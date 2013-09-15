//
//  PluginPreferenceViewController.h
//  dokibox
//
//  Created by Miles Wu on 14/09/2013.
//
//

#import <Cocoa/Cocoa.h>

@class PluginManager;

@interface PluginPreferenceViewController : NSViewController {
    PluginManager *_pluginManager;
    NSTableView IBOutlet *_tableView;
    
    NSView *_currentPluginPreferencePaneView;
}

@end
