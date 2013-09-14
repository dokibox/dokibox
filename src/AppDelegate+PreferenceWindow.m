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


@implementation AppDelegate (PreferenceWindow)


-(IBAction)openPreferences:(id)sender
{
    // Note: Perhaps we should release the preferenceWindowController when the preference window has closed
    // to save memory, but I can't imagine the memory saving is very great. In any case this doesn't leak.
    // Not sure how to do this (windowWillClose in category of LibraryPreferenceViewController
    // to pass back here maybe to set _preferencesWindowController to nil?)
    if(_preferencesWindowController == nil) {
        NSViewController *libraryPreferenceViewController = [[LibraryPreferenceViewController alloc] initWithLibrary:_library];
        NSViewController *pluginPreferenceViewController = [[PluginPreferenceViewController alloc] init];

        NSArray *controllers = [[NSArray alloc] initWithObjects:libraryPreferenceViewController, pluginPreferenceViewController, nil];
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:@"Preferences"];
    }
    
    [_preferencesWindowController showWindow:nil];
}

@end
