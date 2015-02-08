//
//  TitlebarButtonNS.h
//  dokibox
//
//  Created by Miles Wu on 14/08/2012.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TitlebarButtonNS : NSButton {
    NSViewDrawRect _drawIcon;
    BOOL _hover;
    BOOL _held;
}

@property (nonatomic, copy) NSViewDrawRect drawIcon;

@end
