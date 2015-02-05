//
//  PluginPreferenceViewController.h
//  dokibox
//
//  Created by Miles Wu on 14/09/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PluginManager;

@interface PluginPreferenceViewController : NSViewController {
    PluginManager *_pluginManager;
    NSTableView IBOutlet *_tableView;
    
    NSView *_currentPluginPreferencePaneView;
}

@end
