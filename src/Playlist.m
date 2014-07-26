//
//  Playlist.m
//  dokibox
//
//  Created by Miles Wu on 28/07/2012.
//
//

#import "Playlist.h"
#import "MusicController.h"
#import "PlaylistTrack.h"

@implementation Playlist

@dynamic name;
@dynamic tracks;
@dynamic index;
@synthesize repeat = _repeat;

-(NSUInteger)numberOfTracks {
    return [[self tracks] count];
}

-(NSArray*)sortedTracks { // maybe cache this for performance?
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sorted = [[self tracks] sortedArrayUsingDescriptors:sortDescriptors];
    return sorted;
}

-(NSUInteger)getTrackIndex:(PlaylistTrack *)track {
    return [[self sortedTracks] indexOfObject:track];
}

-(PlaylistTrack *)trackAtIndex:(NSUInteger)index {
    return [[self sortedTracks] objectAtIndex:index];
}

-(PlaylistTrack *)currentlyActiveTrack
{
    for(PlaylistTrack *t in [self sortedTracks]) {
        if([t playbackStatus] == MusicControllerPlaying || [t playbackStatus] == MusicControllerPaused) {
            return t;
        }
    }
    return nil;
}

-(void)removeTrack:(PlaylistTrack *)track
{
    if(_shuffleNotPlayedYetTracks) {
        [_shuffleNotPlayedYetTracks removeObject:track];
    }
    
    NSUInteger index = [[track index] integerValue];
    for(NSUInteger i=index+1; i<[[self sortedTracks] count]; i++) {
        PlaylistTrack *t = [[self sortedTracks] objectAtIndex:i];
        [t setIndex:[NSNumber numberWithInteger:i-1]];
    }
    
    [track setPlaylist:nil];
    if([track playbackStatus] == MusicControllerStopped) {
        // Only delete if it's not currently being played, otherwise it'll crash as it tries to access data about the track
        // If it is being played, leave as an orphan (no playlist) and it'll be deleted later
        [[self managedObjectContext] deleteObject:track];
    }
}

-(void)removeTrackAtIndex:(NSUInteger)index
{
    PlaylistTrack *t = [self trackAtIndex:index];
    [self removeTrack:t];
}

-(void)insertTrackWithFilename:(NSString *)filename atIndex:(NSUInteger)index
{ // This can take a long time and block, so be warned.
    PlaylistTrack *t = [PlaylistTrack trackWithFilename:filename inContext:[self managedObjectContext]];
    if(t == nil) {
        DDLogError(@"Failure to insertTrackWithFilename: %@", filename);
        return;
    }
    [self insertTrack:t atIndex:index];
}

-(void)insertTrack:(PlaylistTrack *)track atIndex:(NSUInteger)index
{
    NSAssert(index <= [[self tracks] count], @"Index for Playlist insertTrack:atIndex: out of bound");
    
    NSArray *sortedTracks = [self sortedTracks];
    NSUInteger i = 0;
    
    for(PlaylistTrack *t in sortedTracks) {
        if([t isEqual:track]) { // This skips over the track we are trying to insert as we set the index later
            continue;
        }
        
        if(i == index) i++; // This leaves the gap for the track to insert
        
        [t setIndex:[NSNumber numberWithInteger:i]];
        i++;
    }

    [track setPlaylist:self];
    [track setIndex:[NSNumber numberWithInteger:index]];
    [self addTrackToShuffleList:track];
}

-(void)addTrackWithFilename:(NSString *)filename
{ // This can take a long time and block, so be warned.
    PlaylistTrack *t = [PlaylistTrack trackWithFilename:filename inContext:[self managedObjectContext]];
    if(t == nil) {
        DDLogError(@"Failure to insertTrackWithFilename: %@", filename);
        return;
    }
    [self addTrack:t];
}

-(void)addTrack:(PlaylistTrack *)track
{
    [track setIndex:[NSNumber numberWithInteger:[[self tracks] count]]];
    [track setPlaylist:self];
    [self addTrackToShuffleList:track];
    
}

-(void)addTrackToShuffleList:(PlaylistTrack *)track
{
    if(_shuffleNotPlayedYetTracks)
        [_shuffleNotPlayedYetTracks addObject:track];
}

