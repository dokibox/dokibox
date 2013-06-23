//
//  WindowView.h
//  fb2kmac
//
//  Created by Miles Wu on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TUIView.h"
#import "PlaylistView.h"

@interface WindowView : TUIView {
    PlaylistView *_playlistView;    
    CGFloat width_divider;
}

@property PlaylistView *playlistView;

@end
