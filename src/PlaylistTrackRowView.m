//
//  PlaylistTrackRowView.m
//  dokibox
//
//  Created by Miles Wu on 13/07/2013.
//
//

#import "PlaylistTrackRowView.h"

@implementation PlaylistTrackRowView

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
        // background
        CGContextSetFillColorWithColor(ctx, [[self backgroundColor] CGColor]);
        CGContextFillRect(ctx, b);
    }
}

@end
