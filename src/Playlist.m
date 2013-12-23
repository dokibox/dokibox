//
//  Playlist.m
//  dokibox
//
//  Created by Miles Wu on 28/07/2012.
//
//

#import "Playlist.h"
#import "MusicController.h"

@implementation Playlist

@dynamic name;
@dynamic tracks;
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

-(void)removeTrack:(PlaylistTrack *)track
{
    [[self managedObjectContext] deleteObject:track];
}

-(void)removeTrackAtIndex:(NSUInteger)index
{
    PlaylistTrack *t = [self trackAtIndex:index];
    [[self managedObjectContext] deleteObject:t];
}

-(void)insertTrackWithFilename:(NSString *)filename atIndex:(NSUInteger)index
{
    PlaylistTrack *t = [PlaylistTrack trackWithFilename:filename inContext:[self managedObjectContext]];
    [self insertTrack:t atIndex:index];
}

-(void)insertTrack:(PlaylistTrack *)track atIndex:(NSUInteger)index
{
    NSAssert(index <= [[self tracks] count], @"Index for Playlist insertTrack:atIndex: out of bound");
    
    NSArray *sortedTracks = [self sortedTracks];
    BOOL seenTrackToBeInserted = false;
    for(NSUInteger i=0; i<[sortedTracks count]; i++) {
        PlaylistTrack *t = [sortedTracks objectAtIndex:i];
        if([t isEqual:track]) {
            // this allows tracks to be swapped using the insertTrack:atIndex: function
            // where we don't count the actual track as it will be assigned a new index in the gap
            seenTrackToBeInserted = true;
            continue;
        }
        
        if(i < index)
            [t setIndex:[NSNumber numberWithInteger: (seenTrackToBeInserted == false ? i : i-1)]];
        else
            [t setIndex:[NSNumber numberWithInteger: (seenTrackToBeInserted == false ? i+1 : i)]]; // +1 to leave a gap
    }
    
    [track setPlaylist:self];
    [track setIndex:[NSNumber numberWithInteger:index]];
}

-(void)addTrackWithFilename:(NSString *)filename
{
    PlaylistTrack *t = [PlaylistTrack trackWithFilename:filename inContext:[self managedObjectContext]];
    [self addTrack:t];
}

-(void)addTrack:(PlaylistTrack *)track
{
    [track setPlaylist:self];
    [track setIndex:[NSNumber numberWithInteger:[[self tracks] count]]];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playTrack" object:track];

}

-(void)playNextTrackAfter:(PlaylistTrack *)trackJustEnded {
    NSUInteger index = [[self sortedTracks] indexOfObject:trackJustEnded];
    if(index != NSNotFound && index != [self numberOfTracks]-1) {
        index += 1;
        [self playTrackAtIndex:index];
    }
    else if(index == [self numberOfTracks]-1 && _repeat == YES) {
        [self playTrackAtIndex:0];
    }
}

@end
