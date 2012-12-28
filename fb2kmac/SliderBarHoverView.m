//
//  SliderBarHoverView.m
//  fb2kmac
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
	CGContextRef ctx = TUIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 0.7);
    
    CGContextSaveGState(ctx);
    // We are using horiztonally-centered coordinates
    CGContextTranslateCTM(ctx, [self bounds].size.width/2.0, 0);
    
    float widthofcone = 3.0;
    float heightofcone = 6.0;
    float widthoftext = 15.0;
    float heightoftext = 18.0;
    float r = 3.0;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, -0.5, 0.0);
    CGPathAddLineToPoint(path, NULL, 0.5, 0.0);
    CGPathAddLineToPoint(path, NULL, widthofcone, heightofcone);
    CGPathAddLineToPoint(path, NULL, widthofcone + widthoftext - r, heightofcone);
    CGPathAddArcToPoint(path, NULL, widthofcone + widthoftext, heightofcone, widthofcone + widthoftext, heightofcone + r, r);
    CGPathAddLineToPoint(path, NULL, widthofcone + widthoftext, heightofcone + heightoftext - r);
    CGPathAddArcToPoint(path, NULL, widthofcone + widthoftext, heightofcone + heightoftext, widthofcone + widthoftext - r, heightofcone + heightoftext, r);
    CGPathAddLineToPoint(path, NULL, -widthofcone - widthoftext + r, heightofcone + heightoftext);
    CGPathAddArcToPoint(path, NULL, -widthofcone - widthoftext, heightofcone + heightoftext, -widthofcone - widthoftext, heightofcone + heightoftext - r, r);
    CGPathAddLineToPoint(path, NULL, -widthofcone - widthoftext, heightofcone + r);
    CGPathAddArcToPoint(path, NULL, -widthofcone - widthoftext, heightofcone, -widthofcone - widthoftext + r, heightofcone, r);
    CGPathAddLineToPoint(path, NULL, -widthofcone, heightofcone);
    
    CGPathCloseSubpath(path);
    
    CGContextSaveGState(ctx);
    CGContextAddPath(ctx, path);
    CGContextEOFillPath(ctx);
    CGContextRestoreGState(ctx);
    CGPathRelease(path);
    
    NSMutableDictionary *textAttr = [NSMutableDictionary dictionary];
    [textAttr setObject:[NSFont fontWithName:@"Lucida Grande" size:9] forKey:NSFontAttributeName];
    [textAttr setObject:[NSColor colorWithDeviceWhite:1.0 alpha:1.0] forKey:NSForegroundColorAttributeName];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:_stringValue attributes:textAttr];
    NSPoint textPoint = NSMakePoint(-0.5*[attrString size].width, heightofcone + 0.5*heightoftext - 0.5*[attrString size].height);
    [attrString drawAtPoint:textPoint];
    
    CGContextRestoreGState(ctx);

}

@end
