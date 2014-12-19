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
#import "NSView+CGDrawing.h"

#define bottomToolbarHeight 30.0
#define MINIMUM_LIBRARY_WIDTH 250
#define MINIMUM_PLAYLIST_WIDTH 150

@implementation WindowContentView

@synthesize playlistView = _playlistView;

- (id)initWithFrame:(CGRect)frame andLibrary:(Library *)library titlebarSize:(CGFloat)titlebarSize;
{
    self = [super initWithFrame:frame];
    if (self) {
        _titlebarSize = titlebarSize;
        _libraryWidth = 300;
        
        _libraryView = [[LibraryView alloc] initWithFrame:[self libraryViewFrame] andLibrary:library];
        [self addSubview:_libraryView];

        _playlistView = [[PlaylistView alloc] initWithFrame:[self playlistViewFrame] andLibrary:library];
        [self addSubview:_playlistView];

        // show playlist
        {
            CGRect buttonFrame = self.bounds;
            buttonFrame.origin.x += buttonFrame.size.width - 20 - 5;
            buttonFrame.size = NSMakeSize(20, 20);
            buttonFrame.origin.y += 5;
            _togglePlaylistButton = [[TitlebarButtonNS alloc] initWithFrame:buttonFrame];
            [_togglePlaylistButton setAutoresizingMask:NSViewMinXMargin];
            [_togglePlaylistButton setButtonType:NSMomentaryLightButton];
            [_togglePlaylistButton setTarget:self];
            [_togglePlaylistButton setAction:@selector(togglePlaylistButtonPressed:)];
            [_togglePlaylistButton setDrawIcon: [self togglePlaylistButtonDrawRect]];
            [self addSubview:_togglePlaylistButton];
        }
        
        // repeat
        {
            CGRect buttonFrame = self.bounds;
            buttonFrame.origin.x += buttonFrame.size.width - 20 - 5 - 20*1;
            buttonFrame.size = NSMakeSize(20, 20);
            buttonFrame.origin.y += 5;
            _repeatButton = [[TitlebarButtonNS alloc] initWithFrame:buttonFrame];
            [_repeatButton setAutoresizingMask:NSViewMinXMargin];
            [_repeatButton setButtonType:NSMomentaryLightButton];
            [_repeatButton setTarget:self];
            [_repeatButton bind:@"state" toObject:_playlistView withKeyPath:@"currentPlaylist.repeat" options:nil];
            [_repeatButton setAction:@selector(repeatButtonPressed:)];
            [_repeatButton setDrawIcon: [self repeatButtonDrawRect]];
            [self addSubview:_repeatButton];
        }
        
        // shuffle
        {
            CGRect buttonFrame = self.bounds;
            buttonFrame.origin.x += buttonFrame.size.width - 20 - 5 - 20*2;
            buttonFrame.size = NSMakeSize(20, 20);
            buttonFrame.origin.y += 5;
            _shuffleButton = [[TitlebarButtonNS alloc] initWithFrame:buttonFrame];
            [_shuffleButton setAutoresizingMask:NSViewMinXMargin];
            [_shuffleButton setButtonType:NSMomentaryLightButton];
            [_shuffleButton setTarget:self];
            [_shuffleButton bind:@"state" toObject:_playlistView withKeyPath:@"currentPlaylist.shuffle" options:nil];
            [_shuffleButton setAction:@selector(shuffleButtonPressed:)];
            [_shuffleButton setDrawIcon: [self shuffleButtonDrawRect]];
            [self addSubview:_shuffleButton];
        }
        
        // new playlist button
        {
            CGRect buttonFrame = self.bounds;
            buttonFrame.origin.x += buttonFrame.size.width - 20 - 5 - 20*3;
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
            [_searchButton bind:@"state" toObject:_libraryView withKeyPath:@"searchVisible" options:nil];
            [_searchButton setAction:@selector(searchButtonPressed:)];
            [_searchButton setDrawIcon: [self searchButtonDrawRect]];
            [self addSubview:_searchButton];
        }

        // triggers changing of gradients in bottom toolbar upon active/inactive window
        // also triggers on all NSWindow (not just its window) changes, but doesn't seem too ineffecient
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redisplay) name:NSWindowDidResignKeyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redisplay) name:NSWindowDidBecomeKeyNotification object:nil];
        
        // Window resize handler
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:[self window]];
        
        // mouse tracking for resizing handles
        [self updateDividerTrackingArea];
        
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:[self window]];
}

