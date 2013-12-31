//
//  AppDelegate.m
//  dokibox
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
#import "ProfileViewController.h"
#import "ProfileController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    DDLogVerbose(@"DD Logger ready");
    
    if([NSEvent modifierFlags] & NSAlternateKeyMask) {
        NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0,0,409,300) styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO];
        [window center];
        ProfileViewController *profileViewController = [[ProfileViewController alloc] init];
        [window setContentView:[profileViewController view]];
        [[NSApplication sharedApplication] runModalForWindow:window];
        [window setReleasedWhenClosed:NO]; // let ARC handle
        [window close];
    }
    
    [self launch];
}

-(void)launch {
    PluginManager *pluginManager = [PluginManager sharedInstance];
    [pluginManager loadAll];
    
    NSString *defaultPrefsFile = [[NSBundle mainBundle] pathForResource:@"defaultPrefs" ofType:@"plist"];
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];

    _musicController = [[MusicController alloc] init];
    _library = [[Library alloc] init];
    [_library startFSMonitor];

    CGRect b = CGRectMake(0, 0, 800, 450);

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
    WindowContentView *wcv = [[WindowContentView alloc] initWithFrame:b andLibrary:_library];
    [_window setContentView:wcv];

    [_window makeKeyAndOrderFront:nil];
    [_window relayout];
}

-(IBAction)performFindPanelAction:(id)sender
{
    WindowContentView *wcv = (WindowContentView*)[_window contentView];
    [wcv performFindPanelAction:sender];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application
{
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    if([[NSUserDefaults standardUserDefaults] synchronize] == NO) {
        DDLogError(@"Error saving preferences to disk");
    }
}

@end
