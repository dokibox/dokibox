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

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSWindow    * _window;
    MusicController *_musicController;

}
@end