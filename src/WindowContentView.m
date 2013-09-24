//
//  WindowContentView.m
//  dokibox
//
//  Created by Miles Wu on 05/07/2013.
//
//

#import "WindowContentView.h"
#import "LibraryView.h"
#import "PlaylistView.h"
#import "TitlebarButtonNS.h"

#define bottomToolbarHeight 30.0

enum SearchButtonState {
    SearchButtonStateInactive,
    SearchButtonStateActive
};

@implementation WindowContentView

@synthesize playlistView = _playlistView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        width_divider = 0.60;

        _libraryView = [[LibraryView alloc] initWithFrame:[self libraryViewFrame]];
        [self addSubview:_libraryView];

        _playlistView = [[PlaylistView alloc] initWithFrame:[self playlistViewFrame]];
        [self addSubview:_playlistView];

        // new playlist button
        {
            CGRect buttonFrame = self.bounds;
            buttonFrame.origin.x += buttonFrame.size.width - 20 - 5;
            buttonFrame.size = NSMakeSize(20, 20);
            buttonFrame.origin.y += 5;
            TitlebarButtonNS *button = [[TitlebarButtonNS alloc] initWithFrame:buttonFrame];
            [button setAutoresizingMask:NSViewMinXMargin];
            [button setButtonType:NSMomentaryLightButton];
            [button setTarget:self];
            [button setAction:@selector(newPlaylistButtonPressed:)];
            [button setDrawIcon: [self newPlaylistButtonDrawRect]];
            [self addSubview:button];
        }

        {
            CGRect buttonFrame = self.bounds;
            buttonFrame.origin.x += 5;
            buttonFrame.size = NSMakeSize(20, 20);
            buttonFrame.origin.y += 5;
            _searchButton = [[TitlebarButtonNS alloc] initWithFrame:buttonFrame];
            [_searchButton setAutoresizingMask:NSViewMaxXMargin];
            [_searchButton setButtonType:NSMomentaryLightButton];
            [_searchButton setTarget:self];
            [_searchButton setAction:@selector(searchButtonPressed:)];
            [_searchButton setDrawIcon: [self searchButtonDrawRect]];
            [self addSubview:_searchButton];
        }

        // triggers changing of gradients in bottom toolbar upon active/inactive window
        // also triggers on all NSWindow (not just its window) changes, but doesn't seem too ineffecient
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redisplay) name:NSWindowDidResignKeyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redisplay) name:NSWindowDidBecomeKeyNotification object:nil];
        
        // mouse tracking for resizing handles
        [self updateDividerTrackingArea];
        
    }

    return self;
}

- (BOOL)isOpaque
{
    return YES;
}


- (void)updateDividerTrackingArea
{
    if(_dividerTrackingArea) {
        [self removeTrackingArea:_dividerTrackingArea];
    }
    
    NSRect trackingRect = [self libraryViewFrame];
    trackingRect.origin.x += [self libraryViewFrame].size.width;
    trackingRect.size.width = [self playlistViewFrame].origin.x - trackingRect.origin.x;
    trackingRect.size.width += 6.0;
    trackingRect.origin.x -= 3.0;
    
    _dividerTrackingArea = [[NSTrackingArea alloc] initWithRect:trackingRect options:NSTrackingCursorUpdate|NSTrackingActiveInKeyWindow owner:self userInfo:nil];
    [self addTrackingArea:_dividerTrackingArea];

}

-(void)cursorUpdate:(NSEvent *)event
{
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    
    if ([self mouse:point inRect:[_dividerTrackingArea rect]]) {
        [[NSCursor resizeLeftRightCursor] set];
    } else {
        [super cursorUpdate:event];
    }
}

- (NSView *)hitTest:(NSPoint)aPoint
{
    if ([self mouse:aPoint inRect:[_dividerTrackingArea rect]]) {
        return self; // Capture mouse clicks even though they are on top of other views
    }
    else {
        return [super hitTest:aPoint];
    }
}

-(void)mouseDown:(NSEvent *)event
{
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];

    if ([self mouse:point inRect:[_dividerTrackingArea rect]]) {
        _dividerBeingDragged = YES;
    }
    else {
        [super mouseDown:event];
    }
}

-(void)mouseUp:(NSEvent *)event
{
    if (_dividerBeingDragged) {
        _dividerBeingDragged = NO;
    }
    else {
        [super mouseUp:event];
    }
}


-(void)mouseDragged:(NSEvent *)event
{
    if(_dividerBeingDragged == YES) {
        NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
        width_divider = point.x/[self bounds].size.width;
        [self resizeSubviewsWithOldSize:[self bounds].size];
    }
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
    [super resizeSubviewsWithOldSize:oldBoundsSize];
    [_libraryView setFrame:[self libraryViewFrame]];
    [_playlistView setFrame:[self playlistViewFrame]];
    [self updateDividerTrackingArea];
}

-(void)performFindPanelAction:(id)sender
{
    if([_searchButton state] == SearchButtonStateInactive) {
       [_searchButton setState:SearchButtonStateActive];
    }
    [_libraryView showSearch];
}

-(void)newPlaylistButtonPressed:(id)sender
{
    [_playlistView newPlaylist];
}

