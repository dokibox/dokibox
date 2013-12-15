//
//  PlaylistTrack.h
//  dokibox
//
//  Created by Miles Wu on 20/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "common.h"
#import "ManagedObjectTrack.h"
#import "MusicController.h"

@class Playlist;

@interface PlaylistTrack : ManagedObjectTrack {
}

+(PlaylistTrack *)trackWithFilename:(NSString *)filename inContext:(NSManagedObjectContext *)objectContext;

@property (nonatomic) NSString *albumName;
@property (nonatomic) NSString *artistName;
@property (nonatomic) Playlist *playlist;
@property NSNumber *index;
@property NSNumber *length;
@property MusicControllerStatus playbackStatus;

@end
