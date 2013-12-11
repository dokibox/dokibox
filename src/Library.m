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

struct fsEventCallbackInfo {
    void *library;
    void *monitoredFolder;
};

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
    struct fsEventCallbackInfo *info = (struct fsEventCallbackInfo*)clientCallBackInfo;
    
    Library *library = (__bridge Library *)info->library;
    LibraryMonitoredFolder *folder = (__bridge LibraryMonitoredFolder *)info->monitoredFolder;
    NSLog(@"Monitored folder: %@", [folder path]);
    
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

        [folder setLastEventID:[NSNumber numberWithInteger:eventIds[i]]];
    }
    
    NSError *err;
    [[folder managedObjectContext] save:&err];
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
        _fsEventStreams = CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
        _fsEventCallbackInfos =CFArrayCreateMutable(kCFAllocatorDefault, 0, NULL);
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
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                    initWithKey:@"path"
                                    ascending:YES
                                    selector:@selector(localizedCaseInsensitiveCompare:)];
        [fr setSortDescriptors:[NSArray arrayWithObjects:sorter, nil]];
        NSArray *arr = [_mainObjectContext executeFetchRequest:fr error:&error];
        if(arr == nil) {
            DDLogError(@"Error executing fetch request");
            return nil;
        }

        _monitoredFolders = arr;
        return arr;
    }
}

-(NSString *)addMonitoredFolderWithPath:(NSString *)path
{
    for(LibraryMonitoredFolder *monitoredFolder in [self monitoredFolders]) {
        NSString *i = [monitoredFolder path];
        if([i isEqualTo:path])
            return @"This folder is already being monitored.";
        if([i hasPrefix:path] || [path hasPrefix:i])
            return @"You may not add a new folder that is a subfolder or superfolder of an existing monitored folder.";
    }
    
    NSError *err;
    
    LibraryMonitoredFolder *folder = [NSEntityDescription insertNewObjectForEntityForName:@"monitoredfolder" inManagedObjectContext:_mainObjectContext];
    [folder setPath:path];
    [folder setLastEventID:[NSNumber numberWithLongLong:0]];
    [folder setInitialScanDone:[NSNumber numberWithBool:NO]];
    
    [_mainObjectContext save:&err];
    _monitoredFolders = nil; // Invalidate cache
    [self startFSMonitorForFolder:folder];
    
    return nil;
}

-(NSString *)removeMonitoredFolderAtIndex:(NSUInteger)index
{
    LibraryMonitoredFolder *folder = [self monitoredFolderAtIndex:index];
    if([[folder initialScanDone] boolValue] == NO) {
        return @"You cannot remove a monitored folder while the initial scan is in progress. Please try again later.";
    }
    NSString *path = [folder path];
    [_mainObjectContext deleteObject:folder];
    
    NSError *err;
    [_mainObjectContext save:&err];
    _monitoredFolders = nil; // Invalidate cache
    
    [self stopFSMonitorForFolder:folder];
    [self removeFilesInDirectory:path];
    return nil;
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

-(void)startFSMonitorForFolder:(LibraryMonitoredFolder *)folder
{
    CFStringRef cfpath = (__bridge CFStringRef)([folder path]);
    CFArrayRef pathArray = CFArrayCreate(NULL, (const void **)&cfpath, 1, NULL);
    
    struct fsEventCallbackInfo *info = malloc(sizeof(struct fsEventCallbackInfo));
    info->library = (__bridge void *)(self);
    info->monitoredFolder = (void*)CFBridgingRetain(folder);
    
    FSEventStreamContext context;
    context.retain = NULL;
    context.release = NULL;
    context.version = 0;
    context.copyDescription = NULL;
    context.info = (void *)info;
    
    NSInteger lastEventID = [[folder lastEventID] integerValue];
    if(lastEventID == 0) {
        lastEventID = FSEventsGetCurrentEventId();
        [folder setLastEventID:[NSNumber numberWithInteger:lastEventID]];
        NSError *err;
        [_mainObjectContext save:&err];
    }
    
    FSEventStreamEventId since = lastEventID;
    FSEventStreamRef fsEventStream = FSEventStreamCreate(NULL, &fsEventCallback, &context, pathArray, since, 0.0, kFSEventStreamCreateFlagFileEvents);
    CFArrayAppendValue(_fsEventStreams, fsEventStream);
    CFArrayAppendValue(_fsEventCallbackInfos, info);
    
    FSEventStreamScheduleWithRunLoop(fsEventStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(fsEventStream);
    NSLog(@"started FS monitor for %@", [folder path]);
    
    // Initial search of directory
    if([[folder initialScanDone] boolValue] == NO) {
        NSString *path = [folder path];
        dispatch_async(_dispatchQueue, ^{
            DDLogVerbose(@"Starting initial library search for %@", path);
            [self searchDirectory:path];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"libraryMonitoringInitialDone"];
            DDLogVerbose(@"Finished initial library search for %@", path);
            dispatch_async(dispatch_get_main_queue(), ^{
                [folder setInitialScanDone:[NSNumber numberWithBool:YES]];
                NSError *err;
                [[folder managedObjectContext] save:&err];
            });
     });
    }
}

-(void)stopFSMonitorForFolder:(LibraryMonitoredFolder *)folder
{
    CFIndex n = CFArrayGetCount(_fsEventStreams);
    for(CFIndex i = 0; i < n; i++) {
        FSEventStreamRef ref = (FSEventStreamRef)CFArrayGetValueAtIndex(_fsEventStreams, i);
        struct fsEventCallbackInfo *info = (struct fsEventCallbackInfo *)CFArrayGetValueAtIndex(_fsEventCallbackInfos, i);
        
        if(info->monitoredFolder == (__bridge void *)(folder)) {
            FSEventStreamStop(ref);
            FSEventStreamInvalidate(ref);
            FSEventStreamRelease(ref);
            CFRelease(info->monitoredFolder);
            free(info);
            
            CFArrayRemoveValueAtIndex(_fsEventStreams, i);
            CFArrayRemoveValueAtIndex(_fsEventCallbackInfos, i);
            break;
        }
    }
}

-(void)startFSMonitor
{
    for(LibraryMonitoredFolder *folder in [self monitoredFolders]) {
        [self startFSMonitorForFolder:folder];
    }
}


@end
