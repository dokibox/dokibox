//
//  CoreDataManager.m
//  dokibox
//
//  Created by Miles Wu on 09/02/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "CoreDataManager.h"

@implementation CoreDataManager

@synthesize persistanceCoordinator = _persistanceCoordinator;

-(id)initWithFilename:(NSString *)filename
{
    if(self = [super init]) {
        NSError *error;

        /* Create directory if it doesn't exist */
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        if([paths count] == 0) {
            DDLogError(@"Could not find Application Support folder");
            return nil;
        }
        NSString *path = [(NSString *)[paths objectAtIndex:0] stringByAppendingPathComponent:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"]];
        if(![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
            DDLogError(@"Error creating Application Support folder at: %@", path);
            return nil;
        }
        NSString *storePath = [path stringByAppendingPathComponent:filename];
        NSURL *urlPath = [NSURL fileURLWithPath:storePath];
        
        // Models
        NSManagedObjectModel *sourceModel = nil;
        NSInteger sourceModelVersion = -1;
        NSArray *allModelVersions = [self allModelVersions];
        NSManagedObjectModel *latestModel = [allModelVersions lastObject];
        NSInteger latestModelVersion = [allModelVersions count];
        
        // Check for migrations if db exists already
        if([[NSFileManager defaultManager] fileExistsAtPath:storePath]) {
            // Obtain metadata
            NSDictionary *metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:nil URL:urlPath error:&error];
            if(error) {
                DDLogError(@"Problem obtaining metadata for persistent store at: %@", path);
                return nil;
            }
            
            // Find suitable model version
            DDLogVerbose(@"Latest model version: %ld", latestModelVersion);
            for(NSInteger i=[allModelVersions count]-1; i>=0; i--) { // work backwards
                NSManagedObjectModel *m = [allModelVersions objectAtIndex:i];
                
                if([m isConfiguration:nil compatibleWithStoreMetadata:metadata]) {
                    DDLogVerbose(@"Source model version: %ld", i+1);
                    sourceModel = m;
                    sourceModelVersion = i+1;
                    break;
                }
            }
            if(sourceModel == nil) {
                DDLogError(@"Could not find a suitable model to open store at: %@", path);
                return nil;
            }
            
            // Migration if necessary
            if(latestModel != sourceModel) {
                DDLogInfo(@"A migration is necessary");
                BOOL success = [self migrateStore:storePath from:sourceModel to:latestModel sourceVersion:sourceModelVersion];
                if(success == NO) {
                    DDLogError(@"Migration failed for store at: %@", path);
                    return nil;
                }
            }
        }
        
        _persistanceCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:latestModel];
        NSPersistentStore *persistanceStore = [_persistanceCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:urlPath options:nil error:&error];
        if(persistanceStore == nil) {
            DDLogError(@"Error loading persistance store at %@", [path stringByAppendingPathComponent:filename]);
            DDLogError(@"%@", [error localizedDescription]);
        }
        
        // If a migration occured, call the post-migration handler (for various tasks)
        if(latestModel != sourceModel && sourceModel != nil) {
            [self migrationOccurred];
        }
    }
    return self;
}

-(BOOL)migrateStore:(NSString *)storePath from:(NSManagedObjectModel *)sourceModel to:(NSManagedObjectModel *)destModel sourceVersion:(NSInteger)sourceVersion
{
    // Obtain mapping Model from inference
    NSError *error;
    NSMappingModel *mappingModel = [NSMappingModel inferredMappingModelForSourceModel:sourceModel destinationModel:destModel error:&error];
    if(error || !mappingModel) {
        DDLogError(@"Unable to obtain inferred mapping during migration.");
        return false;
    }
    
    // Remove old temp files if they exist
    NSString *tmpSuffix = @".migration";
    NSString *tempPath = [storePath stringByAppendingString:tmpSuffix];
    [self removeSQLFiles:tempPath];
    
    // Migrate
    NSURL *tempURL = [NSURL fileURLWithPath:tempPath];
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destModel];
    BOOL success = [migrationManager migrateStoreFromURL:storeURL type:NSSQLiteStoreType options:nil withMappingModel:mappingModel toDestinationURL:tempURL destinationType:NSSQLiteStoreType destinationOptions:nil error:&error];
    if(!success || error) {
        DDLogError(@"Failed migration.");
        return false;
    }
    
    // Make backup of old version
    NSString *storeBackupPath = [NSString stringWithFormat:@"%@.v%ld", storePath, sourceVersion];
    success = [self moveSQLFilesFrom:storePath to:storeBackupPath];
    if(!success) {
        DDLogError(@"Failed migration.");
        return false;
    }
    
    // Move new version
    success = [self moveSQLFilesFrom:tempPath to:storePath];
    if(!success) {
        DDLogError(@"Failed migration.");
        return false;
    }
    
    DDLogInfo(@"Migration successful");
    return true;
}

