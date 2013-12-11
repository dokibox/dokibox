//
//  Library.h
//  dokibox
//
//  Created by Miles Wu on 08/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "common.h"

@class LibraryCoreDataManager;
@class LibraryMonitoredFolder;

@interface Library : NSObject {
    dispatch_queue_t _dispatchQueue;
    NSManagedObjectContext *_queueObjectContext;
    NSManagedObjectContext *_mainObjectContext;
    NSUserDefaults *_userDefaults;
    CFMutableArrayRef _fsEventStreams;
    CFMutableArrayRef _fsEventCallbackInfos;
    
    NSArray *_monitoredFolders;
}

-(NSUInteger)numberOfMonitoredFolders;
-(LibraryMonitoredFolder *)monitoredFolderAtIndex:(NSUInteger)index;
-(NSArray *)monitoredFolders;
-(NSString *)addMonitoredFolderWithPath:(NSString *)path;
-(void)removeMonitoredFolderAtIndex:(NSUInteger)index;

-(LibraryTrack *)trackFromFile:(NSString *)file;
-(void)addFileOrUpdate:(NSString*)file;
-(void)removeFile:(NSString*)file;
-(void)searchDirectory:(NSString*)dir recurse:(BOOL)recursive;
-(void)searchDirectory:(NSString*)dir;
-(void)removeFilesInDirectory:(NSString *)dir;

-(void)startFSMonitorForFolder:(LibraryMonitoredFolder *)folder;
-(void)stopFSMonitorForFolder:(LibraryMonitoredFolder *)folder;
-(void)startFSMonitor;

@property(readonly) NSUserDefaults* userDefaults;
@property(readonly) LibraryCoreDataManager* coreDataManager;

@end
