//
//  Track.h
//  dokibox
//
//  Created by Miles Wu on 10/02/2013.
//
//

#import <CoreData/CoreData.h>
#import "common.h"
#import "ManagedObjectTrack.h"

@interface LibraryTrack : ManagedObjectTrack

-(void)setArtistByName:(NSString *)artistName andAlbumByName:(NSString *)albumName;


@property (nonatomic) LibraryAlbum *album;
@property (nonatomic) NSNumber *trackNumber;
@property NSNumber *length;

@end
