//
//  AppDelegate.h
//  fb2kmac
//
//  Created by Miles Wu on 02/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TUIKit.h>
#import "WindowView.h"
#import "MusicController.h"
#import "Window.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    Window    * _window;
    MusicController *_musicController;

}
@end