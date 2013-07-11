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
#import "WindowContentView.h"

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
    
    NSString *defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"defaultPrefs" ofType:@"plist"];
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];

    _musicController = [[MusicController alloc] init];
    _library = [[Library alloc] init];
    [_library startFSMonitor];
    
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
    
    b.size.height = [_window contentViewHeight];
    WindowContentView *wcv = [[WindowContentView alloc] initWithFrame:b];
    [_window setContentView:wcv];
    
    [_window makeKeyAndOrderFront:nil];
    [_window relayout];
}

-(IBAction)openPreferences:(id)sender
{
    // Note: Perhaps we should release the preferenceWindowController when the preference window has closed
    // to save memory, but I can't imagine the memory saving is very great. In any case this doesn't leak.
    // Not sure how to do this (windowWillClose in category of LibraryPreferenceViewController
    // to pass back here maybe to set _preferencesWindowController to nil?)
    if(_preferencesWindowController == nil) {
        NSViewController *libraryPreferenceViewController = [[LibraryPreferenceViewController alloc] initWithLibrary:_library];
        NSArray *controllers = [[NSArray alloc] initWithObjects:libraryPreferenceViewController, nil];
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:@"Preferences"];
    }
    
    [_preferencesWindowController showWindow:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    if([[NSUserDefaults standardUserDefaults] synchronize] == NO) {
        DDLogError(@"Error saving preferences to disk");
    }
}

@end
