//
//  NSView+CGDrawing.m
//  dokibox
//
//  Created by Miles Wu on 20/07/2013.
//
//

#import "NSView+CGDrawing.h"

@implementation NSView (CGDrawing)

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

-(void)CGContextVerticalGradient:(CGRect)b context:(CGContextRef)ctx bottomColor:(NSColor *)bottomColor topColor:(NSColor *)topColor
{
    NSArray *colors = [NSArray arrayWithObjects: (id)[bottomColor CGColor],
                       (id)[topColor CGColor], nil];
    CGFloat locations[] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);
    
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(b.origin.x, b.origin.y), CGPointMake(b.origin.x, b.origin.y+b.size.height), 0);
    CGGradientRelease(gradient);
}

@end
