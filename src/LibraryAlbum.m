//
//  Album.m
//  dokibox
//
//  Created by Miles Wu on 10/02/2013.
//
//

#import "LibraryAlbum.h"
#import "LibraryArtist.h"
#import "LibraryTrack.h"
#import "LibraryCoreDataManager.h"
#import "NSManagedObjectContext+Helpers.h"

@implementation LibraryAlbum
@dynamic name;
@dynamic artist;
@dynamic tracks;

@synthesize isCoverFetched = _isCoverFetched;

-(void)awakeFromFetch
{
    // NB. Core data lies. This is not always called immediately upon fetch. It can occur later, upon access of properties.
    [self setupSelfObserver];
}

- (void)awakeFromInsert
{
    [self setupSelfObserver];
}

-(void)setupSelfObserver
{
    // Observe ourself for changes to tracks, so we can inform parent artist that track count has changed
    _isSelfObserverSetup = YES; // keep track
    [self addObserver:self forKeyPath:@"tracks" options:NULL context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"tracks"]) {
        if([self artist]) { // Inform parent artist that track count has changed
            [[self artist] willChangeValueForKey:@"tracks"];
            [[self artist] didChangeValueForKey:@"tracks"];
        }
    }
}


-(void)didTurnIntoFault
{
    // prevent error from removing if it was never setup (this can happen if awakeFromFetch: was never called, see note there)
    if(_isSelfObserverSetup == YES) {
        [self removeObserver:self forKeyPath:@"tracks"];
        _isSelfObserverSetup = NO;
    }
    
    if(_coverFetchQueue) {
        dispatch_release(_coverFetchQueue);
        _coverFetchQueue = nil;
    }
}

-(NSSet*)tracksFromSet:(NSSet *)set
{
    if([set member:self] || [set member:[self artist]]) // when itself or parent artist is the match, return all
        return [self tracks];
    else {
        NSMutableSet *retval = [[NSMutableSet alloc] initWithSet:[self tracks]];
        [retval intersectSet:set];
        return retval;
    }
}

-(void)setArtistByName:(NSString *)artistName
{
    NSError *error;
    LibraryArtist *artist;
    LibraryArtist *oldArtist = [self artist];

    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"artist"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", artistName];
    [fr setPredicate:predicate];

    NSArray *results = [[self managedObjectContext] executeFetchRequest:fr error:&error];
    if(results == nil) {
        DDLogError(@"error fetching results");
    }
    else if([results count] == 0) {
        artist = [NSEntityDescription insertNewObjectForEntityForName:@"artist" inManagedObjectContext:[self managedObjectContext]];
        [artist setName:artistName];
    }
    else { //already exists in library
        artist = [results objectAtIndex:0];
    }
    
    if(oldArtist != artist) { //prune old one
        [[self artist] pruneDueToAlbumBeingDeleted:self];
    }

    [self setArtist:artist];
}

-(void)pruneDueToTrackBeingDeleted:(LibraryTrack *)track;
{
    if([[self tracks] count] == 1) {
        LibraryTrack *lastTrack = [[[self tracks] allObjects] objectAtIndex:0];
        if([[lastTrack objectID] isEqual:[track objectID]]) {
            [[self managedObjectContext] deleteObject:self];
        }
    }
}

-(void)prepareForDeletion
{
    [[self artist] pruneDueToAlbumBeingDeleted:self];
}

-(NSImage*)cover
{
    if(_isCoverFetched == NO) {
        // Look for directory first
        NSMutableSet *trackDirs = [[NSMutableSet alloc] init];
        for(LibraryTrack *t in [self tracks]) {
            NSString *s = [[t filename] substringToIndex:[[t filename] length] - [[[t filename] lastPathComponent] length]];
            [trackDirs addObject:s];
        }
        if([trackDirs count] == 1) { // all tracks belong in one folder
            NSError *error;
            NSFileManager *fm = [NSFileManager defaultManager];
            NSString *dir = [[trackDirs allObjects] objectAtIndex:0];
            
            NSArray *files = [fm contentsOfDirectoryAtPath:dir error:&error];
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF LIKE[c] %@ OR SELF LIKE[c] %@", @"cover.jpg", @"folder.jpg"];
            NSArray *possible = [files filteredArrayUsingPredicate:pred];
            if([possible count] >= 1) {
                NSString *coverlocation = [NSString stringWithFormat:@"%@/%@", dir, [possible objectAtIndex:0]];
                _cover = [[NSImage alloc] initWithContentsOfFile:coverlocation];
                _isCoverFetched = YES;
                return _cover;
            }
        }
        
        // Now try the track tags
        if([[self tracks] count] > 0) {
            LibraryTrack *t = [[[self tracks] allObjects] objectAtIndex:0];
            NSImage *cover = [t cover];
            if(cover) {
                _cover = cover;
                _isCoverFetched = YES;
                return _cover;
            }
        }

    }
    return _cover;
}

-(void)fetchCoverAsync:(void (^) (LibraryAlbum *album))blockWhenFinished
{
    if(_isCoverFetched) {
        blockWhenFinished(self);
        return;
    }
    
    dispatch_queue_t calling_q = dispatch_get_current_queue();
    if(_coverFetchQueue == nil)
        //serial queue so we never try to fetch a cover multiple times simultanousely
        _coverFetchQueue = dispatch_queue_create(NULL, NULL);
    
    NSManagedObjectID *self_id = [self objectID];
    
    dispatch_async(_coverFetchQueue, ^{
        if(_isCoverFetched == YES) { // could have been queued before we had a cover, but now we have it: so no need to fetch
            dispatch_async(calling_q, ^{ // call block on original queue
                blockWhenFinished(self);
            });
            return;
        }        
        
        NSManagedObjectContext *context = [[self managedObjectContext] newContext];
        LibraryAlbum *album = (LibraryAlbum*)[context objectWithID:self_id];
        NSImage *cover = [album cover];

        _isCoverFetched = YES;
        _cover = cover;
        
        dispatch_sync(calling_q, ^{ // call block on original queue
            blockWhenFinished(self);
        });
    });
}

@end
