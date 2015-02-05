//
//  CoreDataManager.h
//  dokibox
//
//  Created by Miles Wu on 09/02/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject {
}

-(id)initWithFilename:(NSString *)filename;
-(NSArray*)allModelVersions;
-(NSManagedObjectContext*)newContext;
-(NSMappingModel *)simpleMappingModelFor:(NSManagedObjectModel *)sourceModel to:(NSManagedObjectModel *)destModel;
-(NSMappingModel *)exampleCustomMappingModelFor:(NSManagedObjectModel *)sourceModel to:(NSManagedObjectModel *)destModel;
-(void)migrationOccurred;

@property(readonly) NSPersistentStoreCoordinator* persistanceCoordinator;

@end

@interface NSMappingModel (DebuggingUtils)
-(void)debugPrint;
@end
