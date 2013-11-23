//
//  Library.m
//  dokibox
//
//  Created by Miles Wu on 08/02/2013.
//
//

#import "Library.h"
#import "LibraryTrack.h"
#import "LibraryMonitoredFolder.h"
#import "LibraryCoreDataManager.h"
#import <CoreServices/CoreServices.h>


BOOL isFlagSet(unsigned long flags, unsigned long flag);
BOOL isFlagSet(unsigned long flags, unsigned long flag)
{
    if((flags & flag) == flag)
        return YES;
    else
        return NO;
}

void fsEventCallback(ConstFSEventStreamRef streamRef,
                     void *clientCallBackInfo,
                     size_t numEvents,
                     void *eventPaths,
                     const FSEventStreamEventFlags eventFlags[],
                     const FSEventStreamEventId eventIds[]);
void fsEventCallback(ConstFSEventStreamRef streamRef,
                     void *clientCallBackInfo,
                     size_t numEvents,
                     void *eventPaths,
                     const FSEventStreamEventFlags eventFlags[],
                     const FSEventStreamEventId eventIds[])
{
    char **paths = eventPaths;
    Library *library = (__bridge Library *)clientCallBackInfo;
    NSFileManager *fm = [NSFileManager defaultManager];

    // printf("Callback called\n");
    for (int i=0; i<numEvents; i++) {
        NSString *path = [NSString stringWithUTF8String:paths[i]];
        /* flags are unsigned long, IDs are uint64_t */
        if(isFlagSet(eventFlags[i], kFSEventStreamEventFlagHistoryDone)) continue;

        printf("Change %llu in %s, flags %lu\n", eventIds[i], paths[i], eventFlags[i]);
        if(isFlagSet(eventFlags[i], kFSEventStreamEventFlagMustScanSubDirs))
            NSLog(@"must scan subdirs");
        if(isFlagSet(eventFlags[i], kFSEventStreamEventFlagEventIdsWrapped))
            NSLog(@"event ids looped; this is nearly impossible");
        if(isFlagSet(eventFlags[i], kFSEventStreamEventFlagMount) || isFlagSet(eventFlags[i], kFSEventStreamEventFlagUnmount))
            NSLog(@"mount/unmount happened");

        if(isFlagSet(eventFlags[i], kFSEventStreamEventFlagItemIsFile)) {
            if([fm fileExistsAtPath:path]) {
                DDLogCVerbose(@"Detected new file at: %@", path);
                [library addFileOrUpdate:path];
            }
            else {
                DDLogCVerbose(@"Detected removal of file at: %@", path);
                [library removeFile:path];
            }
        }
        if(isFlagSet(eventFlags[i], kFSEventStreamEventFlagItemIsDir)) {
            if([fm fileExistsAtPath:path]) {
                DDLogCVerbose(@"Detected new dir at: %@", path);
                [library searchDirectory:path];
            }
            else {
                DDLogCVerbose(@"Detected removal of dir at: %@", path);
                [library removeFilesInDirectory:path];
            }
        }
        if(isFlagSet(eventFlags[i], kFSEventStreamEventFlagItemIsSymlink)) {
            DDLogCWarn(@"Symlink change detected at: %@ [unimplemented]", path);
        }

        [[library userDefaults] setInteger:eventIds[i] forKey:@"libraryMonitoringLastEventID"];

    }
}


@implementation Library

@synthesize userDefaults = _userDefaults;
@synthesize coreDataManager = _coreDataManager;

