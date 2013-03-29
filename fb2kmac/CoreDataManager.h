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
    NSManagedObjectModel *_model;
    NSPersistentStoreCoordinator *_persistanceCoordinator;
}
+(CoreDataManager *)sharedInstance;
-(NSManagedObjectModel*)model;
+(NSManagedObjectContext *)newContext;

@property(readonly) NSPersistentStoreCoordinator* persistanceCoordinator;

@end
