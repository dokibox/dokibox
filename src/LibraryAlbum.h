//
//  Album.h
//  dokibox
//
//  Created by Miles Wu on 10/02/2013.
//
//

#import <CoreData/CoreData.h>
#import "common.h"

@interface LibraryAlbum : NSManagedObject {
    BOOL _isCoverFetched;
    NSImage *_cover;
}

-(NSSet*)tracksFromSet:(NSSet *)set;
-(NSImage*)cover;

-(void)setArtistByName:(NSString *)artistName;
-(void)pruneDueToTrackBeingDeleted:(LibraryTrack *)track;

@property (nonatomic) NSString *name;
@property (nonatomic) LibraryArtist *artist;
@property (nonatomic) NSSet* tracks;


@end
