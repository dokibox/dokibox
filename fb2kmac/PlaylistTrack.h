//
//  PlaylistTrack.h
//  fb2kmac
//
//  Created by Miles Wu on 20/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "common.h"
#import "ManagedObjectTrack.h"

@class Playlist;

@interface PlaylistTrack : ManagedObjectTrack {
}

+(PlaylistTrack *)trackWithFilename:(NSString *)filename andPlaylist:(Playlist *)playlist inContext:(NSManagedObjectContext *)objectContext;

@property (nonatomic) NSString *albumName;
@property (nonatomic) NSString *artistName;
@property (nonatomic) Playlist *playlist;

@end
