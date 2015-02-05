//
//  Playlist.h
//  dokibox
//
//  Created by Miles Wu on 28/07/2012.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PlaylistTrack.h"
#import "OrderedManagedObject.h"

@interface Playlist : NSManagedObject<OrderedManagedObject> {
    BOOL _shuffle;
    NSMutableArray *_shuffleNotPlayedYetTracks;
    NSMutableArray *_shuffleHistory;
    NSInteger _shuffleHistoryIndex;
}

-(NSUInteger)numberOfTracks;
-(NSUInteger)getTrackIndex:(PlaylistTrack *)track;
-(PlaylistTrack *)trackAtIndex:(NSUInteger)index;
-(NSArray*)sortedTracks;
-(PlaylistTrack *)currentlyActiveTrack;

-(void)removeTrackAtIndex:(NSUInteger)index;
-(void)removeTrack:(PlaylistTrack *)track;
-(void)removeAllTracks;

-(void)insertTrackWithFilename:(NSString *)filename atIndex:(NSUInteger)index;
-(void)insertTrack:(PlaylistTrack *)track atIndex:(NSUInteger)index;
-(void)addTrackWithFilename:(NSString *)filename;
-(void)addTrack:(PlaylistTrack *)track;
-(void)addTrackToShuffleList:(PlaylistTrack *)track;

-(void)playTrackAtIndex:(NSUInteger)index;
-(void)playNextTrackAfter:(PlaylistTrack *)trackJustEnded;
-(void)playPrevTrackBefore:(PlaylistTrack *)trackJustEnded;
-(void)save;

@property (nonatomic) NSString *name;
@property (nonatomic) NSSet* tracks;
@property BOOL repeat;
@property BOOL shuffle;

@end