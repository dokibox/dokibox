//
//  AppDelegate+PreferenceWindow.m
//  dokibox
//
//  Created by Miles Wu on 14/09/2013.
//
//

#import "AppDelegate+PreferenceWindow.h"
#import "LibraryPreferenceViewController.h"
#import "PluginPreferenceViewController.h"
#import "UpdaterPreferenceViewController.h"

@implementation AppDelegate (PreferenceWindow)


-(IBAction)openPreferences:(id)sender
{
    if(_preferencesWindowController == nil) { // Need to create window as it doesn't exist yet
        NSViewController *libraryPreferenceViewController = [[LibraryPreferenceViewController alloc] initWithLibrary:_library];
        NSViewController *pluginPreferenceViewController = [[PluginPreferenceViewController alloc] init];

        NSMutableArray *controllers = [[NSMutableArray alloc] initWithObjects:libraryPreferenceViewController, pluginPreferenceViewController, nil];
        
#ifndef DEBUG
        [controllers addObject:[[UpdaterPreferenceViewController alloc] init]];
#endif
        
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:@"Preferences"];
        [_preferencesWindowController showWindow:nil];
        
        // Add observer for the preference window closing, so we can release the window contoller
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferenceWindowWillClose:) name:NSWindowWillCloseNotification object:[_preferencesWindowController window]];
    }
    else { // Window already exists. Just bring it to the front again
        [_preferencesWindowController showWindow:nil];
    }
}

-(void)preferenceWindowWillClose:(NSNotification *)notification
{
    // Window is about to close, so release the window controller (also remove observer)
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:[_preferencesWindowController window]];
    _preferencesWindowController = nil;
}

@end
