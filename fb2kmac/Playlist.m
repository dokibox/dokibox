//
//  Playlist.m
//  fb2kmac
//
//  Created by Miles Wu on 28/07/2012.
//
//

#import "Playlist.h"

@implementation Playlist

-(id)init {
    if((self = [super init])) {
        _tracks = [NSMutableArray array];
    }
    return self;
}

-(NSUInteger)numberOfTracks {
    return [_tracks count];
}

-(NSUInteger)getTrackIndex:(PlaylistTrack *)track {
    return [_tracks indexOfObject:track];
}

-(PlaylistTrack *)trackAtIndex:(NSUInteger)index {
    return [_tracks objectAtIndex:index];
}

-(void)removeTrackAtIndex:(NSUInteger)index {
    [_tracks removeObjectAtIndex:index];
}

-(void)insertTrack:(PlaylistTrack *)track atIndex:(NSUInteger)index {
    [_tracks insertObject:track atIndex:index];
}

-(void)addTrack:(PlaylistTrack *)track {
    [_tracks addObject:track];
}

-(void)playTrackAtIndex:(NSUInteger)index {
    PlaylistTrack *track = [self trackAtIndex:index];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedTrackEndedNotification:) name:@"trackEnded" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playTrack" object:track];
    
}

-(void)receivedTrackEndedNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"trackEnded" object:nil];
    
    if([notification object] != nil) {
        PlaylistTrack *trackJustEnded = [notification object];
        NSUInteger index = [_tracks indexOfObject:trackJustEnded];
        if(index != NSNotFound && index != [self numberOfTracks]-1) {
            index += 1;
            [self playTrackAtIndex:index];
        }
    }
}

@end
