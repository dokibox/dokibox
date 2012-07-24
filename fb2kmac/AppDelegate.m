//
//  AppDelegate.m
//  fb2kmac
//
//  Created by Miles Wu on 02/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    AtLeastLion = YES;
	CGRect b = CGRectMake(0, 0, 500, 450);
	
	/** Scroll View */
	_window = [[NSWindow alloc] initWithContentRect:b styleMask:NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
	[_window setReleasedWhenClosed:FALSE];
	[_window setMinSize:NSMakeSize(300, 250)];
	[_window center];
	
	/* TUINSView is the bridge between the standard AppKit NSView-based heirarchy and the TUIView-based heirarchy */
	TUINSView *tuiWindow = [[TUINSView alloc] initWithFrame:b];
	[_window setContentView:tuiWindow];
	
	WindowView *windowView = [[WindowView alloc] initWithFrame:b];
	tuiWindow.rootView = windowView;
	
    [_window makeKeyAndOrderFront:nil];
    
    _musicController = [[MusicController alloc] init];
}

@end
