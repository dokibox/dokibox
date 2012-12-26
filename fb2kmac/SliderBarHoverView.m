//
//  SliderBarHoverView.m
//  fb2kmac
//
//  Created by Miles Wu on 25/12/2012.
//
//

#import "SliderBarHoverView.h"

@implementation SliderBarHoverView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	CGContextRef ctx = TUIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 0.2);
    
    CGContextSaveGState(ctx);
    // We are using vertically-flipped and horiztonally-centered coordinates
    CGContextTranslateCTM(ctx, [self bounds].size.width/2.0, 0);
    CGContextTranslateCTM(ctx, 0, [self bounds].size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextFillRect(ctx, NSMakeRect(-10, 0, 20, 10));
    
    CGContextRestoreGState(ctx);

}

@end
