//
//  Window.h
//  dokibox
//
//  Created by Miles Wu on 14/08/2012.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//
#import <Cocoa/Cocoa.h>

@interface Window : NSWindow {
    NSView *_titlebarView;
    CGFloat _titlebarSize;
}

@property NSView* titlebarView;
@property CGFloat titlebarSize;

- (void)relayout;

@end
