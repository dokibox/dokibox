//
//  MusicController.m
//  fb2kmac
//
//  Created by Miles Wu on 22/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MusicController.h"
#import "PlaylistTrack.h"
#import "PlaylistController.h"

@implementation MusicController

- (void)play:(id)sender {
    currentPlaylistController = sender;
    PlaylistTrack *pt = [currentPlaylistController getCurrentTrack];
    
    NSLog([pt title]);
    

};

@end
