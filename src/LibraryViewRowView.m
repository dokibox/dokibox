//
//  LibraryViewRowView.m
//  dokibox
//
//  Created by Miles Wu on 08/05/2014.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "LibraryViewRowView.h"

@implementation LibraryViewRowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // This prevents strange glitches during removal animation of table rows (see issue #34). Only occured if layer-backed
        // Theory: it was trying to re-drawRect during animation (why I don't know because the glitching rows were not being resized) and either lagging or screwing up
        // Rows still seem to correct after a resize, which is good
        [self setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawOnSetNeedsDisplay];
    }
    return self;
}

- (BOOL)isFlipped
{
    return NO;
}

@end
