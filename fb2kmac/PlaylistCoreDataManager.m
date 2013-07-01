//
//  PlaylistCoreDataManager.m
//  fb2kmac
//
//  Created by Miles Wu on 30/06/2013.
//
//

#import "PlaylistCoreDataManager.h"

@implementation PlaylistCoreDataManager

SHAREDINSTANCE

-(id)init
{
    if(self = [super initWithFilename:@"playlists.sql" andModel:[self model]]) {
    }
    return self;
}

-(NSManagedObjectModel*)model
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
            
            NSAttributeDescription *attributesAttribute = [[NSAttributeDescription alloc] init];
            [attributesAttribute setName:@"attributes"];
            [attributesAttribute setAttributeType:NSUndefinedAttributeType];
            [attributesAttribute setTransient:YES];
            [playlistTrackProperties addObject:attributesAttribute];
            
            NSRelationshipDescription *playlistRelation = [[NSRelationshipDescription alloc] init];
            [playlistRelation setName:@"playlist"];
            [playlistRelation setDestinationEntity:playlistEntity];
            //[playlistRelation setMaxCount:1];
            //[playlistRelation setMinCount:1];
            //[albumRelation setOptional:NO];
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
            [tracksRelation setOrdered:YES];
            [playlistProperties addObject:tracksRelation];
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
