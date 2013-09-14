//
//  AppDelegate.h
//  dokibox
//
//  Created by Miles Wu on 02/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MusicController.h"
#import "Window.h"
#import "MASPreferencesWindowController.h"
#import "Library.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    Window    * _window;
    MusicController *_musicController;
    Library *_library;
    NSWindowController *_preferencesWindowController;
}

-(IBAction)performFindPanelAction:(id)sender;

@end