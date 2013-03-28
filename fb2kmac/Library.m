//
//  Library.m
//  fb2kmac
//
//  Created by Miles Wu on 08/02/2013.
//
//

#import "Library.h"
#import "Track.h"
#import "CoreDataManager.h"
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
    }
}


@implementation Library

-(void)searchDirectory:(NSString*)dir
{
    [self searchDirectory:dir recurse:YES];
}

-(void)searchDirectory:(NSString*)dir recurse:(BOOL)recursive;
{
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

-(Track *)trackFromFile:(NSString *)file
{
    NSError *error;
    CoreDataManager *cdm = [CoreDataManager sharedInstance];
    
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"track"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename LIKE %@", file];
    [fr setPredicate:predicate];
    
    NSArray *results = [[cdm context] executeFetchRequest:fr error:&error];
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
    if(!([[file pathExtension] isEqualToString:@"flac"] || [[file pathExtension] isEqualToString:@"mp3"]))
        return;
    
    NSError *error;
    Track *t = [self trackFromFile:file];
    CoreDataManager *cdm = [CoreDataManager sharedInstance];
    BOOL isNew = false;
    
    if(!t) {
        DDLogVerbose(@"Adding file: %@", file);
        isNew = true;
        
        t = [NSEntityDescription insertNewObjectForEntityForName:@"track" inManagedObjectContext:[cdm context]];
        [t setFilename:file];
    }
    else { //already exists in library
        DDLogVerbose(@"Updating file: %@", file);
        [t resetAttributeCache];
    }
    
    if([t attributes] == nil) { // perhaps IO error
        DDLogWarn(@"Skipping %@... wasn't able to load tags", file);
        if(isNew == true) { //delete if new
            [[cdm context] deleteObject:t];
        }
        return;
    }
    
    [t setName:([[t attributes] objectForKey:@"TITLE"] ? [[t attributes] objectForKey:@"TITLE"] : @"")];
    [t setArtistByName:([[t attributes] objectForKey:@"ARTIST"] ? [[t attributes] objectForKey:@"ARTIST"] : @"") andAlbumByName:([[t attributes] objectForKey:@"ALBUM"] ? [[t attributes] objectForKey:@"ALBUM"] : @"")];
    
    if([[cdm context] save:&error] == NO) {
        NSLog(@"error saving");
        NSLog(@"%@", [error localizedDescription]);
        for(NSError *e in [[error userInfo] objectForKey:NSDetailedErrorsKey]) {
            NSLog(@"%@", [e localizedDescription]);
        }
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"libraryUpdated" object:nil];

}

-(void)removeFilesInDirectory:(NSString *)dir
{
    NSError *error;
    CoreDataManager *cdm = [CoreDataManager sharedInstance];
    
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"track"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename BEGINSWITH %@", dir];
    [fr setPredicate:predicate];
    
    NSArray *results = [[cdm context] executeFetchRequest:fr error:&error];
    if(results == nil) {
        DDLogError(@"error fetching results");
        return;
    }
    
    for(Track *t in results) {
        [self removeFile:[t filename]];
    }
}

-(void)removeFile:(NSString*)file
{
    NSError *error;
    CoreDataManager *cdm = [CoreDataManager sharedInstance];
    Track *t = [self trackFromFile:file];
    
    if(t) {
        DDLogVerbose(@"Deleting file: %@", file);
        [[cdm context] deleteObject:t];
        if([[cdm context] save:&error] == NO) {
            NSLog(@"error saving");
            NSLog(@"%@", [error localizedDescription]);
            for(NSError *e in [[error userInfo] objectForKey:NSDetailedErrorsKey]) {
                NSLog(@"%@", [e localizedDescription]);
            }
        };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"libraryUpdated" object:nil];
    }
}

-(void)startFSMonitor
{
    CFStringRef path = (__bridge CFStringRef)([@"~/fb2kmusic" stringByExpandingTildeInPath]);
    CFArrayRef pathArray = CFArrayCreate(NULL, (const void **)&path, 1, NULL);
    
    FSEventStreamContext context;
    context.retain = NULL;
    context.release = NULL;
    context.version = 0;
    context.copyDescription = NULL;
    context.info = (__bridge void *)self;
    
    NSLog(@"%d", FSEventsGetCurrentEventId());
    //FSEventStreamEventId since = 24630466;
    FSEventStreamEventId since = FSEventsGetCurrentEventId();
    FSEventStreamRef stream = FSEventStreamCreate(NULL, &fsEventCallback, &context, pathArray, since, 0.0, kFSEventStreamCreateFlagFileEvents);
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
    NSLog(@"started FS monitor");
}

@end
