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

        NSManagedObjectModel *model = [self model];
        _persistanceCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];

        /* Create directory if it doesn't exist */
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        if([paths count] == 0) {
            DDLogError(@"Could not find Application Support folder");
            return nil;
        }
        NSString *path = [(NSString *)[paths objectAtIndex:0] stringByAppendingPathComponent:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"]];
        if(![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil]) {
            DDLogError(@"Error creating Application Support folder at: %@", path);
        };

        NSPersistentStore *persistanceStore = [_persistanceCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:[path stringByAppendingPathComponent:filename]] options:nil error:&error];
        if(persistanceStore == nil) {
            DDLogError(@"Error loading persistance store at %@", [path stringByAppendingPathComponent:filename]);
        }
    }
    return self;
}

-(NSManagedObjectModel*)model
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
