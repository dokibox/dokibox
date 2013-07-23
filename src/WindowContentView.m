//
//  WindowContentView.m
//  dokibox
//
//  Created by Miles Wu on 05/07/2013.
//
//

#import "WindowContentView.h"
#import <TUIKit.h>
#import "LibraryView.h"
#import "PlaylistView.h"
#import "TitlebarButtonNS.h"

#define bottomToolbarHeight 30.0

@implementation WindowContentView

@synthesize playlistView = _playlistView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        width_divider = 0.60;

        _twuiNSViewLibrary = [[TUINSView alloc] initWithFrame:[self libraryViewFrame]];
        _twuiNSViewLibrary.rootView = [[LibraryView alloc] initWithFrame:CGRectZero];
        [self addSubview:_twuiNSViewLibrary];

        _playlistView = [[PlaylistView alloc] initWithFrame:[self playlistViewFrame]];
        [self addSubview:_playlistView];

        CGRect buttonFrame = self.bounds;
        buttonFrame.origin.x += buttonFrame.size.width - 20 - 10;
        buttonFrame.size = NSMakeSize(20, 20);
        buttonFrame.origin.y += 5;
        TitlebarButtonNS *button = [[TitlebarButtonNS alloc] initWithFrame:buttonFrame];
        [button setAutoresizingMask:NSViewMinXMargin];
        [button setButtonType:NSMomentaryLightButton];
        [button setTarget:self];
        [button setAction:@selector(newPlaylistButtonPressed:)];
        [button setDrawIcon: [self newPlaylistButtonDrawRect]];
        [self addSubview:button];

        // triggers changing of gradients in bottom toolbar upon active/inactive window
        // also triggers on all NSWindow (not just its window) changes, but doesn't seem too ineffecient
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redisplay) name:NSWindowDidResignKeyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redisplay) name:NSWindowDidBecomeKeyNotification object:nil];
    }

    return self;
}

-(NSRect)libraryViewFrame
{
    CGRect libraryFrame = self.bounds;
    libraryFrame.origin.y += bottomToolbarHeight;
    libraryFrame.size.height -= bottomToolbarHeight;
    libraryFrame.size.width = round(self.bounds.size.width * width_divider);
    return libraryFrame;
}

-(NSRect)playlistViewFrame;
{
    CGRect playlistFrame = self.bounds;
    playlistFrame.origin.y += bottomToolbarHeight;
    playlistFrame.size.height -= bottomToolbarHeight;
    playlistFrame.origin.x += round(playlistFrame.size.width * width_divider) + 1.0;
    playlistFrame.size.width = playlistFrame.size.width - round(self.bounds.size.width * width_divider) - 1.0;
    return playlistFrame;
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize
{
    [_twuiNSViewLibrary setFrame:[self libraryViewFrame]];
    [_playlistView setFrame:[self playlistViewFrame]];
}

-(void)newPlaylistButtonPressed:(id)sender
{
    [_playlistView newPlaylist];
}

-(NSViewDrawRect)newPlaylistButtonDrawRect
{
    return ^(NSView *v, CGRect rect) {
        CGContextRef ctx = TUIGraphicsGetCurrentContext();
        CGRect b = v.bounds;
        CGPoint middle = CGPointMake(CGRectGetMidX(b), CGRectGetMidY(b));
        CGContextSaveGState(ctx);

        CGFloat width = 3.0;
        CGFloat height = 10.0;

        CGRect rects[] = {
            CGRectMake(middle.x - width/2.0, middle.y - height/2.0, width, height),
            CGRectMake(middle.x - height/2.0, middle.y - width/2.0, height, width)
        };
        CGContextClipToRects(ctx, rects, 2);
        TUIColor *gradientEndColor = [TUIColor colorWithWhite:0.15 alpha:1.0];
        TUIColor *gradientStartColor = [TUIColor colorWithWhite:0.45 alpha:1.0];

        NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                           (id)[gradientEndColor CGColor], nil];
        CGFloat locations[] = { 0.0, 1.0 };
        CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(middle.x, middle.y + height/2.0), CGPointMake(middle.x, middle.y - height/2.0), 0);
        CGGradientRelease(gradient);
        CGContextRestoreGState(ctx);
    };
}

- (void)redisplay
{
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGRect b = [self bounds];
	CGContextRef ctx = TUIGraphicsGetCurrentContext();
    
    // Line divider for playlist/library
    CGContextSetStrokeColorWithColor(ctx, [[NSColor colorWithDeviceWhite:0.8 alpha:1.0] CGColor]);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, b.origin.x + round(b.size.width*width_divider)+0.5, b.origin.y);
    CGContextAddLineToPoint(ctx, b.origin.x + round(b.size.width*width_divider)+0.5, b.origin.y + b.size.height);
    CGContextStrokePath(ctx);
        
    // Bottom bar gradient
    int isActive = [[self window] isMainWindow] && [[NSApplication sharedApplication] isActive];
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
    
    // Line divider for bottom
    if(isActive)
        CGContextSetStrokeColorWithColor(ctx, [[NSColor colorWithDeviceWhite:0.7 alpha:1.0] CGColor]);
    else
        CGContextSetStrokeColorWithColor(ctx, [[NSColor colorWithDeviceWhite:0.75 alpha:1.0] CGColor]);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, b.origin.x, b.origin.y + bottomToolbarHeight-0.5);
    CGContextAddLineToPoint(ctx, b.origin.x + b.size.width, b.origin.y + bottomToolbarHeight-0.5);
    CGContextStrokePath(ctx);
}

@end
