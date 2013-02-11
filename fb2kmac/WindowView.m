//
//  WindowView.m
//  fb2kmac
//
//  Created by Miles Wu on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WindowView.h"
#import "LibraryView.h"

#import "CoreDataManager.h"

@implementation WindowView

@synthesize playlistView = _playlistView;

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
        
        /*Playlist *playlist = [[Playlist alloc] init];
        _playlistView = [[PlaylistView alloc] initWithFrame:b andPlaylist:playlist];
        [_playlistView setAutoresizingMask:TUIViewAutoresizingFlexibleSize];
        [self addSubview:_playlistView];*/
                
        _library = [[Library alloc] init];
        [_library searchDirectory:@"/Users/mileswu/Downloads"];
        NSLog(@"done serach");
        LibraryView *libraryView = [[LibraryView alloc] initWithFrame:b];
        [libraryView setAutoresizingMask:TUIViewAutoresizingFlexibleSize];
        [self addSubview:libraryView];
	}
	return self;
}

@end
