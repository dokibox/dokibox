//
//  SliderBar.m
//  fb2kmac
//
//  Created by Miles Wu on 11/10/2012.
//
//

#import "SliderBar.h"

@implementation SliderBar

@synthesize percentage = _percentage;
@synthesize drawHandle = _drawHandle;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _percentage = 0.0;
    }
    
    return self;
}

- (void)mouseDown:(NSEvent *)event
{
    NSPoint event_location = [event locationInWindow];
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    float p = local_point.x / [self bounds].size.width;
    NSNumber *percentage = [NSNumber numberWithFloat:p];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"seekTrack" object:percentage];
}

- (void)drawRect:(NSRect)dirtyRect
{    
    CGRect b = [self bounds];
	CGContextRef ctx = TUIGraphicsGetCurrentContext();
    
    // Draw bar
    TUIColor *gradientStartColor, *gradientEndColor;
    gradientStartColor = [TUIColor colorWithWhite:0.77 alpha:1.0];
    gradientEndColor = [TUIColor colorWithWhite:0.82 alpha:1.0];
    
    NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                       (id)[gradientEndColor CGColor], nil];
    CGFloat locations[] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(b.origin.x, b.origin.y), CGPointMake(b.origin.x, b.origin.y+b.size.height), 0);
    CGGradientRelease(gradient);
    
    
    // Draw darkened completed area
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 0.2);
    CGRect progressrect = b;
    progressrect.size.width *= _percentage;
    CGContextFillRect(ctx, progressrect);
    
    // Draw inner drop shadow
    CGMutablePathRef shadowpath = CGPathCreateMutable();
    CGPathAddRect(shadowpath, NULL, CGRectInset(b, -10, -10));
    CGPathAddRect(shadowpath, NULL, b);
    CGPathCloseSubpath(shadowpath);
    
    CGContextSaveGState(ctx);
    CGContextAddRect(ctx, b);
    CGContextClip(ctx);
    
    TUIColor *shadowcolor = [TUIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, -1), 5, [shadowcolor CGColor]);
    CGContextSetRGBFillColor(ctx, 1.0, 0.0, 0.0, 0.5);
    CGContextAddPath(ctx, shadowpath);

    CGContextEOFillPath(ctx);
    CGContextRestoreGState(ctx);    
    // Draw Handle
    if(_drawHandle) {
        
    }
}

-(void)setPercentage:(float)percentage {
    _percentage = percentage;
    [self setNeedsDisplay:YES];
}

@end