- (void)updateDividerTrackingArea
{
    if(_dividerTrackingArea) {
        [self removeTrackingArea:_dividerTrackingArea];
    }
    
    NSRect trackingRect = [self libraryViewFrame];
    trackingRect.origin.x += [self libraryViewFrame].size.width + 0.5;
    trackingRect.size.width = 10.0;
    trackingRect.origin.x -= 5.0;
    
    _dividerTrackingArea = [[NSTrackingArea alloc] initWithRect:trackingRect options:NSTrackingCursorUpdate|NSTrackingActiveInKeyWindow owner:self userInfo:nil];
    [self addTrackingArea:_dividerTrackingArea];

}

-(void)cursorUpdate:(NSEvent *)event
{
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    
    if (_dividerBeingDragged == YES || [self mouse:point inRect:[_dividerTrackingArea rect]]) {
        [[NSCursor resizeLeftRightCursor] set];
    } else {
        [super cursorUpdate:event];
    }
}

- (NSView *)hitTest:(NSPoint)aPoint
{
    NSPoint point = [self convertPoint:aPoint fromView:[self superview]]; // convert to our coordinate system
    if ([self mouse:point inRect:[_dividerTrackingArea rect]]) {
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
        point.x = round(point.x);
        
        // minimum size for libraryFrame
        if(point.x < MINIMUM_LIBRARY_WIDTH)
            point.x = MINIMUM_LIBRARY_WIDTH;
        // minimum size for playlistFrame
        else if(([self bounds].size.width - point.x) < MINIMUM_PLAYLIST_WIDTH)
            point.x = [self bounds].size.width - MINIMUM_PLAYLIST_WIDTH;
        
        _libraryWidth = point.x;
        [self resizeSubviewsWithOldSize:[self bounds].size];
    }
}



-(NSRect)libraryViewFrame
{
    CGRect libraryFrame = self.bounds;
    libraryFrame.origin.y += bottomToolbarHeight;
    libraryFrame.size.height -= bottomToolbarHeight + _titlebarSize;
    libraryFrame.size.width = _libraryWidth;
    return libraryFrame;
}

