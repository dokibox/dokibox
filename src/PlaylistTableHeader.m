//
//  PlaylistTableHeader.m
//  dokibox
//
//  Created by Miles Wu on 19/12/2013.
//
//

#import "PlaylistTableHeader.h"
#import "NSView+CGDrawing.h"

@implementation PlaylistTableHeader

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGRect barRect = [self bounds];
    
    [self CGContextVerticalGradient:barRect context:ctx bottomColor:[NSColor colorWithDeviceWhite:0.8 alpha:1.0] topColor:[NSColor colorWithDeviceWhite:0.92 alpha:1.0]];
    
    // Line top/bottom
    CGContextSetStrokeColorWithColor(ctx, [[NSColor colorWithDeviceWhite:0.8 alpha:1.0] CGColor]);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, barRect.origin.x, barRect.origin.y + barRect.size.height - 0.5);
    CGContextAddLineToPoint(ctx, barRect.origin.x + barRect.size.width, barRect.origin.y + barRect.size.height - 0.5);
    CGContextStrokePath(ctx);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, barRect.origin.x, barRect.origin.y + 0.5);
    CGContextAddLineToPoint(ctx, barRect.origin.x + barRect.size.width, barRect.origin.y + 0.5);
    CGContextStrokePath(ctx);
    
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    [attr setObject:[NSFont labelFontOfSize:9] forKey:NSFontAttributeName];
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Playlist Collection" attributes:attr];
    CGPoint strPoint = NSMakePoint(barRect.origin.x + barRect.size.width/2.0 - [str size].width/2.0, barRect.origin.y + barRect.size.height/2.0 - [str size].height/2.0);
    CGContextSetShouldSmoothFonts(ctx, YES);
    [str drawAtPoint:strPoint];
}

@end
