//
//  LibraryViewArtistRowView.m
//  dokibox
//
//  Created by Miles Wu on 26/09/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "LibraryViewArtistRowView.h"

@implementation LibraryViewArtistRowView

- (void)drawRect:(NSRect)dirtyRect
{
    CGRect b = self.bounds;
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    
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
        gradientStartColor = [NSColor colorWithDeviceWhite:0.82 alpha:1.0];
        gradientEndColor = [NSColor colorWithDeviceWhite:0.98 alpha:1.0];
    }
    
    NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                       (id)[gradientEndColor CGColor], nil];
    CGFloat locations[] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);
    
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(b.origin.x, b.origin.y), CGPointMake(b.origin.x, b.origin.y+b.size.height), 0);
    CGGradientRelease(gradient);
    
    // emboss
    /*CGContextSetRGBFillColor(ctx, 1, 1, 1, 0.9); // light at the top
    CGContextFillRect(ctx, CGRectMake(0, b.size.height-1, b.size.width, 1));
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.05); // dark at the bottom
    CGContextFillRect(ctx, CGRectMake(0, 0, b.size.width, 1));*/
}

@end
