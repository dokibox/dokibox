//
//  LibraryViewCell.h
//  dokibox
//
//  Created by Miles Wu on 29/09/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LibraryView;

@interface LibraryViewCell : NSView {
    CGRect _textRect;
    
    NSTextField *_nameTextField;
    NSTextField *_altTextField;
}

- (void)addButtonPressed:(id)sender;

@property(weak) NSSet* searchMatchedObjects;
@property(weak) LibraryView* libraryView;

@end
