//
//  Artist.m
//  dokibox
//
//  Created by Miles Wu on 10/02/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
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

-(NSSet*)tracksFromSet:(NSSet *)set
{
    if([set member:self]) // when itself is the match, return all
        return [self tracks];
    else {
        NSMutableSet *retval = [[NSMutableSet alloc] init];
        for(LibraryAlbum *album in [self albums]) {
            [retval addObjectsFromArray:[[album tracksFromSet:set] allObjects]];
        }
        return retval;
    }
}


-(NSSet*)albumsFromSet:(NSSet *)set
{
    if([set member:self]) // when itself is the match, return all
        return [self albums];
    else {
        NSMutableSet *retval = [[NSMutableSet alloc] init];
        for(LibraryAlbum *album in [self albums]) {
            if([[album tracksFromSet:set] count] != 0) {
                [retval addObject:album];
            }
        }
        return retval;
    }
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
