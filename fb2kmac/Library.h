//
//  Library.h
//  fb2kmac
//
//  Created by Miles Wu on 08/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "common.h"

@interface Library : NSObject {
    dispatch_queue_t _dispatchQueue;
    NSManagedObjectContext *_objectContext;
    NSUserDefaults *_userDefaults;
    FSEventStreamRef _fsEventStream;
}

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


@end
