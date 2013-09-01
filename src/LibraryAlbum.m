//
//  Album.m
//  dokibox
//
//  Created by Miles Wu on 10/02/2013.
//
//

#import "LibraryAlbum.h"
#import "LibraryArtist.h"
#import "LibraryTrack.h"
#import "CoreDataManager.h"

@implementation LibraryAlbum
@dynamic name;
@dynamic artist;
@dynamic tracks;

-(NSSet*)tracksFromSet:(NSSet *)set
{
    if([set member:self] || [set member:[self artist]]) // when itself or parent artist is the match, return all
        return [self tracks];
    else {
        NSMutableSet *retval = [[NSMutableSet alloc] initWithSet:[self tracks]];
        [retval intersectSet:set];
        return retval;
    }
}

-(void)setArtistByName:(NSString *)artistName
{
    NSError *error;
    LibraryArtist *artist;

    if([self artist]) { //prune old one
        [[self artist] pruneDueToAlbumBeingDeleted:self];
    }

    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"artist"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", artistName];
    [fr setPredicate:predicate];

    NSArray *results = [[self managedObjectContext] executeFetchRequest:fr error:&error];
    if(results == nil) {
        NSLog(@"error fetching results");
    }
    else if([results count] == 0) {
        artist = [NSEntityDescription insertNewObjectForEntityForName:@"artist" inManagedObjectContext:[self managedObjectContext]];
        [artist setName:artistName];
    }
    else { //already exists in library
        artist = [results objectAtIndex:0];
    }

    [self setArtist:artist];
}

-(void)pruneDueToTrackBeingDeleted:(LibraryTrack *)track;
{
    if([[self tracks] count] == 1) {
        LibraryTrack *lastTrack = [[[self tracks] allObjects] objectAtIndex:0];
        if([[lastTrack objectID] isEqual:[track objectID]]) {
            [[self managedObjectContext] deleteObject:self];
        }
    }
}

-(void)prepareForDeletion
{
    [[self artist] pruneDueToAlbumBeingDeleted:self];
}

@end
