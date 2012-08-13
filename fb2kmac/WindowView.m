//
//  WindowView.m
//  fb2kmac
//
//  Created by Miles Wu on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WindowView.h"

@implementation WindowView

- (id)initWithFrame:(CGRect)frame
{
	if((self = [super initWithFrame:frame])) {
		self.backgroundColor = [TUIColor colorWithWhite:0.9 alpha:1.0];
        
        int toolbarheight = 50;
        
        int inlay = 20;
        CGRect b = self.bounds;
		b.origin.y += inlay;
		b.origin.x += inlay;
		b.size.height -= inlay + toolbarheight;
		b.size.width -= 2*inlay;
        
        Playlist *playlist = [[Playlist alloc] init];
        PlaylistView *playlistView = [[PlaylistView alloc] initWithFrame:b andPlaylist:playlist];
        [playlistView setAutoresizingMask:TUIViewAutoresizingFlexibleSize];
        [self addSubview:playlistView];
        
        b = self.bounds;
        b.origin.y += (b.size.height-toolbarheight);
		b.origin.x += inlay;
		b.size.height = toolbarheight;
		b.size.width -= 2*inlay;
        
        PlayControlsView *pcv = [[PlayControlsView alloc] initWithFrame:b];
        //[pcv setAutoresizingMask:TUIViewAutoresizingFlexibleSize];
        [self addSubview:pcv];
		
	}
	return self;
}

@end
