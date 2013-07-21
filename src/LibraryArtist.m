//
//  Artist.m
//  dokibox
//
//  Created by Miles Wu on 10/02/2013.
//
//

#import "LibraryArtist.h"
#import "LibraryAlbum.h"

@implementation LibraryArtist
@dynamic name;
@dynamic albums;

-(NSSet*)tracks
{
    // NB: This can probably be sped up if you use a batch fetch or something complicated!
    NSMutableSet *set = [[NSMutableSet alloc] init];
    for(LibraryAlbum *album in [self albums]) {
        [set addObjectsFromArray:[[album tracks] allObjects]];
    }
    return set;
}

-(void)pruneDueToAlbumBeingDeleted:(LibraryAlbum *)album
{
    if([[self albums] count] == 1) {
        LibraryAlbum *lastAlbum = [[[self albums] allObjects] objectAtIndex:0];
        if([[lastAlbum objectID] isEqual:[album objectID]]) {
            [[self managedObjectContext] deleteObject:self];
        }
    }

}


@end
