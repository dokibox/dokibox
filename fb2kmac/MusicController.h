//
//  MusicController.h
//  fb2kmac
//
//  Created by Miles Wu on 22/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "common.h"

@interface MusicController : NSObject {
    PlaylistController  *currentPlaylistController;
}

- (void)play:(id)sender;

@end
