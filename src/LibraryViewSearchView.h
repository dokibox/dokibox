//
//  LibraryViewSearchView.h
//  dokibox
//
//  Created by Miles Wu on 19/08/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LibraryView;

@interface LibraryViewSearchView : NSView < NSTextFieldDelegate > {
    NSSearchField *_searchField;
}

@property(weak) LibraryView *libraryView;

- (void)setFocusInSearchField;
- (void)resetSearch;
- (void)redisplay;

@end
