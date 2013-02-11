//
//  Track.m
//  fb2kmac
//
//  Created by Miles Wu on 10/02/2013.
//
//

#import "Track.h"
#import "common.h"
#import "Artist.h"
#import "Album.h"
#import "CoreDataManager.h"

/*@synthesize attributes = _attributes;
@synthesize filename = _filename;

- (id)init {
    self = [super init];
    _attributes = [NSMutableDictionary dictionary];
    return self;
}

- (id)initWithFilename:(NSString *)filename {
    self = [self init];
    
    id<TaggerProtocol> tagger = [[TaglibTagger alloc] initWithFilename:filename];
    _attributes = [tagger tag];
    
    _filename = filename;
    
    return self;
}

@end*/


@implementation Track
@dynamic filename;
@dynamic name;
@dynamic primitiveAttributes;
@dynamic album;

-(NSMutableDictionary *)attributes
{
    [self willAccessValueForKey:@"attributes"];
    NSMutableDictionary *dict = [self primitiveAttributes];
    [self didAccessValueForKey:@"attributes"];
    if(dict == nil) {
        id<TaggerProtocol> tagger = [[TaglibTagger alloc] initWithFilename:[self filename]];
        dict = [tagger tag];
        [self setPrimitiveAttributes:dict];
    }
    return dict;
}

-(void)didTurnIntoFault {
    //NSLog(@"hi turned into fault");
    [super didTurnIntoFault];
}

-(void)setArtistByName:(NSString *)artistName andAlbumByName:(NSString *)albumName
{
    NSError *error;
    Album *album;
    CoreDataManager *cdm = [CoreDataManager sharedInstance];
    
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"album"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name LIKE %@) AND (artist.name LIKE %@)", albumName, artistName];
    [fr setPredicate:predicate];
    
    NSArray *results = [[cdm context] executeFetchRequest:fr error:&error];
    if(results == nil) {
        NSLog(@"error fetching results");
    }
    else if([results count] == 0) {
        album = [NSEntityDescription insertNewObjectForEntityForName:@"album" inManagedObjectContext:[cdm context]];
        [album setName:albumName];
        [album setArtistByName:artistName];
    }
    else { //already exists in library
        album = [results objectAtIndex:0];
    }
    
    [self setAlbum:album];
}



@end
