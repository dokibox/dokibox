//
//  Window.m
//  fb2kmac
//
//  Created by Miles Wu on 14/08/2012.
//
//

#import "Window.h"
#import "TitlebarViewNS.h"

#define TITLEBARSIZE 40

@implementation Window

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    if ((self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag])) {
        [self setMovableByWindowBackground:YES];
        
        NSView *themeFrame = [[self contentView] superview];
        NSView *firstSubview = [[themeFrame subviews] objectAtIndex:0];
        
        NSRect themeFrameRect = [themeFrame frame];
        NSRect titleFrame = NSMakeRect(0.0, NSMaxY(themeFrameRect) - TITLEBARSIZE, NSWidth(themeFrameRect), TITLEBARSIZE);
        _titlebarView = [[TitlebarViewNS alloc] initWithFrame:titleFrame];
        [themeFrame addSubview:_titlebarView positioned:NSWindowBelow relativeTo:firstSubview];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relayout) name:NSWindowDidResizeNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redisplay) name:NSWindowDidResignKeyNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redisplay) name:NSWindowDidBecomeKeyNotification object:self];
    }
    return self;
}

- (void)setContentView:(NSView *)view
{
    [super setContentView:view];
    [self relayout];
}

- (void)redisplay
{
    [_titlebarView setNeedsDisplay:YES];
}

- (void)relayout
{
    // Relayout titlebar view
    NSView *themeFrame = [[self contentView] superview];
    NSRect themeFrameRect = [themeFrame frame];
    NSRect titleFrame = NSMakeRect(0.0, NSMaxY(themeFrameRect) - TITLEBARSIZE, NSWidth(themeFrameRect), TITLEBARSIZE);
    [_titlebarView setFrame:titleFrame];
    
    // Relayout content view
    NSRect contentFrame = [[self contentView] frame];
    contentFrame.size.height = [self frame].size.height - TITLEBARSIZE;
    [[self contentView] setFrame:contentFrame];
    
    // Relayout control buttons
    NSUInteger buttonTypes[] = {NSWindowCloseButton, NSWindowMiniaturizeButton, NSWindowZoomButton};
    for(int i=0; i<3; i++) {
        NSButton *button = [self standardWindowButton:buttonTypes[i]];
        NSRect buttonframe = [button frame];
        buttonframe.origin.y = round(NSMidY([_titlebarView frame]) - buttonframe.size.height/2.0);
        [button setFrame: buttonframe];
    }
    
    // Fix tracking areas for control buttons
    [[[self contentView] superview] viewWillStartLiveResize];
    [[[self contentView] superview] viewDidEndLiveResize];
    
    /*NSArray *trackingAreas = [themeFrame trackingAreas];
    if([trackingAreas count] != 0) {
        NSTrackingArea *trackingArea = [trackingAreas objectAtIndex:0];
        NSRect trackingRect = [trackingArea rect];
        trackingRect.origin.y = NSMinY([[self standardWindowButton:buttonTypes[0]] frame]);
        
        NSTrackingArea *newTrackingArea = [[NSTrackingArea alloc] initWithRect:trackingRect options:[trackingArea options] owner:[trackingArea owner] userInfo:[NSDictionary dictionary]];
        
        [themeFrame removeTrackingArea:trackingArea];
        [themeFrame addTrackingArea:newTrackingArea];
    }*/
    
    /*[[self contentView] setNeedsDisplay:YES];
    TUINSView *tuins = [self contentView];
    [tuins setFrame:frame];
    [self setEverythingNeedsDisplay];*/
}

@end
