//
//  LibraryViewCell.m
//  dokibox
//
//  Created by Miles Wu on 29/09/2013.
//
//

#import "LibraryViewCell.h"
#import "LibraryViewAddButton.h"
#import "LibraryView.h"

@implementation LibraryViewCell

@synthesize searchMatchedObjects = _searchMatchedObjects;
@synthesize libraryView = _libraryView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _textRect = NSInsetRect([self bounds], 5, 4);
        _textRect.origin.x += 17; // for button
        _textRect.size.width -= 17; // for button
        
        // Defaults for _nameTextField
        _nameTextField = [[NSTextField alloc] initWithFrame:NSZeroRect];
        [_nameTextField setEditable:NO];
        [_nameTextField setBordered:NO];
        [_nameTextField setBezeled:NO];
        [_nameTextField setDrawsBackground:NO];
        [[_nameTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [_nameTextField setAutoresizingMask:NSViewWidthSizable];
        [self addSubview:_nameTextField];
        
        // Defaults for _altTextField
        _altTextField = [[NSTextField alloc] initWithFrame:NSZeroRect];
        [_altTextField setEditable:NO];
        [_altTextField setBordered:NO];
        [_altTextField setBezeled:NO];
        [_altTextField setDrawsBackground:NO];
        [_altTextField setFont:[[NSFontManager sharedFontManager] convertFont:[NSFont systemFontOfSize:10] toHaveTrait:NSItalicFontMask]];
        [_altTextField setTextColor:[NSColor colorWithDeviceWhite:0.35 alpha:1.0]];
        [_altTextField setAlignment:NSRightTextAlignment];
        [_altTextField setAutoresizingMask:NSViewMinXMargin];
        [self addSubview:_altTextField];
        
        // Add to playlist button
        CGRect buttonFrame = NSMakeRect(2, NSMidY([self bounds])-10, 20, 20);
        LibraryViewAddButton *addButton = [[LibraryViewAddButton alloc] initWithFrame:buttonFrame];
        [addButton setAutoresizingMask:NSViewMaxXMargin];
        [addButton setTarget:self];
        [addButton setAction:@selector(addButtonPressed:)];
        [self addSubview:addButton];
    }
    
    return self;
}

- (void)addButtonPressed:(id)sender
{
    if(_libraryView == nil) {
        DDLogError(@"_libraryView is not set in LibraryViewCell");
        return;
    }
    
    [_libraryView addButtonPressed:self];
}

- (void)drawRect:(CGRect)rect
{
    // Need a drawRect function for subpixel font rendering to work in NSTextField
}

@end
