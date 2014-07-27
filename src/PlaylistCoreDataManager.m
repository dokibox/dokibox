//
//  PlaylistCoreDataManager.m
//  dokibox
//
//  Created by Miles Wu on 30/06/2013.
//
//

#import "PlaylistCoreDataManager.h"
#import "ProfileController.h"
#import "PlaylistTrack.h"

@implementation PlaylistCoreDataManager

-(id)init
{
    NSString *filename = [[NSString alloc] initWithFormat:@"playlist-%@.sql", [[ProfileController sharedInstance] currentUUID]];
    if(self = [super initWithFilename:filename]) {
    }
    return self;
}

-(NSArray*)allModelVersions
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [arr addObject:[self model_v1]];
    [arr addObject:[self model_v2]];
    return arr;
}

-(void)migrationOccurred
{
    NSManagedObjectContext *context = [self newContext];
    [PlaylistTrack markAllTracksForUpdateIn:context];
}

-(NSManagedObjectModel*)model_v2
{
    NSManagedObjectModel *mom = [self model_v1];
    
    NSEntityDescription *trackEntity = [[mom entitiesByName] objectForKey:@"track"];
    NSMutableArray *trackEntity_properties = [NSMutableArray arrayWithArray:[trackEntity properties]];
    
    // Rename artistName->trackArtistName (delete old property, create new one with renamingIdentifier)
    [trackEntity_properties removeObject:[[trackEntity propertiesByName] objectForKey:@"artistName"]];
    NSAttributeDescription *trackEntity_trackArtistName = [[NSAttributeDescription alloc] init];
    [trackEntity_trackArtistName setName:@"trackArtistName"];
    [trackEntity_trackArtistName setRenamingIdentifier:@"artistName"];
    [trackEntity_trackArtistName setAttributeType:NSStringAttributeType];
    [trackEntity_trackArtistName setOptional:NO];
    [trackEntity_properties addObject:trackEntity_trackArtistName];
    
    // Add albumArtistName
    NSAttributeDescription *trackEntity_albumArtistName = [[NSAttributeDescription alloc] init];
    [trackEntity_albumArtistName setName:@"albumArtistName"];
    [trackEntity_albumArtistName setAttributeType:NSStringAttributeType];
    [trackEntity_properties addObject:trackEntity_albumArtistName];
    
    // Add needsUpdate
    NSAttributeDescription *trackEntity_needsUpdate = [[NSAttributeDescription alloc] init];
    [trackEntity_needsUpdate setName:@"needsUpdate"];
    [trackEntity_needsUpdate setDefaultValue:[NSNumber numberWithBool:NO]];
    [trackEntity_needsUpdate setOptional:NO];
    [trackEntity_needsUpdate setAttributeType:NSBooleanAttributeType];
    [trackEntity_properties addObject:trackEntity_needsUpdate];
    
    [trackEntity setProperties:trackEntity_properties];
    
    return mom;
}

