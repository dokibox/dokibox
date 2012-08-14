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
		self.backgroundColor = [TUIColor colorWithWhite:0.3 alpha:1.0];
                
        int inlay = 20;
        CGRect b = frame;
		b.origin.y += inlay;
		b.origin.x += inlay;
		b.size.height -= 2*inlay;
		b.size.width -= 2*inlay;
        
        Playlist *playlist = [[Playlist alloc] init];
        PlaylistView *playlistView = [[PlaylistView alloc] initWithFrame:b andPlaylist:playlist];
        [playlistView setAutoresizingMask:TUIViewAutoresizingFlexibleSize];
        [self addSubview:playlistView];
	}
	return self;
}

@end
