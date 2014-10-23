//
//  RBLClipView.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-09-14.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "RBLClipView.h"
//#import "NSColor+RBLCGColorAdditions.h" Modification by Miles Wu

@implementation RBLClipView

#pragma mark Properties

@dynamic layer;

- (NSColor *)backgroundColor {
    return [NSColor colorWithCGColor:self.layer.backgroundColor]; //[NSColor rbl_colorWithCGColor:self.layer.backgroundColor]; Modification by Miles Wu
}

- (void)setBackgroundColor:(NSColor *)color {
    self.layer.backgroundColor = [color CGColor]; //color.rbl_CGColor; Modification by Miles Wu
}

- (BOOL)isOpaque {
	return self.layer.opaque;
}

- (void)setOpaque:(BOOL)opaque {
	self.layer.opaque = opaque;
}

#pragma mark Lifecycle

- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self == nil) return nil;

	self.layer = [CAScrollLayer layer];
	self.wantsLayer = YES;

	self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawNever;

	// Matches default NSClipView settings.
	self.backgroundColor = NSColor.clearColor;
	self.opaque = NO;

	return self;
}

@end
