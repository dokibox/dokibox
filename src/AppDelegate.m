//
//  AppDelegate.m
//  dokibox
//
//  Created by Miles Wu on 02/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDDLogFormatter.h"
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
    AppDDLogFormatter *logFormatter = [[AppDDLogFormatter alloc] init];
    [[DDASLLogger sharedInstance] setLogFormatter:logFormatter];
    [[DDTTYLogger sharedInstance] setLogFormatter:logFormatter];
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

    /** Window */
    CGFloat titlebarSize = 46;
    _window = [[Window alloc] initWithContentRect:b styleMask:NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask | NSMiniaturizableWindowMask | NSTexturedBackgroundWindowMask backing:NSBackingStoreBuffered defer:NO];
    [_window setReleasedWhenClosed:FALSE];
    [_window setMinSize:NSMakeSize(300, 250)];
    [_window center];
    [_window setTitlebarSize:titlebarSize];

    TitlebarViewNS *titlebarView = [[TitlebarViewNS alloc] initWithMusicController:_musicController];
    WindowContentView *wcv = [[WindowContentView alloc] initWithFrame:b andLibrary:_library titlebarSize:titlebarSize];
    [_window setContentView:wcv];
    [_window setTitlebarView:titlebarView];
    [titlebarView initSubviews];
    [_window makeKeyAndOrderFront:nil];
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
