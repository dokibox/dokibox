//
//  PlaylistRowView.m
//  fb2kmac
//
//  Created by Miles Wu on 13/07/2013.
//
//

#import "PlaylistRowView.h"

@implementation PlaylistRowView

- (BOOL)isFlipped
{
    return NO;
}

- (void)drawRect:(NSRect)dirtyRect
{    
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGRect b = self.bounds;
    
    if([self isSelected]) {
        // selected background
        if([self isEmphasized]) {
            CGContextSetRGBFillColor(ctx, .77, .77, .87, 1);
        }
        else {
            CGContextSetRGBFillColor(ctx, .87, .87, .87, 1);
        }
        CGContextFillRect(ctx, b);
    } else {
        // light gray background
        CGContextSetRGBFillColor(ctx, .97, .97, .97, 1);
        CGContextFillRect(ctx, b);
        
        // emboss
        CGContextSetRGBFillColor(ctx, 1, 1, 1, 0.9); // light at the top
        CGContextFillRect(ctx, CGRectMake(0, b.size.height-1, b.size.width, 1));
        CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.08); // dark at the bottom
        CGContextFillRect(ctx, CGRectMake(0, 0, b.size.width, 1));
    }
}

@end
