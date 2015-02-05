//
//  Artist.h
//  dokibox
//
//  Created by Miles Wu on 10/02/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "common.h"

@interface LibraryArtist : NSManagedObject

-(NSSet*)tracksFromSet:(NSSet *)set;
-(NSSet*)albumsFromSet:(NSSet *)set;

-(void)pruneDueToAlbumBeingDeleted:(LibraryAlbum *)album;

@property (nonatomic) NSString *name;
@property (readonly, nonatomic) NSSet* albums;
@property (readonly, nonatomic) NSSet* tracks;

@end
