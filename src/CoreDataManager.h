//
//  CoreDataManager.h
//  dokibox
//
//  Created by Miles Wu on 09/02/2013.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject {
}

-(id)initWithFilename:(NSString *)filename;
-(NSArray*)allModelVersions;
-(NSManagedObjectContext*)newContext;

@property(readonly) NSPersistentStoreCoordinator* persistanceCoordinator;

@end