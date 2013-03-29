//
//  CoreDataManager.m
//  fb2kmac
//
//  Created by Miles Wu on 09/02/2013.
//
//

#import "CoreDataManager.h"
#import "Track.h"

@implementation CoreDataManager

@synthesize persistanceCoordinator = _persistanceCoordinator;

+(CoreDataManager *)sharedInstance
{
    static dispatch_once_t pred;
    static CoreDataManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[CoreDataManager alloc] init];
    });
    return shared;
}

+(NSManagedObjectContext *)newContext
{
    CoreDataManager *cdm = [CoreDataManager sharedInstance];
    NSManagedObjectContext *context;
    context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:[cdm persistanceCoordinator]];
    return context;
}

-(id)init
{
    if(self = [super init]) {
        NSError *error;
        
        _model = [self model];        
        
        _persistanceCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        
        NSPersistentStore *persistanceStore __unused = [persistanceCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:[@"~/Desktop/fb2kmac/derp.sql" stringByExpandingTildeInPath]] options:nil error:&error];
        [_context setPersistentStoreCoordinator:persistanceCoordinator];
    }
    return self;
}


-(NSManagedObjectModel*)model
{
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] init];
    NSMutableArray *entities = [[NSMutableArray alloc] init];
    
    NSEntityDescription *trackEntity = [[NSEntityDescription alloc] init];
    NSEntityDescription *albumEntity = [[NSEntityDescription alloc] init];
    NSEntityDescription *artistEntity = [[NSEntityDescription alloc] init];
    
    { // Track
        [trackEntity setName:@"track"];
        [trackEntity setManagedObjectClassName:@"Track"];
        NSMutableArray *trackProperties = [[NSMutableArray alloc] init];
        { // trackEntity properties
            NSAttributeDescription *filenameAttribute = [[NSAttributeDescription alloc] init];
            [filenameAttribute setName:@"filename"];
            [filenameAttribute setAttributeType:NSStringAttributeType];
            [filenameAttribute setOptional:NO];
            [trackProperties addObject:filenameAttribute];
            
            NSAttributeDescription *nameAttribute = [[NSAttributeDescription alloc] init];
            [nameAttribute setName:@"name"];
            [nameAttribute setAttributeType:NSStringAttributeType];
            [nameAttribute setOptional:NO];
            [trackProperties addObject:nameAttribute];
            
            NSAttributeDescription *attributesAttribute = [[NSAttributeDescription alloc] init];
            [attributesAttribute setName:@"attributes"];
            [attributesAttribute setAttributeType:NSUndefinedAttributeType];
            [attributesAttribute setTransient:YES];
            [trackProperties addObject:attributesAttribute];
            
            NSRelationshipDescription *albumRelation = [[NSRelationshipDescription alloc] init];
            [albumRelation setName:@"album"];
            [albumRelation setDestinationEntity:albumEntity];
            [albumRelation setMaxCount:1];
            [albumRelation setMinCount:1];
            //[albumRelation setOptional:NO];
            [trackProperties addObject:albumRelation];
        }
        [trackEntity setProperties:trackProperties];
        [entities addObject:trackEntity];
    }
    
    { // album
        [albumEntity setName:@"album"];
        [albumEntity setManagedObjectClassName:@"Album"];
        NSMutableArray *albumProperties = [[NSMutableArray alloc] init];
        { // albumEntity properties
            NSAttributeDescription *nameAttribute = [[NSAttributeDescription alloc] init];
            [nameAttribute setName:@"name"];
            [nameAttribute setAttributeType:NSStringAttributeType];
            [nameAttribute setOptional:NO];
            [albumProperties addObject:nameAttribute];
            
            NSRelationshipDescription *artistRelation = [[NSRelationshipDescription alloc] init];
            [artistRelation setName:@"artist"];
            [artistRelation setDestinationEntity:artistEntity];
            [artistRelation setMaxCount:1];
            [artistRelation setMinCount:1];
            //[artistRelation setOptional:NO];
            [albumProperties addObject:artistRelation];
            
            NSRelationshipDescription *tracksRelation = [[NSRelationshipDescription alloc] init];
            [tracksRelation setName:@"tracks"];
            [tracksRelation setDestinationEntity:trackEntity];
            [tracksRelation setMinCount:1];
            //[tracksRelation setOptional:NO];
            [albumProperties addObject:tracksRelation];
            
        }
        [albumEntity setProperties:albumProperties];
        [entities addObject:albumEntity];
    }
    
    { // Artist
        [artistEntity setName:@"artist"];
        [artistEntity setManagedObjectClassName:@"Artist"];
        NSMutableArray *artistProperties = [[NSMutableArray alloc] init];
        { // artistEntity properties
            NSAttributeDescription *nameAttribute = [[NSAttributeDescription alloc] init];
            [nameAttribute setName:@"name"];
            [nameAttribute setAttributeType:NSStringAttributeType];
            [nameAttribute setOptional:NO];
            [artistProperties addObject:nameAttribute];
            
            NSRelationshipDescription *albumsRelation = [[NSRelationshipDescription alloc] init];
            [albumsRelation setName:@"albums"];
            [albumsRelation setDestinationEntity:albumEntity];
            [albumsRelation setMinCount:1];
            //[albumsRelation setOptional:NO];
            [artistProperties addObject:albumsRelation];
        }
        [artistEntity setProperties:artistProperties];
        [entities addObject:artistEntity];
    }
    
    [[[artistEntity relationshipsByName] objectForKey:@"albums"] setInverseRelationship:[[albumEntity relationshipsByName] objectForKey:@"artist"]];
    [[[albumEntity relationshipsByName] objectForKey:@"artist"] setInverseRelationship:[[artistEntity relationshipsByName] objectForKey:@"albums"]];
    [[[albumEntity relationshipsByName] objectForKey:@"tracks"] setInverseRelationship:[[trackEntity relationshipsByName] objectForKey:@"album"]];
    [[[trackEntity relationshipsByName] objectForKey:@"album"] setInverseRelationship:[[albumEntity relationshipsByName] objectForKey:@"tracks"]];
    
    [mom setEntities:entities];
    return mom;
}

@end
