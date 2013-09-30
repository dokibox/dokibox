//
//  LibraryViewAddButton.m
//  dokibox
//
//  Created by Miles Wu on 28/09/2013.
//
//

#import "LibraryViewAddButton.h"
#import "NSView+CGDrawing.h"

@implementation LibraryViewAddButton

@synthesize action = _action;
@synthesize target = _target;

- (void)drawRect:(NSRect)dirtyRect
{
    CGRect b = self.bounds;
    CGPoint middle = CGPointMake(CGRectGetMidX(b), CGRectGetMidY(b));
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextSaveGState(ctx);
    CGContextAddArc(ctx, middle.x, middle.y, 7, 0, 2*pi, 0);
    CGContextClip(ctx);
    
    NSColor *gradientStartColor, *gradientEndColor;
    gradientStartColor = [NSColor colorWithDeviceWhite:0.75 alpha:1.0];
    gradientEndColor = [NSColor colorWithDeviceWhite:0.9 alpha:1.0];
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

-(void)mouseDown:(NSEvent *)theEvent
{
    if(_target && _action) {
        [NSApp sendAction:_action to:_target from:self];
    }
}

@end
