//
//  Album.m
//  fb2kmac
//
//  Created by Miles Wu on 10/02/2013.
//
//

#import "Album.h"
#import "Artist.h"
#import "CoreDataManager.h"

@implementation Album
@dynamic name;
@dynamic artist;
@dynamic tracks;

-(void)setArtistByName:(NSString *)artistName
{
    NSError *error;
    Artist *artist;
    CoreDataManager *cdm = [CoreDataManager sharedInstance];
    
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"artist"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE %@", artistName];
    [fr setPredicate:predicate];
    
    NSArray *results = [[cdm context] executeFetchRequest:fr error:&error];
    if(results == nil) {
        NSLog(@"error fetching results");
    }
    else if([results count] == 0) {
        artist = [NSEntityDescription insertNewObjectForEntityForName:@"artist" inManagedObjectContext:[cdm context]];
        [artist setName:artistName];
    }
    else { //already exists in library
        artist = [results objectAtIndex:0];
    }
    
    [self setArtist:artist];
}

@end
