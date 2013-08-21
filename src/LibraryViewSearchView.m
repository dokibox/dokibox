//
//  LibraryViewSearchView.m
//  dokibox
//
//  Created by Miles Wu on 19/08/2013.
//
//

#import "LibraryViewSearchView.h"

@implementation LibraryViewSearchView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setWantsLayer:YES];
        
        NSRect b = CGRectInset([self bounds], 3, 3);
        b.size.height -= 1;
        _searchField = [[NSSearchField alloc] initWithFrame:b];
        [[_searchField cell] setControlSize:NSSmallControlSize];
        [_searchField setFont:[NSFont fontWithName:@"Lucida Grande" size:10]];
        [self addSubview:_searchField];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    //CGContextSetRGBFillColor(ctx, 1.0, 0.0, 0.0, 1.0);
    //CGContextFillRect(ctx, NSMakeRect(5, 5, [self bounds].size.width - 10, [self bounds].size.height - 10));
}

@end
