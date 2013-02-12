//
//  Album.h
//  fb2kmac
//
//  Created by Miles Wu on 10/02/2013.
//
//

#import <CoreData/CoreData.h>
#import "common.h"

@interface Album : NSManagedObject

-(void)setArtistByName:(NSString *)artistName;

@property (nonatomic) NSString *name;
@property (nonatomic) Artist *artist;
@property (nonatomic) NSSet* tracks;


@end
