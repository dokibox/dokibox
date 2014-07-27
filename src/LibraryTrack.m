//
//  Track.m
//  dokibox
//
//  Created by Miles Wu on 10/02/2013.
//
//

#import "LibraryTrack.h"
#import "LibraryArtist.h"
#import "LibraryAlbum.h"
#import "CoreDataManager.h"

@implementation LibraryTrack
@dynamic album;
@dynamic trackArtistName;
@dynamic trackNumber;
@dynamic length;

+(LibraryTrack *)trackWithFilename:(NSString *)filename inContext:(NSManagedObjectContext *)objectContext
{
    LibraryTrack *t = [NSEntityDescription insertNewObjectForEntityForName:@"track" inManagedObjectContext:objectContext];
    [t setFilename:filename];
    
    BOOL retval = [t updateFromFile];
    if(retval == NO) { // delete if we weren't able to update
        [objectContext deleteObject:t];
        return nil;
    }
    
    return t;
}

-(BOOL)updateFromFile
// return value is YES for success. NO for failure.
{
    [self resetAttributeCache]; //reset any previously loaded attributes/tags
    
    if([self attributes] == nil) { // failure in loading tags (perhaps IO error)
        DDLogWarn(@"Failure in updateFromFile: (not able to load tags) for %@", [self filename]);
        return NO;
    }
    
    [self setName:([[self attributes] objectForKey:@"TITLE"] ? [[self attributes] objectForKey:@"TITLE"] : @"")];
    [self setLength:[[self attributes] objectForKey:@"length"]];

    // Artist name
    NSString *albumArtistName;
    if([[self attributes] objectForKey:@"ALBUMARTIST"]) { //ALBUMARTIST tag exists
        albumArtistName = [[self attributes] objectForKey:@"ALBUMARTIST"];
        if([[self attributes] objectForKey:@"ARTIST"] && ![[[self attributes] objectForKey:@"ARTIST"] isEqualTo:albumArtistName]) { // if ARTIST && ARTIST!=ALBUMARTIST, set the track artist
            [self setTrackArtistName:[[self attributes] objectForKey:@"ARTIST"]];
        }
    }
    else if([[self attributes] objectForKey:@"ARTIST"]) { // Only ARTIST tag
        albumArtistName = [[self attributes] objectForKey:@"ARTIST"];
    }
    else { // No ALBUMARTIST or ARTIST tag. Use empty string
        albumArtistName = @"";
    }
    
    [self setAlbumArtistByName:albumArtistName andAlbumByName:([[self attributes] objectForKey:@"ALBUM"] ? [[self attributes] objectForKey:@"ALBUM"] : @"")];
    
    // Track number tag is a string that is either "tracknum" or "tracknum/totaltracks", so we need to split by "/", take the first component only and convert it to an integer
    NSString *trackNumberString = [[[[self attributes] objectForKey:@"TRACKNUMBER"] componentsSeparatedByString:@"/"] objectAtIndex:0];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [self setTrackNumber:[numberFormatter numberFromString:trackNumberString]];
    
    // Reset needsUpdate flag
    [super updateFromFile];
    return YES;
}

-(void)didTurnIntoFault {
    //NSLog(@"hi turned into fault");
    [super didTurnIntoFault];
}

-(void)setAlbumArtistByName:(NSString *)albumArtistName andAlbumByName:(NSString *)albumName;
{
    NSError *error;
    LibraryAlbum *album;
    LibraryAlbum *oldAlbum = [self album];

    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"album"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name == %@) AND (artist.name == %@)", albumName, albumArtistName];
    [fr setPredicate:predicate];

    NSArray *results = [[self managedObjectContext] executeFetchRequest:fr error:&error];
    if(results == nil) {
        NSLog(@"error fetching results");
    }
    else if([results count] == 0) {
        album = [NSEntityDescription insertNewObjectForEntityForName:@"album" inManagedObjectContext:[self managedObjectContext]];
        [album setName:albumName];
        [album setArtistByName:albumArtistName];
    }
    else { //already exists in library
        album = [results objectAtIndex:0];
    }
    
    if(oldAlbum != album) { //prune old one
        [oldAlbum pruneDueToTrackBeingDeleted:self];
    }

    [self setAlbum:album];
}

-(void)prepareForDeletion
{
    [[self album] pruneDueToTrackBeingDeleted:self];
}



@end