-(id)init
{
    if(self = [super init]) {
        _dispatchQueue = dispatch_queue_create("fb2k.library", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_t lowPriorityQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_set_target_queue(_dispatchQueue, lowPriorityQueue);
        
        _coreDataManager = [[LibraryCoreDataManager alloc] init];
        _mainObjectContext = [_coreDataManager newContext];

        dispatch_async(_dispatchQueue, ^{
            _queueObjectContext = [_coreDataManager newContext];
        });

        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

#pragma mark Manipulating monitored folders list

-(NSUInteger)numberOfMonitoredFolders
{
    return [[self monitoredFolders] count];
}

-(LibraryMonitoredFolder *)monitoredFolderAtIndex:(NSUInteger)index
{
    return [[self monitoredFolders] objectAtIndex:index];
}

-(NSArray *)monitoredFolders
{
    if(_monitoredFolders) { // Use cache if available
        return _monitoredFolders;
    }
    else {
        NSError *error;
        NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"monitoredfolder"];
        NSArray *arr = [_mainObjectContext executeFetchRequest:fr error:&error];
        if(arr == nil) {
            DDLogError(@"Error executing fetch request");
            return nil;
        }

        _monitoredFolders = arr;
        return arr;
    }
}

-(void)addMonitoredFolderWithPath:(NSString *)path
{
    NSError *err;
    
    LibraryMonitoredFolder *folder = [NSEntityDescription insertNewObjectForEntityForName:@"monitoredfolder" inManagedObjectContext:_mainObjectContext];
    [folder setPath:path];
    [folder setLastEventID:[NSNumber numberWithLongLong:0]];
    [_mainObjectContext save:&err];
    _monitoredFolders = nil; // Invalidate cache
}

-(void)removeMonitoredFolderAtIndex:(NSUInteger)index
{
    LibraryMonitoredFolder *folder = [self monitoredFolderAtIndex:index];
    [_mainObjectContext deleteObject:folder];
    NSError *err;
    [_mainObjectContext save:&err];
    _monitoredFolders = nil; // Invalidate cache
}


-(void)searchDirectory:(NSString*)dir
{
    [self searchDirectory:dir recurse:YES];
}

-(void)searchDirectory:(NSString*)dir recurse:(BOOL)recursive;
{
    if(dispatch_get_current_queue() != _dispatchQueue) {
        dispatch_async(_dispatchQueue, ^{
            [self searchDirectory:dir recurse:recursive];
        });
        return;
    }

    DDLogVerbose(@"Searching directory: %@", dir);
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];

    NSArray *files = [fm contentsOfDirectoryAtPath:dir error:&error];

    for(NSString *filepath in files) {
        @autoreleasepool {
            NSString *fullfilepath = [dir stringByAppendingPathComponent:filepath];
            BOOL isDir;
            [fm fileExistsAtPath:fullfilepath isDirectory:&isDir];
            if(isDir && recursive) {
                NSDictionary *attributes = [fm attributesOfItemAtPath:fullfilepath error:&error];
                if([attributes objectForKey:NSFileType] == NSFileTypeSymbolicLink) {
                    DDLogWarn(@"symlink found. unsupported");
                }
                [self searchDirectory:fullfilepath recurse:YES];
            }
            else {
                [self addFileOrUpdate:fullfilepath];
            }
        }
    }
}

-(LibraryTrack *)trackFromFile:(NSString *)file
{
    NSError *error;

    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"track"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename == %@", file];
    [fr setPredicate:predicate];

    NSArray *results = [_queueObjectContext executeFetchRequest:fr error:&error];
    if(results == nil) {
        DDLogError(@"error fetching results");
    }
    else if([results count] == 1) {
        return [results objectAtIndex:0];
    }
    else {
        return nil;
    }
}

-(void)addFileOrUpdate:(NSString*)file
{
    if(dispatch_get_current_queue() != _dispatchQueue) {
        dispatch_async(_dispatchQueue, ^{
            [self addFileOrUpdate:file];
        });
        return;
    }

    if(!([[file pathExtension] isEqualToString:@"flac"] || [[file pathExtension] isEqualToString:@"mp3"] || [[file pathExtension] isEqualToString:@"ogg"] || [[file pathExtension] isEqualToString:@"m4a"]))
        return;

    NSError *error;
    LibraryTrack *t = [self trackFromFile:file];
    BOOL isNew = false;

    if(!t) {
        DDLogVerbose(@"Adding file: %@", file);
        isNew = true;

        t = [NSEntityDescription insertNewObjectForEntityForName:@"track" inManagedObjectContext:_queueObjectContext];
        [t setFilename:file];
    }
    else { //already exists in library
        DDLogVerbose(@"Updating file: %@", file);
        [t resetAttributeCache];
    }

    if([t attributes] == nil) { // perhaps IO error
        DDLogWarn(@"Skipping %@... wasn't able to load tags", file);
        if(isNew == true) { //delete if new
            [_queueObjectContext deleteObject:t];
        }
        return;
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

    [t setName:([[t attributes] objectForKey:@"TITLE"] ? [[t attributes] objectForKey:@"TITLE"] : @"")];
    [t setArtistByName:([[t attributes] objectForKey:@"ARTIST"] ? [[t attributes] objectForKey:@"ARTIST"] : @"") andAlbumByName:([[t attributes] objectForKey:@"ALBUM"] ? [[t attributes] objectForKey:@"ALBUM"] : @"")];
    [t setTrackNumber:[numberFormatter numberFromString:[[t attributes] objectForKey:@"TRACKNUMBER"]]];
    [t setLength:[[t attributes] objectForKey:@"length"]];

    if([_queueObjectContext save:&error] == NO) {
        NSLog(@"error saving");
        NSLog(@"%@", [error localizedDescription]);
        for(NSError *e in [[error userInfo] objectForKey:NSDetailedErrorsKey]) {
            NSLog(@"%@", [e localizedDescription]);
        }
    };
}

-(void)removeFilesInDirectory:(NSString *)dir
{
    if(dispatch_get_current_queue() != _dispatchQueue) {
        dispatch_async(_dispatchQueue, ^{
            [self removeFilesInDirectory:dir];
        });
        return;
    }

    NSError *error;

    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"track"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename BEGINSWITH %@", dir];
    [fr setPredicate:predicate];

    NSArray *results = [_queueObjectContext executeFetchRequest:fr error:&error];
    if(results == nil) {
        DDLogError(@"error fetching results");
        return;
    }

    for(LibraryTrack *t in results) {
        [self removeFile:[t filename]];
    }
}

-(void)removeFile:(NSString*)file
{
    if(dispatch_get_current_queue() != _dispatchQueue) {
        dispatch_async(_dispatchQueue, ^{
            [self removeFile:file];
        });
        return;
    }

    NSError *error;
    LibraryTrack *t = [self trackFromFile:file];

    if(t) {
        DDLogVerbose(@"Deleting file: %@", file);
        [_queueObjectContext deleteObject:t];
        if([_queueObjectContext save:&error] == NO) {
            NSLog(@"error saving");
            NSLog(@"%@", [error localizedDescription]);
            for(NSError *e in [[error userInfo] objectForKey:NSDetailedErrorsKey]) {
                NSLog(@"%@", [e localizedDescription]);
            }
        };
    }
}

-(void)startFSMonitor
{
    NSString *path = [[[NSUserDefaults standardUserDefaults] stringForKey:@"libraryLocation"] stringByExpandingTildeInPath];
    CFStringRef cfpath = (__bridge CFStringRef)(path);
    CFArrayRef pathArray = CFArrayCreate(NULL, (const void **)&cfpath, 1, NULL);

    FSEventStreamContext context;
    context.retain = NULL;
    context.release = NULL;
    context.version = 0;
    context.copyDescription = NULL;
    context.info = (__bridge void *)self;

    NSInteger lastEventID;
    if((lastEventID = [_userDefaults integerForKey:@"libraryMonitoringLastEventID"]) == 0) {
        lastEventID = FSEventsGetCurrentEventId();
        [_userDefaults setInteger:lastEventID forKey:@"libraryMonitoringLastEventID"];
    }

    FSEventStreamEventId since = lastEventID;
    _fsEventStream = FSEventStreamCreate(NULL, &fsEventCallback, &context, pathArray, since, 0.0, kFSEventStreamCreateFlagFileEvents);
    FSEventStreamScheduleWithRunLoop(_fsEventStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(_fsEventStream);
    NSLog(@"started FS monitor for %@", path);

    // Initial search of directory
    if([_userDefaults boolForKey:@"libraryMonitoringInitialDone"] == NO) {
        dispatch_async(_dispatchQueue, ^{
            DDLogVerbose(@"Starting initial library search");
            [self searchDirectory:path];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"libraryMonitoringInitialDone"];
            DDLogVerbose(@"Finished initial library search");
        });
    }

}

-(void)stopFSMonitor
{
    FSEventStreamStop(_fsEventStream);
    FSEventStreamInvalidate(_fsEventStream);
    FSEventStreamRelease(_fsEventStream);
    _fsEventStream = nil;
}

-(void)removeAll:(NSString *)entityName
{
    dispatch_async(_dispatchQueue, ^{
        NSError *error;
        NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:entityName];
        [fr setIncludesPropertyValues:NO];
        NSArray *arr = [_queueObjectContext executeFetchRequest:fr error:&error];
        if(arr == nil) {
            DDLogError(@"Error executing fetch request");
            return;
        }

        for(NSManagedObject *obj in arr) {
            [_queueObjectContext deleteObject:obj];
        }

        if([_queueObjectContext save:&error] == NO) {
            DDLogError(@"error saving");
            DDLogError(@"%@", [error localizedDescription]);
            for(NSError *e in [[error userInfo] objectForKey:NSDetailedErrorsKey]) {
                DDLogError(@"%@", [e localizedDescription]);
            }
        };
    });
}

-(void)reset
{
    if(_fsEventStream) {
        [self stopFSMonitor];
    }
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"libraryMonitoringLastEventID"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"libraryMonitoringInitialDone"];
    [self removeAll:@"track"];
    [self removeAll:@"album"];
    [self removeAll:@"artist"];
}

@end
