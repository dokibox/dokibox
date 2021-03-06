//
//  PlaylistTrack.h
//  dokibox
//
//  Created by Miles Wu on 20/11/2011.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "common.h"
#import "ManagedObjectTrack.h"
#import "MusicController.h"
#import "OrderedManagedObject.h"

@class Playlist;

@interface PlaylistTrack : ManagedObjectTrack<OrderedManagedObject> {
}

+(PlaylistTrack *)trackWithFilename:(NSString *)filename inContext:(NSManagedObjectContext *)objectContext;
+(PlaylistTrack *)trackWithLibraryTrack:(LibraryTrack *)libraryTrack inContext:(NSManagedObjectContext *)objectContext;
+(PlaylistTrack *)trackWithPlaylistTrack:(PlaylistTrack *)playlistTrack inContext:(NSManagedObjectContext *)objectContext;
-(NSString *)menuItemFormatString;

-(NSString *)displayName;
-(NSString *)displayAlbumName;
-(NSString *)displayArtistName;

@property (nonatomic) NSString *albumName;
@property (nonatomic) NSString *trackArtistName;
@property (nonatomic) NSString *albumArtistName;
@property (nonatomic) Playlist *playlist;
@property NSNumber *length;
@property MusicControllerStatus playbackStatus;
@property BOOL hasErrorOpeningFile;

@end