-(NSManagedObjectModel*)model_v1
{
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] init];
    NSMutableArray *entities = [[NSMutableArray alloc] init];

    NSEntityDescription *playlistTrackEntity = [[NSEntityDescription alloc] init];
    NSEntityDescription *playlistEntity = [[NSEntityDescription alloc] init];

    { // playlistTrack
        [playlistTrackEntity setName:@"track"];
        [playlistTrackEntity setManagedObjectClassName:@"PlaylistTrack"];
        NSMutableArray *playlistTrackProperties = [[NSMutableArray alloc] init];
        { // playlistTrackEntity properties
            NSAttributeDescription *filenameAttribute = [[NSAttributeDescription alloc] init];
            [filenameAttribute setName:@"filename"];
            [filenameAttribute setAttributeType:NSStringAttributeType];
            [filenameAttribute setOptional:NO];
            [playlistTrackProperties addObject:filenameAttribute];
            
            NSAttributeDescription *indexAttribute = [[NSAttributeDescription alloc] init];
            [indexAttribute setName:@"index"];
            [indexAttribute setAttributeType:NSInteger32AttributeType];
            [indexAttribute setOptional:NO];
            [playlistTrackProperties addObject:indexAttribute];

            NSAttributeDescription *nameAttribute = [[NSAttributeDescription alloc] init];
            [nameAttribute setName:@"name"];
            [nameAttribute setAttributeType:NSStringAttributeType];
            [nameAttribute setOptional:NO];
            [playlistTrackProperties addObject:nameAttribute];

            NSAttributeDescription *albumNameAttribute = [[NSAttributeDescription alloc] init];
            [albumNameAttribute setName:@"albumName"];
            [albumNameAttribute setAttributeType:NSStringAttributeType];
            [albumNameAttribute setOptional:NO];
            [playlistTrackProperties addObject:albumNameAttribute];

            NSAttributeDescription *artistNameAttribute = [[NSAttributeDescription alloc] init];
            [artistNameAttribute setName:@"artistName"];
            [artistNameAttribute setAttributeType:NSStringAttributeType];
            [artistNameAttribute setOptional:NO];
            [playlistTrackProperties addObject:artistNameAttribute];
            
            NSAttributeDescription *lengthAttribute = [[NSAttributeDescription alloc] init];
            [lengthAttribute setName:@"length"];
            [lengthAttribute setAttributeType:NSInteger32AttributeType];
            [lengthAttribute setOptional:YES];
            [playlistTrackProperties addObject:lengthAttribute];

            NSAttributeDescription *attributesAttribute = [[NSAttributeDescription alloc] init];
            [attributesAttribute setName:@"attributes"];
            [attributesAttribute setAttributeType:NSUndefinedAttributeType];
            [attributesAttribute setTransient:YES];
            [playlistTrackProperties addObject:attributesAttribute];

            NSRelationshipDescription *playlistRelation = [[NSRelationshipDescription alloc] init];
            [playlistRelation setName:@"playlist"];
            [playlistRelation setDestinationEntity:playlistEntity];
            [playlistRelation setMaxCount:1];
            [playlistRelation setMinCount:1];
            [playlistTrackProperties addObject:playlistRelation];

        }
        [playlistTrackEntity setProperties:playlistTrackProperties];
        [entities addObject:playlistTrackEntity];
    }

    { // Playlist
        [playlistEntity setName:@"playlist"];
        [playlistEntity setManagedObjectClassName:@"Playlist"];
        NSMutableArray *playlistProperties = [[NSMutableArray alloc] init];
        { // playlistProperties properties
            NSAttributeDescription *nameAttribute = [[NSAttributeDescription alloc] init];
            [nameAttribute setName:@"name"];
            [nameAttribute setAttributeType:NSStringAttributeType];
            [nameAttribute setOptional:NO];
            [playlistProperties addObject:nameAttribute];

            NSRelationshipDescription *tracksRelation = [[NSRelationshipDescription alloc] init];
            [tracksRelation setName:@"tracks"];
            [tracksRelation setDestinationEntity:playlistTrackEntity];
            [tracksRelation setMinCount:0];
            [playlistProperties addObject:tracksRelation];
            
            NSAttributeDescription *indexAttribute = [[NSAttributeDescription alloc] init];
            [indexAttribute setName:@"index"];
            [indexAttribute setAttributeType:NSInteger32AttributeType];
            [indexAttribute setOptional:NO];
            [playlistProperties addObject:indexAttribute];
        }
        [playlistEntity setProperties:playlistProperties];
        [entities addObject:playlistEntity];
    }

    [[[playlistEntity relationshipsByName] objectForKey:@"tracks"] setInverseRelationship:[[playlistTrackEntity relationshipsByName] objectForKey:@"playlist"]];
    [[[playlistTrackEntity relationshipsByName] objectForKey:@"playlist"] setInverseRelationship:[[playlistEntity relationshipsByName] objectForKey:@"tracks"]];

    [mom setEntities:entities];
    return mom;
}


@end
