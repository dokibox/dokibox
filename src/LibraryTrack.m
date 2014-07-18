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
    [self setArtistByName:([[self attributes] objectForKey:@"ARTIST"] ? [[self attributes] objectForKey:@"ARTIST"] : @"") andAlbumByName:([[self attributes] objectForKey:@"ALBUM"] ? [[self attributes] objectForKey:@"ALBUM"] : @"")];
    [self setLength:[[self attributes] objectForKey:@"length"]];
    
    // Track number tag is a string that is either "tracknum" or "tracknum/totaltracks", so we need to split by "/", take the first component only and convert it to an integer
    NSString *trackNumberString = [[[[self attributes] objectForKey:@"TRACKNUMBER"] componentsSeparatedByString:@"/"] objectAtIndex:0];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [self setTrackNumber:[numberFormatter numberFromString:trackNumberString]];
    
    return YES;
}

-(void)didTurnIntoFault {
    //NSLog(@"hi turned into fault");
    [super didTurnIntoFault];
}

-(void)setArtistByName:(NSString *)artistName andAlbumByName:(NSString *)albumName
{
    NSError *error;
    LibraryAlbum *album;
    LibraryAlbum *oldAlbum = [self album];

    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"album"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name == %@) AND (artist.name == %@)", albumName, artistName];
    [fr setPredicate:predicate];

    NSArray *results = [[self managedObjectContext] executeFetchRequest:fr error:&error];
    if(results == nil) {
        NSLog(@"error fetching results");
    }
    else if([results count] == 0) {
        album = [NSEntityDescription insertNewObjectForEntityForName:@"album" inManagedObjectContext:[self managedObjectContext]];
        [album setName:albumName];
        [album setArtistByName:artistName];
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
