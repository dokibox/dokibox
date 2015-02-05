//
//  LibraryViewAddButton.h
//  dokibox
//
//  Created by Miles Wu on 28/09/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LibraryViewAddButton : NSView {
    BOOL _hover;
    BOOL _held;
}

@property(weak) id target;
@property(assign) SEL action;

@end
