//
//  CoreDataManager.h
//  fb2kmac
//
//  Created by Miles Wu on 09/02/2013.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject {
    NSPersistentStoreCoordinator *_persistanceCoordinator;
}
+(CoreDataManager *)sharedInstance;
+(NSManagedObjectContext *)newContext;
-(id)initWithFilename:(NSString *)filename andModel:(NSManagedObjectModel *)model;

@property(readonly) NSPersistentStoreCoordinator* persistanceCoordinator;

@end

#define SHAREDINSTANCE           \
+(CoreDataManager *)sharedInstance \
{ \
    static dispatch_once_t pred; \
    static CoreDataManager *shared = nil;\
    \
    dispatch_once(&pred, ^{ \
        shared = [[[self class] alloc] init]; \
    }); \
    return shared; \
}