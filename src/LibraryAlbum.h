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
    NSImage *_cover;
    dispatch_queue_t _coverFetchQueue;
}

-(NSSet*)tracksFromSet:(NSSet *)set;
-(NSImage*)cover;
-(void)fetchCoverAsync:(void (^) ())blockWhenFinished;

-(void)setArtistByName:(NSString *)artistName;
-(void)pruneDueToTrackBeingDeleted:(LibraryTrack *)track;

@property (nonatomic) NSString *name;
@property (nonatomic) LibraryArtist *artist;
@property (nonatomic) NSSet* tracks;

@property (readonly) BOOL isCoverFetched;


@end
