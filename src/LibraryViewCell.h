//
//  LibraryViewCell.h
//  dokibox
//
//  Created by Miles Wu on 29/09/2013.
//
//

#import <Cocoa/Cocoa.h>

@interface LibraryViewCell : NSView {
    CGRect _textRect;
    
    NSTextField *_nameTextField;
    NSTextField *_altTextField;
}

@property(weak) NSSet* searchMatchedObjects;

@end