-(BOOL)moveSQLFilesFrom:(NSString*)srcPath to:(NSString *)destPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *fileExtensions = [NSArray arrayWithObjects:@"", @"-shm", @"-wal", nil]; // Includes sqlite tmp files
    for(NSString *ext in fileExtensions) {
        NSString *src =[NSString stringWithFormat:@"%@%@", srcPath, ext];
        NSString *dest =[NSString stringWithFormat:@"%@%@", destPath, ext];
        
        [fileManager moveItemAtPath:src toPath:dest error:&error];
        if(error) {
            DDLogError(@"Error moving SQL file from %@ to %@", src, dest);
            return false;
        }
    }
    
    return true;
}

-(BOOL)removeSQLFiles:(NSString*)basePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *fileExtensions = [NSArray arrayWithObjects:@"", @"-shm", @"-wal", nil]; // Includes sqlite tmp files
    for(NSString *ext in fileExtensions) {
        NSString *p =[NSString stringWithFormat:@"%@%@", basePath, ext];
        if([fileManager fileExistsAtPath:p]) {
            [fileManager removeItemAtPath:p error:&error];
            if(error) {
                DDLogError(@"Error removing SQL file at %@", p);
                return false;
            }
        }
    }
    
    return true;
}

-(NSArray*)allModelVersions
{
    DDLogError(@"CoreDataManager model should be overidden and never called");
    return nil;
}

-(NSManagedObjectContext*)newContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:[self persistanceCoordinator]];
    return context;
}

-(void)migrationOccurred
{
    // Virtual method (to be overriden)
    // Can be used for doing various DB tasks after a migration
}

#pragma mark Custom mapping models
-(NSMappingModel *)simpleMappingModelFor:(NSManagedObjectModel *)sourceModel to:(NSManagedObjectModel *)destModel
{
    // This creates a simple 1:1 copy mapping model:
    //   it simply creates a map for each entity and each entities' property in the destModel, telling them to take the value from the source model
    //   assuming that the same entities and properties are also present in the srcModel with the same names etc.
    // Since this is mostly true for most DB migrations, you can take this as a base mapping model
    //   and then modify it to match what you need (eg. changing the value expressions).
    //   An example of this is in exampleCustomMappingModelFor:to:
    
    NSMutableArray *entityMappings = [NSMutableArray array];
    
    for(NSEntityDescription *destEntity in [destModel entities]) {
        NSEntityMapping *entityMapping = [[NSEntityMapping alloc] init];
        NSString *srcExprFormat = [NSString stringWithFormat:@"FETCH(FUNCTION($%@, \"fetchRequestForSourceEntityNamed:predicateString:\" , \"%@\", \"TRUEPREDICATE\"), $%@.sourceContext, NO)", NSMigrationManagerKey, [destEntity name], NSMigrationManagerKey];
        [entityMapping setSourceExpression:[NSExpression expressionWithFormat:srcExprFormat]]; // I believe this is used to substitute for $source in the valueExpressions
        [entityMapping setDestinationEntityName:[destEntity name]];
        [entityMapping setSourceEntityName:[destEntity name]];
        [entityMapping setName:[destEntity name]];
        [entityMapping setMappingType:NSCopyEntityMappingType];
        
        NSMutableArray *attributeMappings = [NSMutableArray array];
        NSMutableArray *relationshipMappings = [NSMutableArray array];
        for(NSPropertyDescription *p in [destEntity properties]) {
            NSPropertyMapping *pmap = [[NSPropertyMapping alloc] init];
            [pmap setName:[p name]];
            
            if([p isKindOfClass:[NSAttributeDescription class]]) {
                NSString *exprFormat = [NSString stringWithFormat:@"$%@.%@", NSMigrationSourceObjectKey, [p name]]; //This is $source.%name
                [pmap setValueExpression:[NSExpression expressionWithFormat:exprFormat]];
                [attributeMappings addObject:pmap];
            }
            else if ([p isKindOfClass:[NSRelationshipDescription class]]) {
                NSString *exprFormat = [NSString stringWithFormat:@"FUNCTION($%@, 'destinationInstancesForSourceRelationshipNamed:sourceInstances:', '%@', $%@.%@)", NSMigrationManagerKey, [p name], NSMigrationSourceObjectKey, [p name]]; // This is needed otherwise it'll complain about trying to assign instances from the source Context to the dest Context. I believe this function finds the appropriate instances in the dest Context automatically
                [pmap setValueExpression:[NSExpression expressionWithFormat:exprFormat]];
                [relationshipMappings addObject:pmap];
            }
        }
        
        [entityMapping setAttributeMappings:attributeMappings];
        [entityMapping setRelationshipMappings:relationshipMappings];
        
        if([sourceModel entitiesByName][entityMapping.name]) {
            [entityMapping setSourceEntityVersionHash: [[[sourceModel entitiesByName] objectForKey:[entityMapping name]] versionHash]];
        }
        [entityMapping setDestinationEntityVersionHash:[destEntity versionHash]];
        
        [entityMappings addObject:entityMapping];
    }
    
    NSMappingModel *mappingModel = [[NSMappingModel alloc] init];
    [mappingModel setEntityMappings:entityMappings];
    
    return mappingModel;
}

