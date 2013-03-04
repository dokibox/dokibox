//
//  WindowView.h
//  fb2kmac
//
//  Created by Miles Wu on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TUIView.h"
#import "PlaylistView.h"
#import "Library.h"

@interface WindowView : TUIView {
    PlaylistView *_playlistView;
    Library *_library;
    
    CGFloat width_divider;
}

@property PlaylistView *playlistView;

@end