-(void)save
{
    NSError *error;
    if([[self managedObjectContext] save:&error] == NO) {
        NSLog(@"error saving");
        NSLog(@"%@", [error localizedDescription]);
        for(NSError *e in [[error userInfo] objectForKey:NSDetailedErrorsKey]) {
            NSLog(@"%@", [e localizedDescription]);
        }
    }
}

-(void)playTrackAtIndex:(NSUInteger)index {
    PlaylistTrack *track = [self trackAtIndex:index];
    if(_shuffle == YES) {
        [self setShuffle:YES]; //remake _shuffleNotPlayedYetTracks and _shuffleHistory + index
        [_shuffleNotPlayedYetTracks removeObject:track];
        [_shuffleHistory addObject:track];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playTrack" object:track];
}

-(void)playNextTrackAfter:(PlaylistTrack *)trackJustEnded {
    if(_shuffle == YES) {
        PlaylistTrack *nextTrack;
        
        if(_shuffleHistoryIndex == -1 || _shuffleHistoryIndex == [_shuffleHistory count]-1) { // not in history, or at end of history
            _shuffleHistoryIndex = -1;
            if([_shuffleNotPlayedYetTracks count] == 0 && _repeat == YES) { //repeat
                [self setShuffle:YES]; //remake _shuffleNotPlayedYetTracks
                [_shuffleNotPlayedYetTracks removeObject:trackJustEnded]; // prevent double play
            }
            else if([_shuffleNotPlayedYetTracks count] == 0 && _repeat == NO) { //no more tracks to play
                return;
            }
            
            nextTrack = [_shuffleNotPlayedYetTracks objectAtIndex:arc4random_uniform((int)[_shuffleNotPlayedYetTracks count])];
            [_shuffleNotPlayedYetTracks removeObject:nextTrack];
            [_shuffleHistory addObject:nextTrack];
        }
        else {
            _shuffleHistoryIndex++;
            nextTrack = [_shuffleHistory objectAtIndex:_shuffleHistoryIndex];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"playTrack" object:nextTrack];
    }
    else {
        NSUInteger index = [[self sortedTracks] indexOfObject:trackJustEnded];
        if(index != NSNotFound && index != [self numberOfTracks]-1) {
            index += 1;
            [self playTrackAtIndex:index];
        }
        else if(index == [self numberOfTracks]-1 && _repeat == YES) {
            [self playTrackAtIndex:0];
        }
    }
}

-(void)playPrevTrackBefore:(PlaylistTrack *)trackJustEnded
{
    if(_shuffle == YES) {
        if(_shuffleHistoryIndex == -1)
            _shuffleHistoryIndex = [_shuffleHistory count] - 1;
        
        if(_shuffleHistoryIndex == 0) // at beginning now
            return;
        
        _shuffleHistoryIndex--;
        
        PlaylistTrack *nextTrack = [_shuffleHistory objectAtIndex:_shuffleHistoryIndex];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"playTrack" object:nextTrack];
    }
    else {
        NSUInteger index = [[self sortedTracks] indexOfObject:trackJustEnded];
        if(index != NSNotFound && index != 0) {
            index -= 1;
            [self playTrackAtIndex:index];
        }
        else if(index == 0 && _repeat == YES) {
            [self playTrackAtIndex:[[self sortedTracks] count]-1];
        }
    }
}

-(BOOL)shuffle
{
    return _shuffle;
}

-(void)setShuffle:(BOOL)shuffle
{
    _shuffle = shuffle;
    
    if(_shuffle == YES) {
        _shuffleNotPlayedYetTracks = [[NSMutableArray alloc] init];
        [_shuffleNotPlayedYetTracks addObjectsFromArray:[self sortedTracks]];
        
        _shuffleHistory = [[NSMutableArray alloc] init];
        _shuffleHistoryIndex = -1;
        
        //if we are currently playing something
        PlaylistTrack *t;
        if((t = [self currentlyActiveTrack])) {
            [_shuffleNotPlayedYetTracks removeObject:t]; // remove from not played
            [_shuffleHistory addObject:t]; // add to history
        }
    }
    else {
        _shuffleNotPlayedYetTracks = nil;
        _shuffleHistory = nil;
    }
}

@end
