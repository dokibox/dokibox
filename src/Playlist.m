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
    for(NSUInteger i=0; i<[sortedTracks count]; i++) {
        PlaylistTrack *t = [sortedTracks objectAtIndex:i];
        if(i < index)
            [t setIndex:[NSNumber numberWithInteger:i]];
        else
            [t setIndex:[NSNumber numberWithInteger:i+1]]; // +1 to leave a gap
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedTrackEndedNotification:) name:@"trackEnded" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playTrack" object:track];

}

-(void)receivedTrackEndedNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"trackEnded" object:nil];

    if([notification object] != nil) {
        PlaylistTrack *trackJustEnded = [notification object];
        NSUInteger index = [[self sortedTracks] indexOfObject:trackJustEnded];
        if(index != NSNotFound && index != [self numberOfTracks]-1) {
            index += 1;
            [self playTrackAtIndex:index];
        }
    }
}

@end
