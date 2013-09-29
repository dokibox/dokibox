//
//  LibraryViewTrackRowView.m
//  dokibox
//
//  Created by Miles Wu on 28/09/2013.
//
//

#import "LibraryViewTrackRowView.h"

@implementation LibraryViewTrackRowView

@synthesize isEvenRow = _isEvenRow;

- (void)drawRect:(NSRect)dirtyRect
{
    CGRect b = self.bounds;
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    
    // draw left background
    CGContextSetRGBFillColor(ctx, .87, .90, .94, 1);
    CGContextFillRect(ctx, b);
    
    // indent everything by the image size
    CGFloat indent = 50;
    b = CGRectIntersection(b, CGRectOffset(b, indent, 0));
    
    // draw normal background
    if([self isSelected] == true)
        CGContextSetRGBFillColor(ctx, .81, .85, .98, 1);
    else if([self isEvenRow] == true)
        CGContextSetRGBFillColor(ctx, .92, .94, .99, 1);
    else
        CGContextSetRGBFillColor(ctx, .98, .99, 1.0, 1);
    CGContextFillRect(ctx, b);}

@end