-(NSMappingModel *)exampleCustomMappingModelFor:(NSManagedObjectModel *)sourceModel to:(NSManagedObjectModel *)destModel
{
    // This is an example of a custom mapping model. It was last tested for Library v1->v2.
    // It does two things:
    //  1. Adds "hi " in front of every track name
    //  2. Fills the new trackArtistName field with "hi"
    // NB: I believe a mapping is required for every entity and every entities' properties
    
    // Get simple copy mappingModel first
    NSMappingModel *mappingModel = [self simpleMappingModelFor:sourceModel to:destModel];

    // Now let's modify the track mapping
    NSEntityMapping *trackEntityMapping = [[mappingModel entityMappingsByName] objectForKey:@"track"];
    
    // this Class is where our custom mapping functions live
    [trackEntityMapping setEntityMigrationPolicyClassName:@"CustomMigrationPolicyExample"];
    
    for(NSPropertyMapping *pmap in [trackEntityMapping attributeMappings]) {
        if([[pmap name] isEqualToString:@"name"]) {
            // the syntax is: FUNCTION(operand, func name, args). Operand in our case is $policy (which is an instance of the custom migration policy class)
            // and then we call its prefixStringWithHi function and give it $source.name (the prev value)
            NSString *exprFormat = [NSString stringWithFormat:@"FUNCTION($%@, 'prefixStringWithHi:', $%@.%@)", NSMigrationEntityPolicyKey, NSMigrationSourceObjectKey, [pmap name]];
            [pmap setValueExpression:[NSExpression expressionWithFormat:exprFormat]];
        }
        else if([pmap.name isEqualToString:@"trackArtistName"]) {
            NSString *exprFormat = [NSString stringWithFormat:@"FUNCTION($%@, 'placeholderString')", NSMigrationEntityPolicyKey];
            [pmap setValueExpression:[NSExpression expressionWithFormat:exprFormat]];
        }
    }
    
    return mappingModel;
}

@end

@implementation NSMappingModel (DebuggingUtils)

-(void)debugPrint
{
    for(NSEntityMapping *e in [self entityMappings]) {
        DDLogVerbose(@"Mapping \"%@\" (%@ -> %@)", [e name], [e sourceEntityName], [e destinationEntityName]);
        DDLogVerbose(@"  Type %ld, Policy %@", [e mappingType], [e entityMigrationPolicyClassName]);
        DDLogVerbose(@"  Ver: %@ -> %@", [e sourceEntityVersionHash], [e destinationEntityVersionHash]);
        DDLogVerbose(@"  Src Expr: %@", [e sourceExpression]);
        DDLogVerbose(@"  Userinfo %@", [e userInfo]);
        for(NSPropertyMapping *p in [e attributeMappings]) {
            DDLogVerbose(@"    - Prop %@: %@", [p name], [p valueExpression]);
        }
        for(NSPropertyMapping *p in [e relationshipMappings]) {
            DDLogVerbose(@"    - Rel %@: %@", [p name], [p valueExpression]);
        }
    }
}

@end

// These are the custom mapping functions that we can call in the PropertyMapping valueExpressions
@interface CustomMigrationPolicyExample : NSEntityMigrationPolicy
-(NSString *)prefixStringWithHi:(NSString *)s;
-(NSString *)placeholderString;
@end

@implementation CustomMigrationPolicyExample

-(NSString *)prefixStringWithHi:(NSString *)s
{
    return [@"hi " stringByAppendingString:s];
}
-(NSString *)placeholderString
{
    return @"hi";
}


@end
