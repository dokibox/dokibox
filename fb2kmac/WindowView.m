//
//  WindowView.m
//  fb2kmac
//
//  Created by Miles Wu on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WindowView.h"
#import "LibraryView.h"
#import "LibraryTrack.h"

#import "CoreDataManager.h"

@implementation WindowView

@synthesize playlistView = _playlistView;

#define bottomToolbarHeight 30.0

- (id)initWithFrame:(CGRect)frame
{
	if((self = [super initWithFrame:frame])) {
        // triggers changing of gradients in bottom toolbar upon active/inactive window
        // also triggers on all NSWindow (not just its window) changes, but doesn't seem too ineffecient
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redisplay) name:NSWindowDidResignKeyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redisplay) name:NSWindowDidBecomeKeyNotification object:nil];
        
        width_divider = 0.60;
                
        __block typeof(self) bself = self;

        LibraryView *libraryView = [[LibraryView alloc] initWithFrame:CGRectZero];
        libraryView.layout = ^(TUIView *v) {
            CGRect b = v.superview.bounds;
            b.size.height -= bottomToolbarHeight;
            b.origin.y += bottomToolbarHeight;
            
            CGRect libraryFrame = b;
            libraryFrame.size.width = (int)(width_divider*b.size.width);
            return libraryFrame;
        };
        [self addSubview:libraryView];
        
        _playlistView = [[PlaylistView alloc] initWithFrame:CGRectZero];
        _playlistView.layout = ^(TUIView *v) {
            CGRect b = v.superview.bounds;
            b.size.height -= bottomToolbarHeight;
            b.origin.y += bottomToolbarHeight;
            
            CGRect playlistFrame = b;
            playlistFrame.origin.x += (int)(bself->width_divider*b.size.width);
            playlistFrame.size.width = b.size.width - (int)(bself->width_divider*b.size.width);
            return playlistFrame;
        };
        [self addSubview:_playlistView];
	}
	return self;
}

- (void)redisplay
{
    [self setNeedsDisplay];
}

- (void)drawRect:(NSRect)rect
{
    NSLog(@"gi");
    CGRect b = [self bounds];
	CGContextRef ctx = TUIGraphicsGetCurrentContext();
    
    int isActive = [[self nsWindow] isMainWindow] && [[NSApplication sharedApplication] isActive];
    TUIColor *gradientStartColor, *gradientEndColor;
    if(isActive) {
        gradientStartColor = [TUIColor colorWithWhite:0.62 alpha:1.0];
        gradientEndColor = [TUIColor colorWithWhite:0.90 alpha:1.0];
    }
    else {
        gradientStartColor = [TUIColor colorWithWhite:0.80 alpha:1.0];
        gradientEndColor = [TUIColor colorWithWhite:0.80 alpha:1.0];
    }
    
    NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                       (id)[gradientEndColor CGColor], nil];
    CGFloat locations[] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);
    
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(b.origin.x, b.origin.y), CGPointMake(b.origin.x, b.origin.y+bottomToolbarHeight), 0);
    CGGradientRelease(gradient);
}


@end
