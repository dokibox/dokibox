//
//  LibraryViewAddButton.m
//  dokibox
//
//  Created by Miles Wu on 28/09/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "LibraryViewAddButton.h"
#import "NSView+CGDrawing.h"

@implementation LibraryViewAddButton

@synthesize action = _action;
@synthesize target = _target;

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if(self) {
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options: NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingEnabledDuringMouseDrag owner:self userInfo:nil];
        [self addTrackingArea:trackingArea];
    }
    return self;
}

- (void)mouseDown:(NSEvent *)event
{
    _held = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event
{
    if(CGRectContainsPoint([self bounds], [self convertPoint:[event locationInWindow] fromView:nil])) {
        if(_target && _action) {
            [NSApp sendAction:_action to:_target from:self];
        }
    }
    _held = NO;
    [self setNeedsDisplay:YES];
}

- (void)mouseEntered:(NSEvent *)event
{
    _hover = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)event
{
    _hover = NO;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGRect b = self.bounds;
    CGPoint middle = CGPointMake(CGRectGetMidX(b), CGRectGetMidY(b));
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextSaveGState(ctx);
    CGContextAddArc(ctx, middle.x, middle.y, 7, 0, 2*pi, 0);
    CGContextClip(ctx);
    
    NSColor *gradientStartColor, *gradientEndColor;
    if(_held) {
        gradientStartColor = [NSColor colorWithDeviceWhite:0.4 alpha:1.0];
        gradientEndColor = [NSColor colorWithDeviceWhite:0.65 alpha:1.0];
    }
    else if(_hover) {
        gradientStartColor = [NSColor colorWithDeviceWhite:0.6 alpha:1.0];
        gradientEndColor = [NSColor colorWithDeviceWhite:0.85 alpha:1.0];
    }
    else {
        gradientStartColor = [NSColor colorWithDeviceWhite:0.75 alpha:1.0];
        gradientEndColor = [NSColor colorWithDeviceWhite:0.9 alpha:1.0];
    }
    [self CGContextVerticalGradient:b context:ctx bottomColor:gradientStartColor topColor:gradientEndColor];
    
    CGContextRestoreGState(ctx);

    CGContextSaveGState(ctx);
    CGFloat width = 2.0;
    CGFloat height = 8.0;
    
    CGRect rects[] = {
        CGRectMake(middle.x - width/2.0, middle.y - height/2.0, width, height),
        CGRectMake(middle.x - height/2.0, middle.y - width/2.0, height, width)
    };
    CGContextClipToRects(ctx, rects, 2);
    gradientEndColor = [NSColor colorWithDeviceWhite:0.2 alpha:1.0];
    gradientStartColor = [NSColor colorWithDeviceWhite:0.5 alpha:1.0];
    [self CGContextVerticalGradient:b context:ctx bottomColor:gradientStartColor topColor:gradientEndColor];
    CGContextRestoreGState(ctx);
}

@end