-(NSViewDrawRect)newPlaylistButtonDrawRect
{
    return ^(NSView *v, CGRect rect) {
        CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
        CGRect b = v.bounds;
        CGPoint middle = CGPointMake(CGRectGetMidX(b), CGRectGetMidY(b));
        CGContextSaveGState(ctx);

        CGFloat width = 2.0;
        CGFloat height = 10.0;

        CGRect rects[] = {
            CGRectMake(middle.x - width/2.0, middle.y - height/2.0, width, height),
            CGRectMake(middle.x - height/2.0, middle.y - width/2.0, height, width)
        };
        CGContextClipToRects(ctx, rects, 2);
        NSColor *gradientEndColor = [NSColor colorWithDeviceWhite:0.15 alpha:1.0];
        NSColor *gradientStartColor = [NSColor colorWithDeviceWhite:0.45 alpha:1.0];

        NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                           (id)[gradientEndColor CGColor], nil];
        CGFloat locations[] = { 0.0, 1.0 };
        CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(middle.x, middle.y + height/2.0), CGPointMake(middle.x, middle.y - height/2.0), 0);
        CGGradientRelease(gradient);
        CGContextRestoreGState(ctx);
    };
}

-(void)searchButtonPressed:(id)sender
{
    if([_searchButton state] == SearchButtonStateInactive) {
        [_searchButton setState:SearchButtonStateActive];
        [_libraryView showSearch];
    }
    else {
        [_searchButton setState:SearchButtonStateInactive];
        [_libraryView hideSearch];
    }
}

-(NSViewDrawRect)searchButtonDrawRect
{
    return ^(NSView *v, CGRect rect) {
        CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
        CGRect b = v.bounds;
        CGContextSaveGState(ctx);

        CGFloat outer_r = 4.5;
        CGFloat inner_r = 3.0;
        CGFloat height = 20.0;
        CGFloat widthofhandle = 1.5;
        CGFloat heightofhandle = 6;
        CGFloat angle = 0.7;

        CGPoint middle = CGPointMake(CGRectGetMidX(b), CGRectGetMidY(b));
        middle.x += 2.5;
        middle.y += 2.5;
        CGContextAddArc(ctx, middle.x, middle.y, outer_r, 0, 2*pi, 0);
        CGContextAddArc(ctx, middle.x, middle.y, inner_r, 2*pi, 0, 1);

        middle.x -= outer_r*sin(angle);
        middle.y -= outer_r*cos(angle);
        CGContextMoveToPoint(ctx, middle.x + cos(angle)*widthofhandle/2.0, middle.y - sin(angle)*widthofhandle/2.0);
        CGContextAddLineToPoint(ctx, middle.x + cos(angle)*widthofhandle/2.0 - sin(angle)*heightofhandle, middle.y - sin(angle)*widthofhandle/2.0 - cos(angle)*heightofhandle);
        CGContextAddLineToPoint(ctx, middle.x - cos(angle)*widthofhandle/2.0 - sin(angle)*heightofhandle, middle.y + sin(angle)*widthofhandle/2.0 - cos(angle)*heightofhandle);
        CGContextAddLineToPoint(ctx, middle.x - cos(angle)*widthofhandle/2.0, middle.y + sin(angle)*widthofhandle/2.0);
        CGContextClosePath(ctx);


        CGContextClip(ctx);

        TitlebarButtonNS *button = (TitlebarButtonNS*)v;
        NSColor *gradientEndColor, *gradientStartColor;
        if([button state] == SearchButtonStateActive) {
            gradientEndColor = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.75 alpha:1.0];
            gradientStartColor = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.85 alpha:1.0];
        } else {
            gradientEndColor = [NSColor colorWithDeviceWhite:0.15 alpha:1.0];
            gradientStartColor = [NSColor colorWithDeviceWhite:0.45 alpha:1.0];
        }

        NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                           (id)[gradientEndColor CGColor], nil];
        CGFloat locations[] = { 0.0, 1.0 };
        CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(middle.x, middle.y + height/2.0), CGPointMake(middle.x, middle.y - height/2.0), 0);
        CGGradientRelease(gradient);
        CGContextRestoreGState(ctx);


        CGContextSaveGState(ctx);
        middle.x += outer_r*sin(angle);
        middle.y += outer_r*cos(angle);
        CGContextAddArc(ctx, middle.x, middle.y, inner_r, 0, 2*pi, 0);
        CGContextClip(ctx);
        NSColor *innerGradientEndColor = [NSColor colorWithDeviceWhite:0.8 alpha:0.75];
        NSColor *innerGradientStartColor = [NSColor colorWithDeviceWhite:1.0 alpha:0.75];

        NSArray *innerColors = [NSArray arrayWithObjects: (id)[innerGradientStartColor CGColor],
                           (id)[innerGradientEndColor CGColor], nil];
        CGGradientRef innerGradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)innerColors, locations);

        CGContextDrawLinearGradient(ctx, innerGradient, CGPointMake(middle.x - inner_r*sin(angle), middle.y + inner_r*cos(angle)), CGPointMake(middle.x + inner_r*sin(angle), middle.y - inner_r*cos(angle)), 0);
        CGGradientRelease(innerGradient);
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
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];

    // Line divider for playlist/library
    CGContextSetStrokeColorWithColor(ctx, [[NSColor colorWithDeviceWhite:0.8 alpha:1.0] CGColor]);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, b.origin.x + round(b.size.width*width_divider)+0.5, b.origin.y);
    CGContextAddLineToPoint(ctx, b.origin.x + round(b.size.width*width_divider)+0.5, b.origin.y + b.size.height);
    CGContextStrokePath(ctx);

    // Bottom bar gradient
    int isActive = [[self window] isMainWindow] && [[NSApplication sharedApplication] isActive];
    NSColor *gradientStartColor, *gradientEndColor;
    if(isActive) {
        gradientStartColor = [NSColor colorWithDeviceWhite:0.62 alpha:1.0];
        gradientEndColor = [NSColor colorWithDeviceWhite:0.90 alpha:1.0];
    }
    else {
        gradientStartColor = [NSColor colorWithDeviceWhite:0.80 alpha:1.0];
        gradientEndColor = [NSColor colorWithDeviceWhite:0.80 alpha:1.0];
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
