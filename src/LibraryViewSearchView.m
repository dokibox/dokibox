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
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(ctx, 1.0, 0.0, 0.0, 1.0);
    CGContextFillRect(ctx, NSMakeRect(5, 5, [self bounds].size.width - 10, [self bounds].size.height - 10));
}

@end
