//
//  WindowView.m
//  fb2kmac
//
//  Created by Miles Wu on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WindowView.h"
#import "LibraryView.h"
#import "LibraryTrack.h"

#import "CoreDataManager.h"

@implementation WindowView

@synthesize playlistView = _playlistView;

- (id)initWithFrame:(CGRect)frame
{
	if((self = [super initWithFrame:frame])) {
		self.backgroundColor = [TUIColor colorWithWhite:0.3 alpha:1.0];
                
        int inlay = 20;
        width_divider = 0.60;
                
        __block typeof(self) bself = self;

        LibraryView *libraryView = [[LibraryView alloc] initWithFrame:CGRectZero];
        libraryView.layout = ^(TUIView *v) {
            CGRect b = v.superview.bounds;
            b.origin.y += inlay;
            b.origin.x += inlay;
            b.size.height -= 2*inlay;
            b.size.width -= 2*inlay;
            
            CGRect libraryFrame = b;
            libraryFrame.size.width = (int)(width_divider*b.size.width);
            return libraryFrame;
        };
        [self addSubview:libraryView];
        
        Playlist *playlist = [[Playlist alloc] init];
        _playlistView = [[PlaylistView alloc] initWithFrame:CGRectZero andPlaylist:playlist];
        _playlistView.layout = ^(TUIView *v) {
            CGRect b = v.superview.bounds;
            b.origin.y += inlay;
            b.origin.x += inlay;
            b.size.height -= 2*inlay;
            b.size.width -= 2*inlay;
            
            CGRect playlistFrame = b;
            playlistFrame.origin.x += (int)(bself->width_divider*b.size.width);
            playlistFrame.size.width = b.size.width - (int)(bself->width_divider*b.size.width);
            return playlistFrame;
        };
        [self addSubview:_playlistView];
	}
	return self;
}

@end
