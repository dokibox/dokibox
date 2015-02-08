//
//  Track.h
//  dokibox
//
//  Created by Miles Wu on 10/02/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "common.h"
#import "ManagedObjectTrack.h"

@interface LibraryTrack : ManagedObjectTrack

+(LibraryTrack *)trackWithFilename:(NSString *)filename inContext:(NSManagedObjectContext *)objectContext;
-(void)setAlbumArtistByName:(NSString *)albumArtistName andAlbumByName:(NSString *)albumName;


@property (nonatomic) LibraryAlbum *album;
@property (nonatomic) NSString *trackArtistName;
@property (nonatomic) NSNumber *trackNumber;
@property NSNumber *length;

@end
