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

@end
