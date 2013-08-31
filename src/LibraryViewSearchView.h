//
//  LibraryViewSearchView.h
//  dokibox
//
//  Created by Miles Wu on 19/08/2013.
//
//

#import <Cocoa/Cocoa.h>

@class LibraryView;

@interface LibraryViewSearchView : NSView < NSTextFieldDelegate > {
    NSSearchField *_searchField;
}

@property(weak) LibraryView *libraryView;

- (void)setFocusInSearchField;
- (void)redisplay;

@end
