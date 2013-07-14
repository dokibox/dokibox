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
    NSColor *gradientStartColor, *gradientEndColor;
    
    if([self isSelected]) {
        // selected background
        if([self isEmphasized]) { // also active
            gradientStartColor = [NSColor colorWithDeviceRed:0.52 green:0.65 blue:1.0 alpha:1.0];
            gradientEndColor = [NSColor colorWithDeviceRed:0.72 green:0.85 blue:1.0 alpha:1.0];
        }
        else {
            gradientStartColor = [NSColor colorWithDeviceRed:0.82 green:0.88 blue:1.0 alpha:1.0];
            gradientEndColor = [NSColor colorWithDeviceRed:0.92 green:0.97 blue:1.0 alpha:1.0];
        }
    } else {
        gradientStartColor = [NSColor colorWithDeviceWhite:0.92 alpha:1.0];
        gradientEndColor = [NSColor colorWithDeviceWhite:0.98 alpha:1.0];
    }
    
    NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                       (id)[gradientEndColor CGColor], nil];
    CGFloat locations[] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);
    
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(b.origin.x, b.origin.y), CGPointMake(b.origin.x, b.origin.y+b.size.height), 0);
    CGGradientRelease(gradient);
}

@end
