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

+(CoreDataManager *)sharedInstance
{
    DDLogError(@"Singleton creation method should only be run from subclasses");
    return nil;
}

+(NSManagedObjectContext *)newContext
{
    CoreDataManager *cdm = [[self class] sharedInstance];
    NSManagedObjectContext *context;
    context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:[cdm persistanceCoordinator]];
    return context;
}

-(id)initWithFilename:(NSString *)filename andModel:(NSManagedObjectModel *)model
{
    if(self = [super init]) {
        NSError *error;

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

        NSPersistentStore *persistanceStore __unused = [_persistanceCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:[path stringByAppendingPathComponent:filename]] options:nil error:&error];
    }
    return self;
}

+(BOOL)contextBelongs:(NSManagedObjectContext*)context
{
    CoreDataManager *cdm = [[self class] sharedInstance];
    return ([context persistentStoreCoordinator] == [cdm persistanceCoordinator]);
}

@end
