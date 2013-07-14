//
//  TitlebarButtonNS.m
//  fb2kmac
//
//  Created by Miles Wu on 14/08/2012.
//
//

#import "TitlebarButtonNS.h"

@implementation TitlebarButtonNS

@synthesize drawIcon = _drawIcon;

- (id)initWithFrame:(NSRect)rect {
    if(self = [super initWithFrame:rect]) {
        _hover = NO;
        _held = NO;
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
        [self sendAction:[self action] to:[self target]];
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

- (void)CGContextRoundedCornerPath:(CGRect)b context:(CGContextRef)ctx radius:(CGFloat)r withHalfPixelRedution:(BOOL)onpixel
{
    CGFloat diff = (onpixel ? 0.5 : 0.0);

    CGContextMoveToPoint(ctx, NSMinX(b)+diff, NSMinY(b)+r+diff);
    CGContextAddLineToPoint(ctx, NSMinX(b)+diff, NSMaxY(b)-r-diff);
    CGContextAddArcToPoint(ctx, NSMinX(b)+diff, NSMaxY(b)-diff, NSMinX(b)+r+diff, NSMaxY(b)-diff, r);
    CGContextAddLineToPoint(ctx, NSMaxX(b)-r-diff, NSMaxY(b)-diff);
    CGContextAddArcToPoint(ctx, NSMaxX(b)-diff, NSMaxY(b)-diff, NSMaxX(b)-diff, NSMaxY(b)-r-diff, r);
    CGContextAddLineToPoint(ctx, NSMaxX(b)-diff, NSMinY(b)+r+diff);
    CGContextAddArcToPoint(ctx, NSMaxX(b)-diff, NSMinY(b)+diff, NSMaxX(b)-r-diff, NSMinY(b)+diff, r);
    CGContextAddLineToPoint(ctx, NSMinX(b)+r+diff, NSMinY(b)+diff);
    CGContextAddArcToPoint(ctx, NSMinX(b)+diff, NSMinY(b)+diff, NSMinX(b)+diff, NSMinY(b)+r+diff, r);
}

- (BOOL)isFlipped
{
    return NO;
}

- (void)drawRect:(NSRect)dirtyRect
{

    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    CGRect b = self.bounds;
    
    BOOL key = [[self window] isKeyWindow];
    
    if(!key) {
        CGContextSetAlpha(ctx, 0.75);
    }
    if(_hover) {
        
        TUIColor *gradientStartColor, *gradientEndColor, *borderColor;

        if(_held) {
            gradientStartColor = [TUIColor colorWithWhite:0.62 alpha:1.0];
            gradientEndColor = [TUIColor colorWithWhite:0.72 alpha:1.0];
            borderColor = [TUIColor colorWithWhite:0.45 alpha:1.0];
        } else {
            gradientStartColor = [TUIColor colorWithWhite:0.82 alpha:1.0];
            gradientEndColor = [TUIColor colorWithWhite:0.92 alpha:1.0];
            borderColor = [TUIColor colorWithWhite:0.65 alpha:1.0];
        }

                
        [self CGContextRoundedCornerPath:b context:ctx radius:7.0 withHalfPixelRedution:NO];
        CGContextSaveGState(ctx);
        CGContextClip(ctx);
    
        NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                           (id)[gradientEndColor CGColor], nil];
        CGFloat locations[] = { 0.0, 1.0 };
        CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);
        
        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(b.origin.x, b.origin.y), CGPointMake(b.origin.x, b.origin.y+b.size.height), 0);
        
        CGContextRestoreGState(ctx);
        CGGradientRelease(gradient);
        
        [self CGContextRoundedCornerPath:b context:ctx radius:7.0 withHalfPixelRedution:YES];
        CGContextSetStrokeColorWithColor(ctx, [borderColor CGColor]);
        CGContextStrokePath(ctx);
    }
    
    _drawIcon(self, b);
}

@end
