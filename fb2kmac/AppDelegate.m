//
//  AppDelegate.m
//  fb2kmac
//
//  Created by Miles Wu on 02/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "TitlebarViewNS.h"
#import "PluginManager.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

#import "LibraryPreferenceViewController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    AtLeastLion = YES;
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    DDLogVerbose(@"DD Logger ready");
    
    PluginManager *pluginManager = [PluginManager sharedInstance];
    [pluginManager loadAll];

    _musicController = [[MusicController alloc] init];
    
	CGRect b = CGRectMake(0, 0, 500, 450);
	
	/** Scroll View */
	_window = [[Window alloc] initWithContentRect:b styleMask:NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
	[_window setReleasedWhenClosed:FALSE];
	[_window setMinSize:NSMakeSize(300, 250)];
	[_window center];
    
    TitlebarViewNS *titlebarView = [[TitlebarViewNS alloc] initWithMusicController:_musicController];
    [_window setTitlebarSize:46.0];
    [_window setTitlebarView:titlebarView];
	[titlebarView initSubviews];
    
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
}

-(void)windowWillClose:(NSNotification *)notification
{
    NSLog(@"hi");
}

-(IBAction)openPreferences:(id)sender
{
    // Note: Perhaps we should release the preferenceWindowController when the preference window has closed
    // to save memory, but I can't imagine the memory saving is very great. In any case this doesn't leak.
    // Not sure how to do this (windowWillClose in category of LibraryPreferenceViewController
    // to pass back here maybe to set _preferencesWindowController to nil?)
    if(_preferencesWindowController == nil) {
        NSViewController *libraryPreferenceViewController = [[LibraryPreferenceViewController alloc] init];
        NSArray *controllers = [[NSArray alloc] initWithObjects:libraryPreferenceViewController, nil];
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:@"Preferences"];
    }
    
    [_preferencesWindowController showWindow:nil];
}

@end
