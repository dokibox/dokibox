//
//  WindowContentView.m
//  fb2kmac
//
//  Created by Miles Wu on 05/07/2013.
//
//

#import "WindowContentView.h"
#import <TUIKit.h>
#import "LibraryView.h"
#import "PlaylistView.h"

#define bottomToolbarHeight 30.0

@implementation WindowContentView

@synthesize playlistView = _playlistView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        width_divider = 0.60;
        [self setAutoresizesSubviews:YES];
        
        CGRect libraryFrame = self.bounds;
        libraryFrame.origin.y += bottomToolbarHeight;
        libraryFrame.size.height -= bottomToolbarHeight;
        libraryFrame.size.width *= width_divider;
        TUINSView *twuiNSViewLibrary = [[TUINSView alloc] initWithFrame:libraryFrame];
        twuiNSViewLibrary.rootView = [[LibraryView alloc] initWithFrame:CGRectZero];
        [self addSubview:twuiNSViewLibrary];
        [twuiNSViewLibrary setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable | NSViewMaxXMargin];
        
        
        
        CGRect playlistFrame = self.bounds;
        playlistFrame.origin.y += bottomToolbarHeight;
        playlistFrame.size.height -= bottomToolbarHeight;
        playlistFrame.origin.x += playlistFrame.size.width*width_divider;
        playlistFrame.size.width = playlistFrame.size.width - playlistFrame.size.width*width_divider;
        
        _playlistView = [[PlaylistView alloc] initWithFrame:playlistFrame];
        [self addSubview:_playlistView];
        [_playlistView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable | NSViewMinXMargin];
        
        // triggers changing of gradients in bottom toolbar upon active/inactive window
        // also triggers on all NSWindow (not just its window) changes, but doesn't seem too ineffecient
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redisplay) name:NSWindowDidResignKeyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redisplay) name:NSWindowDidBecomeKeyNotification object:nil];
    }
    
    return self;
}

- (void)redisplay
{
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGRect b = [self bounds];
	CGContextRef ctx = TUIGraphicsGetCurrentContext();
    
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
}

@end
