//
//  ProportionalImageView.m
//  dokibox
//
//  Created by Miles Wu on 28/09/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "ProportionalImageView.h"

@implementation ProportionalImageView

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGRect b = [self bounds];
    NSImage *nimage = [self image];
    
    float hratio = b.size.height / [nimage size].height;
    float wratio = b.size.width / [nimage size].width;
    float ratio = hratio > wratio ? hratio : wratio;
    
    CGContextSaveGState(ctx);
    CGContextAddRect(ctx, CGRectMake(b.origin.x, b.origin.y, b.size.width, b.size.width));
    CGContextClip(ctx);
    
    if(wratio > hratio) { //height larger
        CGFloat excess = ratio * [nimage size].height - b.size.height;
        [nimage drawInRect:CGRectMake(b.origin.x, b.origin.y - 0.5*excess, b.size.width, b.size.height + excess) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
    else { //width larger
        CGFloat excess = ratio * [nimage size].width - b.size.width;
        [nimage drawInRect:CGRectMake(b.origin.x - 0.5*excess, b.origin.y, b.size.width + excess, b.size.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
    CGContextRestoreGState(ctx);
}

@end
