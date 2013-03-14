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
            if(isFlagSet(eventFlags[i], kFSEventStreamEventFlagItemCreated)) {
                DDLogCVerbose(@"New file detected at: %@", path);
                [library addFile:path];
            }
            NSLog(@"file");
        }
        if(isFlagSet(eventFlags[i], kFSEventStreamEventFlagItemIsDir)) {
            DDLogCVerbose(@"Dir change detected at: %@ [no action]", path);
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
    CoreDataManager *cdm = [CoreDataManager sharedInstance];
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
                [self addFile:fullfilepath];
            }
        }
    }
}

-(void)addFile:(NSString*)file
{
    if(!([[file pathExtension] isEqualToString:@"flac"] || [[file pathExtension] isEqualToString:@"mp3"]))
        return;
    
    NSError *error;
    Track *t;
    CoreDataManager *cdm = [CoreDataManager sharedInstance];
    
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"track"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename LIKE %@", file];
    [fr setPredicate:predicate];
    
    NSArray *results = [[cdm context] executeFetchRequest:fr error:&error];
    if(results == nil) {
        NSLog(@"error fetching results");
    }
    else if([results count] == 0) {
        DDLogVerbose(@"Adding file: %@", file);
        
        t = [NSEntityDescription insertNewObjectForEntityForName:@"track" inManagedObjectContext:[cdm context]];
        [t setFilename:file];
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
    else { //already exists in library
        t = [results objectAtIndex:0];
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
    FSEventStreamRef stream = FSEventStreamCreate(NULL, &fsEventCallback, &context, pathArray, since, 1.0, kFSEventStreamCreateFlagFileEvents);
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
    NSLog(@"started FS monitor");
}

@end
