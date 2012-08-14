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
	_window = [[Window alloc] initWithContentRect:b styleMask:NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
	[_window setReleasedWhenClosed:FALSE];
	[_window setMinSize:NSMakeSize(300, 250)];
	[_window center];
	
	/* TUINSView is the bridge between the standard AppKit NSView-based heirarchy and the TUIView-based heirarchy */
	TUINSView *tuiWindow = [[TUINSView alloc] initWithFrame:b];
	[_window setContentView:tuiWindow];

    /*NSRect windowFrame = [_window frame];
    NSRect newFrame = [tuiWindow frame];
    CGFloat titleHeight = NSHeight(windowFrame) - NSHeight(newFrame);
    newFrame.size.height -= 60;*/
    //[tuiWindow setFrame:windowFrame];
	
	WindowView *windowView = [[WindowView alloc] initWithFrame:[tuiWindow frame]];
	tuiWindow.rootView = windowView;
	
    [_window makeKeyAndOrderFront:nil];
    [_window relayout];
    
    _musicController = [[MusicController alloc] init];
}

@end
