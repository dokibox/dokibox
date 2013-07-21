//
//  Playlist.h
//  dokibox
//
//  Created by Miles Wu on 28/07/2012.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PlaylistTrack.h"

@interface Playlist : NSManagedObject {
}

-(NSUInteger)numberOfTracks;
-(NSUInteger)getTrackIndex:(PlaylistTrack *)track;
-(PlaylistTrack *)trackAtIndex:(NSUInteger)index;
-(void)removeTrackAtIndex:(NSUInteger)index;
-(void)insertTrack:(PlaylistTrack *)track atIndex:(NSUInteger)index;
-(void)addTrack:(PlaylistTrack *)track;
-(void)playTrackAtIndex:(NSUInteger)index;
-(void)receivedTrackEndedNotification:(NSNotification *)notification;
-(void)save;

@property (nonatomic) NSString *name;
@property (nonatomic) NSMutableOrderedSet* tracks;

@end