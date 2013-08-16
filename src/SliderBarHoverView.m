//
//  SliderBarHoverView.m
//  dokibox
//
//  Created by Miles Wu on 25/12/2012.
//
//

#import "SliderBarHoverView.h"

@implementation SliderBarHoverView

@synthesize stringValue = _stringValue;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _stringValue = @"";
    }

    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];

    CGContextSaveGState(ctx);
    // We are using horiztonally-centered coordinates
    CGContextTranslateCTM(ctx, [self bounds].size.width/2.0, 0);

    float widthofcone = 3.0;
    float heightofcone = 6.0;
    float widthoftext = 15.0;
    float heightoftext = 18.0;
    float r = 4.0;
    float alpha = 0.7;

    // Create Bottom half of path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, -0.5, 0.0);
    CGPathAddLineToPoint(path, NULL, 0.5, 0.0);
    CGPathAddLineToPoint(path, NULL, widthofcone, heightofcone);
    CGPathAddLineToPoint(path, NULL, widthofcone + widthoftext - r, heightofcone);
    CGPathAddArcToPoint(path, NULL, widthofcone + widthoftext, heightofcone, widthofcone + widthoftext, heightofcone + r, r);
    CGPathAddLineToPoint(path, NULL, widthofcone + widthoftext, heightofcone + heightoftext*0.5); // corner
    CGPathAddLineToPoint(path, NULL, -widthofcone - widthoftext, heightofcone + heightoftext*0.5); //corner
    CGPathAddLineToPoint(path, NULL, -widthofcone - widthoftext, heightofcone + r);
    CGPathAddArcToPoint(path, NULL, -widthofcone - widthoftext, heightofcone, -widthofcone - widthoftext + r, heightofcone, r);
    CGPathAddLineToPoint(path, NULL, -widthofcone, heightofcone);
    CGPathCloseSubpath(path);

    // Draw bottom half of path
    CGContextSaveGState(ctx);
    float greybottom = 0.15;
    CGContextSetRGBFillColor(ctx, greybottom, greybottom, greybottom, alpha);
    CGContextAddPath(ctx, path);
    CGContextEOFillPath(ctx);
    CGContextRestoreGState(ctx);
    CGPathRelease(path);

    // Create top half of path
    path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, widthofcone + widthoftext, heightofcone + heightoftext*0.5); // corner
    CGPathAddLineToPoint(path, NULL, widthofcone + widthoftext, heightofcone + heightoftext - r);
    CGPathAddArcToPoint(path, NULL, widthofcone + widthoftext, heightofcone + heightoftext, widthofcone + widthoftext - r, heightofcone + heightoftext, r);
    CGPathAddLineToPoint(path, NULL, -widthofcone - widthoftext + r, heightofcone + heightoftext);
    CGPathAddArcToPoint(path, NULL, -widthofcone - widthoftext, heightofcone + heightoftext, -widthofcone - widthoftext, heightofcone + heightoftext - r, r);
    CGPathAddLineToPoint(path, NULL, -widthofcone - widthoftext, heightofcone + heightoftext*0.5); //corner
    CGPathCloseSubpath(path);

    // Draw top half of path
    CGContextSaveGState(ctx);
    //float greytop = 0.35;
    //CGContextSetRGBFillColor(ctx, greytop, greytop, greytop, alpha);

    NSColor *gradientStartColor, *gradientEndColor;
    gradientStartColor = [NSColor colorWithDeviceWhite:0.15 alpha:alpha];
    gradientEndColor = [NSColor colorWithDeviceWhite:0.28 alpha:alpha];
    NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                       (id)[gradientEndColor CGColor], nil];
    CGFloat locations[] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

    CGContextAddPath(ctx, path);
    CGContextClip(ctx);
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(-widthofcone - widthoftext, heightofcone + heightoftext*0.5), CGPointMake(-widthofcone - widthoftext, heightofcone + heightoftext), 0);
    CGGradientRelease(gradient);
    CGContextRestoreGState(ctx);
    CGPathRelease(path);

    // Draw text
    NSMutableDictionary *textAttr = [NSMutableDictionary dictionary];
    [textAttr setObject:[NSFont fontWithName:@"Lucida Grande" size:9] forKey:NSFontAttributeName];
    [textAttr setObject:[NSColor colorWithDeviceWhite:1.0 alpha:1.0] forKey:NSForegroundColorAttributeName];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:_stringValue attributes:textAttr];
    NSPoint textPoint = NSMakePoint(-0.5*[attrString size].width, heightofcone + 0.5*heightoftext - 0.5*[attrString size].height);
    [attrString drawAtPoint:textPoint];

    CGContextRestoreGState(ctx);

}

@end