-(NSRect)playlistViewFrame;
{
    CGRect playlistFrame = self.bounds;
    playlistFrame.origin.y += bottomToolbarHeight;
    playlistFrame.size.height -= bottomToolbarHeight + _titlebarSize;
    playlistFrame.origin.x += _libraryWidth + 1.0;
    playlistFrame.size.width = playlistFrame.size.width - _libraryWidth - 1.0;
    return playlistFrame;
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize
{
    [super resizeSubviewsWithOldSize:oldBoundsSize];
    [_libraryView setFrame:[self libraryViewFrame]];
    [_playlistView setFrame:[self playlistViewFrame]];
    [self updateDividerTrackingArea];
}

- (void)windowDidResize:(NSNotification *)notification
{
    // Make sure playlist frame doesn't become too small upon resize
    // No need to check library frame as MINIMUM_LIBRARY_WIDTH + MINIMUM_PLAYLIST_WIDTH < MINIMUM_WINDOW_WIDTH
    if([self playlistViewFrame].size.width < MINIMUM_PLAYLIST_WIDTH) {
        _libraryWidth = [self bounds].size.width - MINIMUM_PLAYLIST_WIDTH;
    }
}

-(void)performFindPanelAction:(id)sender
{
    if([_searchButton state] == NSOffState) {
       [_searchButton setState:NSOnState];
    }
    [_libraryView setSearchVisible:YES];
}

-(void)newPlaylistButtonPressed:(id)sender
{
    [_playlistView newPlaylist];
    if([_togglePlaylistButton state] == NSOffState) {
        [_togglePlaylistButton setState:NSOnState];
    }
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
    [_libraryView setSearchVisible:![_libraryView searchVisible]];
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
        if([button state] == NSOnState) {
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

-(NSViewDrawRect)togglePlaylistButtonDrawRect
{
    return ^(NSView *v, CGRect rect) {
        CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
        CGRect b = v.bounds;
        CGPoint middle = CGPointMake(CGRectGetMidX(b), CGRectGetMidY(b));
        CGFloat halfHeight = 7;
        
        CGContextMoveToPoint(ctx, 14, 5);
        CGContextAddLineToPoint(ctx, 6, 5);
        CGContextAddLineToPoint(ctx, 6, 15);
        CGContextAddLineToPoint(ctx, 14, 15);
        CGContextMoveToPoint(ctx, 4.25, 16.75);
        CGContextAddLineToPoint(ctx, 4.25, 3.25);
        CGContextAddLineToPoint(ctx, 15.75, 3.25);
        CGContextAddLineToPoint(ctx, 15.75, 16.75);
        CGContextMoveToPoint(ctx, 12, 7.75);
        CGContextAddLineToPoint(ctx, 13, 7.75);
        CGContextAddLineToPoint(ctx, 13, 6);
        CGContextAddLineToPoint(ctx, 12, 6);
        CGContextMoveToPoint(ctx, 7, 6);
        CGContextAddLineToPoint(ctx, 7, 7.75);
        CGContextAddLineToPoint(ctx, 11, 7.75);
        CGContextAddLineToPoint(ctx, 11, 6);
        CGContextMoveToPoint(ctx, 12, 10.75);
        CGContextAddLineToPoint(ctx, 12, 9);
        CGContextAddLineToPoint(ctx, 13, 9);
        CGContextAddLineToPoint(ctx, 13, 10.75);
        CGContextMoveToPoint(ctx, 7, 10.75);
        CGContextAddLineToPoint(ctx, 7, 9);
        CGContextAddLineToPoint(ctx, 11, 9);
        CGContextAddLineToPoint(ctx, 11, 10.75);
        CGContextMoveToPoint(ctx, 12, 13.75);
        CGContextAddLineToPoint(ctx, 13, 13.75);
        CGContextAddLineToPoint(ctx, 13, 12);
        CGContextAddLineToPoint(ctx, 12, 12);
        CGContextMoveToPoint(ctx, 7, 12);
        CGContextAddLineToPoint(ctx, 7, 13.75);
        CGContextAddLineToPoint(ctx, 11, 13.75);
        CGContextAddLineToPoint(ctx, 11, 12);

        CGContextClosePath(ctx);
        
        CGContextClip(ctx);
        
        TitlebarButtonNS *button = (TitlebarButtonNS*)v;
        NSColor *gradientEndColor, *gradientStartColor;
        if([button state] == NSOnState) {
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
        
        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(middle.x, middle.y + halfHeight), CGPointMake(middle.x, middle.y - halfHeight), 0);
        CGGradientRelease(gradient);
    };
}

-(void)togglePlaylistButtonPressed:(id)sender
{
    if([_togglePlaylistButton state] == NSOffState) {
        [_togglePlaylistButton setState:NSOnState];
        [_playlistView setPlaylistVisiblity:YES];
    }
    else {
        [_togglePlaylistButton setState:NSOffState];
        [_playlistView setPlaylistVisiblity:NO];
    }
}

-(NSViewDrawRect)repeatButtonDrawRect
{
    return ^(NSView *v, CGRect rect) {
        CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
        CGRect b = v.bounds;
        CGPoint middle = CGPointMake(CGRectGetMidX(b), CGRectGetMidY(b));
        CGFloat halfHeight = 7;

        CGContextMoveToPoint(ctx, 14.92, 9.22);
        CGContextAddCurveToPoint(ctx, 14.54, 6.83, 12.49, 5, 10, 5);
        CGContextAddCurveToPoint(ctx, 8.36, 5, 6.93, 5.8, 6.02, 7.01);
        CGContextAddLineToPoint(ctx, 9, 7);
        CGContextAddLineToPoint(ctx, 3, 10);
        CGContextAddCurveToPoint(ctx, 3, 6.14, 6.14, 3, 10, 3);
        CGContextAddCurveToPoint(ctx, 13.33, 3, 16.12, 5.34, 16.82, 8.46);
        CGContextMoveToPoint(ctx, 17, 10);
        CGContextAddCurveToPoint(ctx, 17, 13.86, 13.86, 17, 10, 17);
        CGContextAddCurveToPoint(ctx, 6.67, 17, 3.88, 14.66, 3.18, 11.54);
        CGContextAddLineToPoint(ctx, 5.08, 10.78);
        CGContextAddCurveToPoint(ctx, 5.46, 13.17, 7.51, 15, 10, 15);
        CGContextAddCurveToPoint(ctx, 11.64, 15, 13.07, 14.2, 13.98, 12.99);
        CGContextAddLineToPoint(ctx, 11, 13);
        CGContextClosePath(ctx);
        
        CGContextClip(ctx);
        
        TitlebarButtonNS *button = (TitlebarButtonNS*)v;
        NSColor *gradientEndColor, *gradientStartColor;
        if([button state] == NSOnState) {
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
        
        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(middle.x, middle.y + halfHeight), CGPointMake(middle.x, middle.y - halfHeight), 0);
        CGGradientRelease(gradient);
    };
}

-(void)repeatButtonPressed:(id)sender
{
    [[_playlistView currentPlaylist] setRepeat:![[_playlistView currentPlaylist] repeat]];
}

-(NSViewDrawRect)shuffleButtonDrawRect
{
    return ^(NSView *v, CGRect rect) {
        CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
        CGRect b = v.bounds;
        CGPoint middle = CGPointMake(CGRectGetMidX(b), CGRectGetMidY(b));
        CGFloat halfHeight = 7;

        CGContextMoveToPoint(ctx, 3, 13);
        CGContextAddLineToPoint(ctx, 5.5, 13);
        CGContextAddCurveToPoint(ctx, 8.88, 13, 9, 5, 13, 5);
        CGContextAddLineToPoint(ctx, 14, 5);
        CGContextAddLineToPoint(ctx, 14, 3.5);
        CGContextAddLineToPoint(ctx, 18, 6);
        CGContextAddLineToPoint(ctx, 14, 8.5);
        CGContextAddLineToPoint(ctx, 14, 7);
        CGContextAddLineToPoint(ctx, 13.07, 7);
        CGContextAddCurveToPoint(ctx, 10, 7, 10, 15, 5.5, 15);
        CGContextAddLineToPoint(ctx, 3, 15);
        CGContextMoveToPoint(ctx, 7.64, 8.41);
        CGContextAddCurveToPoint(ctx, 7.06, 7.58, 6.4, 7, 5.5, 7);
        CGContextAddLineToPoint(ctx, 3, 7);
        CGContextAddLineToPoint(ctx, 3, 5);
        CGContextAddLineToPoint(ctx, 5.5, 5);
        CGContextAddCurveToPoint(ctx, 6.84, 5, 7.77, 5.71, 8.51, 6.71);
        CGContextAddCurveToPoint(ctx, 8.19, 7.27, 7.9, 7.85, 7.64, 8.41);
        CGContextMoveToPoint(ctx, 11.17, 11.66);
        CGContextAddCurveToPoint(ctx, 11.69, 12.46, 12.27, 13, 13.07, 13);
        CGContextAddLineToPoint(ctx, 14, 13);
        CGContextAddLineToPoint(ctx, 14, 11.5);
        CGContextAddLineToPoint(ctx, 18, 14);
        CGContextAddLineToPoint(ctx, 14, 16.5);
        CGContextAddLineToPoint(ctx, 14, 15);
        CGContextAddLineToPoint(ctx, 13, 15);
        CGContextAddCurveToPoint(ctx, 11.82, 15, 10.98, 14.3, 10.3, 13.32);
        CGContextAddCurveToPoint(ctx, 10.63, 12.77, 10.91, 12.2, 11.17, 11.66);
        CGContextClosePath(ctx);
        
        CGContextClip(ctx);

        TitlebarButtonNS *button = (TitlebarButtonNS*)v;
        NSColor *gradientEndColor, *gradientStartColor;
        if([button state] == NSOnState) {
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
        
        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(middle.x, middle.y + halfHeight), CGPointMake(middle.x, middle.y - halfHeight), 0);
        CGGradientRelease(gradient);
    };
}

-(void)shuffleButtonPressed:(id)sender
{
    [[_playlistView currentPlaylist] setShuffle:![[_playlistView currentPlaylist] shuffle]];
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
    CGFloat trackTableHeaderHeight = 17.0;
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, [[NSColor colorWithDeviceWhite:.71372549 alpha:1.0] CGColor]);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, b.origin.x + _libraryWidth+0.5, b.origin.y);
    CGContextAddLineToPoint(ctx, b.origin.x + _libraryWidth+0.5, b.origin.y + b.size.height - trackTableHeaderHeight - _titlebarSize);
    CGContextStrokePath(ctx);
    NSColor *gradientStartColor, *gradientEndColor; //Gradient for track table header as top line is darker
    gradientStartColor = [NSColor colorWithDeviceWhite:TRACK_TABLEVIEW_HEADER_BOTTOM_COLOR alpha:1.0];
    gradientEndColor = [NSColor colorWithDeviceWhite:TRACK_TABLEVIEW_HEADER_TOP_COLOR alpha:1.0];
    [self CGContextVerticalGradient:NSMakeRect(b.origin.x + _libraryWidth-0.5, b.origin.y + b.size.height - _titlebarSize - trackTableHeaderHeight, 1, 17.0) context:ctx bottomColor:gradientStartColor topColor:gradientEndColor];
    
    // Bottom bar gradient
    int isActive = [[self window] isMainWindow] && [[NSApplication sharedApplication] isActive];
    if(isActive) {
        gradientStartColor = [NSColor colorWithDeviceWhite:0.62 alpha:1.0];
        gradientEndColor = [NSColor colorWithDeviceWhite:0.90 alpha:1.0];
    }
    else {
        gradientStartColor = [NSColor colorWithDeviceWhite:0.87 alpha:1.0];
        gradientEndColor = [NSColor colorWithDeviceWhite:0.97 alpha:1.0];
    }

    NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                       (id)[gradientEndColor CGColor], nil];
    CGFloat locations[] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(b.origin.x, b.origin.y), CGPointMake(b.origin.x, b.origin.y+bottomToolbarHeight), 0);
    CGGradientRelease(gradient);

    // Line divider for bottom
    CGContextSetStrokeColorWithColor(ctx, [[NSColor colorWithDeviceWhite:TRACK_TABLEVIEW_HEADER_BOTTOM_COLOR alpha:1.0] CGColor]);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, b.origin.x, b.origin.y + bottomToolbarHeight-0.5);
    CGContextAddLineToPoint(ctx, b.origin.x + b.size.width, b.origin.y + bottomToolbarHeight-0.5);
    CGContextStrokePath(ctx);
}

@end
