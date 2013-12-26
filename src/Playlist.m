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
    [[self managedObjectContext] deleteObject:track];
}

-(void)removeTrackAtIndex:(NSUInteger)index
{
    PlaylistTrack *t = [self trackAtIndex:index];
    if(_shuffleNotPlayedYetTracks) {
        [_shuffleNotPlayedYetTracks removeObject:t];
    }
    [[self managedObjectContext] deleteObject:t];
}

-(void)insertTrackWithFilename:(NSString *)filename atIndex:(NSUInteger)index onCompletion:(void (^)(void)) completionHandler
{
    dispatch_queue_t queue = dispatch_queue_create(NULL, NULL);
    NSManagedObjectID *playlistID = [self objectID];
    NSPersistentStoreCoordinator *store = [[self managedObjectContext] persistentStoreCoordinator];
    
    dispatch_async(queue, ^() {
        NSError *err;
        NSManagedObjectContext *c = [[NSManagedObjectContext alloc] init];
        [c setPersistentStoreCoordinator:store];
        Playlist *p = (Playlist *)[c objectWithID:playlistID];
        
        PlaylistTrack *t = [PlaylistTrack trackWithFilename:filename inContext:c];
        [p insertTrack:t atIndex:index];
        [c save:&err];
        NSManagedObjectID *tID = [t objectID];
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            PlaylistTrack *tMain = (PlaylistTrack *)[[self managedObjectContext] objectWithID:tID];
            [self insertTrack:tMain atIndex:index]; //add again (this does not duplicate) so that _shuffle stuff is populated for main thread instance
            completionHandler();
        });
    });
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
    if(_shuffleNotPlayedYetTracks)
        [_shuffleNotPlayedYetTracks addObject:track];
}

-(void)addTrackWithFilename:(NSString *)filename onCompletion:(void (^)(void)) completionHandler
{
    dispatch_queue_t queue = dispatch_queue_create(NULL, NULL);
    NSManagedObjectID *playlistID = [self objectID];
    NSPersistentStoreCoordinator *store = [[self managedObjectContext] persistentStoreCoordinator];
    
    dispatch_async(queue, ^() {
        NSError *err;
        NSManagedObjectContext *c = [[NSManagedObjectContext alloc] init];
        [c setPersistentStoreCoordinator:store];
        Playlist *p = (Playlist *)[c objectWithID:playlistID];
        
        PlaylistTrack *t = [PlaylistTrack trackWithFilename:filename inContext:c];
        [p addTrack:t];
        [c save:&err];
        NSManagedObjectID *tID = [t objectID];
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            PlaylistTrack *tMain = (PlaylistTrack *)[[self managedObjectContext] objectWithID:tID];
            [self addTrack:tMain]; //add again (this does not duplicate) so that _shuffle stuff is populated for main thread instance
            completionHandler();
        });
    });
}

-(void)addTrack:(PlaylistTrack *)track
{
    [track setPlaylist:self];
    [track setIndex:[NSNumber numberWithInteger:[[self tracks] count]]];
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
        [self setShuffle:YES]; //remake _shuffleNotPlayedYetTracks
        [_shuffleNotPlayedYetTracks removeObject:track];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playTrack" object:track];
}

-(void)playNextTrackAfter:(PlaylistTrack *)trackJustEnded {
    if(_shuffle == YES) {
        if([_shuffleNotPlayedYetTracks count] == 0 && _repeat == YES) { //repeat
            [self setShuffle:YES]; //remake _shuffleNotPlayedYetTracks
            [_shuffleNotPlayedYetTracks removeObject:trackJustEnded]; // prevent double play
        }
        else if([_shuffleNotPlayedYetTracks count] == 0 && _repeat == NO) { //no more tracks to play
            return;
        }
        
        PlaylistTrack *nextTrack = [_shuffleNotPlayedYetTracks objectAtIndex:arc4random_uniform((int)[_shuffleNotPlayedYetTracks count])];
        [_shuffleNotPlayedYetTracks removeObject:nextTrack];
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
        
        //remove current playing one (if it exists)
        if([self currentlyActiveTrack]) {
            [_shuffleNotPlayedYetTracks removeObject:[self currentlyActiveTrack]];
        }
    }
    else {
        _shuffleNotPlayedYetTracks = nil;
    }
}

@end
