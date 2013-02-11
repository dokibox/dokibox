//
//  Track.h
//  fb2kmac
//
//  Created by Miles Wu on 10/02/2013.
//
//

#import <CoreData/CoreData.h>
#import "common.h"

@interface Track : NSManagedObject

-(void)setArtistByName:(NSString *)artistName andAlbumByName:(NSString *)albumName;

@property (nonatomic) NSString *filename;
@property (nonatomic) NSString *name;
@property (nonatomic) NSMutableDictionary *primitiveAttributes;
@property (nonatomic) Album *album;
@property (readonly, nonatomic) NSMutableDictionary *attributes;

@end
