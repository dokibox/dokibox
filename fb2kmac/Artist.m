//
//  Artist.m
//  fb2kmac
//
//  Created by Miles Wu on 10/02/2013.
//
//

#import "Artist.h"
#import "Album.h"

@implementation Artist
@dynamic name;
@dynamic albums;

-(NSSet*)tracks
{
    // NB: This can probably be sped up if you use a batch fetch or something complicated!
    NSMutableSet *set = [[NSMutableSet alloc] init];
    for(Album *album in [self albums]) {
        [set addObjectsFromArray:[[album tracks] allObjects]];
    }
    return set;
}

-(void)pruneDueToAlbumBeingDeleted:(Album *)album
{
    if([[self albums] count] == 1) {
        Album *lastAlbum = [[[self albums] allObjects] objectAtIndex:0];
        if([[lastAlbum objectID] isEqual:[album objectID]]) {
            [[self managedObjectContext] deleteObject:self];
        }
    }

}


@end
