//
//  Track.h
//  fb2kmac
//
//  Created by Miles Wu on 10/02/2013.
//
//

#import <CoreData/CoreData.h>
#import "common.h"

@interface LibraryTrack : NSManagedObject

-(void)setArtistByName:(NSString *)artistName andAlbumByName:(NSString *)albumName;
-(void)resetAttributeCache;

@property (nonatomic) NSString *filename;
@property (nonatomic) NSString *name;
@property (nonatomic) NSMutableDictionary *primitiveAttributes;
@property (nonatomic) LibraryAlbum *album;
@property (readonly, nonatomic) NSMutableDictionary *attributes;
@property (readonly, nonatomic) NSSet* tracks;

@end
