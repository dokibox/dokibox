//
//  Playlist.h
//  fb2kmac
//
//  Created by Miles Wu on 28/07/2012.
//
//

#import <Foundation/Foundation.h>
#import "PlaylistTrack.h"

@interface Playlist : NSObject {
    NSMutableArray *_tracks;
}

-(NSUInteger)numberOfTracks;
-(NSUInteger)getTrackIndex:(PlaylistTrack *)track;
-(PlaylistTrack *)trackAtIndex:(NSUInteger)index;
-(void)removeTrackAtIndex:(NSUInteger)index;
-(void)insertTrack:(PlaylistTrack *)track atIndex:(NSUInteger)index;
-(void)addTrack:(PlaylistTrack *)track;
-(void)playTrackAtIndex:(NSUInteger)index;
-(void)receivedTrackEndedNotification:(NSNotification *)notification;

@end