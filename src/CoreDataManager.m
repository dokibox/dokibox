//
//  CoreDataManager.m
//  dokibox
//
//  Created by Miles Wu on 09/02/2013.
//
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
        NSURL *urlPath = [NSURL fileURLWithPath:[path stringByAppendingPathComponent:filename]];
        
        // Obtain metadata
        NSDictionary *metadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:nil URL:urlPath error:&error];
        if(error) {
            DDLogError(@"Problem obtaining metadata for persistent store at: %@", path);
            return nil;
        }
        
        // Find suitable model version
        NSManagedObjectModel *sourceModel = nil;
        NSInteger sourceModelVersion = -1;
        NSArray *allModelVersions = [self allModelVersions];
        NSManagedObjectModel *latestModel = [allModelVersions lastObject];
        NSInteger latestModelVersion = [allModelVersions count];
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
            // TODO
        }
        
        
        _persistanceCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:latestModel];
        
        NSPersistentStore *persistanceStore = [_persistanceCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:urlPath options:nil error:&error];
        if(persistanceStore == nil) {
            DDLogError(@"Error loading persistance store at %@", [path stringByAppendingPathComponent:filename]);
            DDLogError(@"%@", [error localizedDescription]);
        }
    }
    return self;
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

@end
