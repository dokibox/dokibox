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
@class LibraryFolder;

@interface Library : NSObject {
    dispatch_queue_t _dispatchQueue;
    NSManagedObjectContext *_queueObjectContext;
    NSManagedObjectContext *_mainObjectContext;
    NSUserDefaults *_userDefaults;
    FSEventStreamRef _fsEventStream;
}

-(NSUInteger)numberOfFolders;
-(LibraryFolder *)folderAtIndex:(NSUInteger)index;
-(NSArray *)folders;
-(void)addFolderWithPath:(NSString *)path;

-(LibraryTrack *)trackFromFile:(NSString *)file;
-(void)addFileOrUpdate:(NSString*)file;
-(void)removeFile:(NSString*)file;
-(void)searchDirectory:(NSString*)dir recurse:(BOOL)recursive;
-(void)searchDirectory:(NSString*)dir;
-(void)removeFilesInDirectory:(NSString *)dir;
-(void)startFSMonitor;
-(void)stopFSMonitor;
-(void)reset;
-(void)removeAll:(NSString *)entityName;

@property(readonly) NSUserDefaults* userDefaults;
@property(readonly) LibraryCoreDataManager* coreDataManager;

@end
