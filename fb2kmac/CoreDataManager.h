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
    NSManagedObjectContext *_context;
    NSManagedObjectModel *_model;
}
+(CoreDataManager *)sharedInstance;
-(NSManagedObjectModel*)model;

@property(readonly) NSManagedObjectContext *context;

@end
