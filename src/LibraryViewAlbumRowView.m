//
//  LibraryViewAlbumRowView.m
//  dokibox
//
//  Created by Miles Wu on 26/09/2013.
//
//

#import "LibraryViewAlbumRowView.h"

@implementation LibraryViewAlbumRowView

- (void)drawRect:(NSRect)dirtyRect
{
    CGRect b = self.bounds;
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    
    if([self isSelected]) {
        CGContextSetRGBFillColor(ctx, .81, .85, .98, 1);
        CGContextFillRect(ctx, b);
    } else {
        CGContextSetRGBFillColor(ctx, .87, .90, .94, 1);
        CGContextFillRect(ctx, b);
    }
}

@end
