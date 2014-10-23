//
//  Window.m
//  dokibox
//
//  Created by Miles Wu on 14/08/2012.
//
//

#import "Window.h"


@implementation Window
@synthesize titlebarSize = _titlebarSize;

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    if ((self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag])) {
        [self setMovableByWindowBackground:YES];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relayout) name:NSWindowDidResizeNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redisplay) name:NSWindowDidResignKeyNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redisplay) name:NSWindowDidBecomeKeyNotification object:self];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignKeyNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeKeyNotification object:self];
}

- (NSView *)titlebarView
{
    return _titlebarView;
}

- (void)setTitlebarView:(NSView *)view
{
    NSView *themeFrame = [[self contentView] superview];
    NSView *firstSubview = [[themeFrame subviews] objectAtIndex:0];

    _titlebarView = view;
    NSRect themeFrameRect = [themeFrame frame];
    NSRect titleFrame = NSMakeRect(0.0, NSMaxY(themeFrameRect) - _titlebarSize, NSWidth(themeFrameRect), _titlebarSize);
    [_titlebarView setFrame:titleFrame];
    [_titlebarView setAutoresizingMask:NSViewWidthSizable];

    // This function emits a warning on OSX 10.10+ (NSWindow warning: adding an unknown subview)
    // There does not seem to be a workaround, so we just supress the warning temporarily by redirecting stderr
    if([NSTitlebarAccessoryViewController class]) { //OSX 10.10+
        int stderr_copy = dup(fileno(stderr));
        freopen("/dev/null", "w", stderr);
        [themeFrame addSubview:_titlebarView positioned:NSWindowBelow relativeTo:firstSubview];
        dup2(stderr_copy, fileno(stderr));
        close(stderr_copy);
    }
    else {
        [themeFrame addSubview:_titlebarView positioned:NSWindowBelow relativeTo:firstSubview];
    }
    
    if([NSTitlebarAccessoryViewController class]) {
        // We are on OSX 10.10+. Let it expand the titlebar using an accessory view so we don't have to draw it ourselves in TitlebarViewNS
        NSTitlebarAccessoryViewController *titlebarAccessoryViewController = [[NSTitlebarAccessoryViewController alloc] initWithNibName:nil bundle:nil];
        NSView *emptyView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, [self frame].size.width, [self titlebarSize]-21.0)]; // 21 just seems to work
        [titlebarAccessoryViewController setView:emptyView];
        [self addTitlebarAccessoryViewController:titlebarAccessoryViewController];
    }
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

- (CGFloat)contentViewHeight
{
    return [self frame].size.height - _titlebarSize;
}

- (void)relayout
{
    if(_titlebarView == nil) return;

    // Relayout titlebar view
    NSView *themeFrame = [[self contentView] superview];
    NSRect themeFrameRect = [themeFrame frame];
    NSRect titleFrame = NSMakeRect(0.0, NSMaxY(themeFrameRect) - _titlebarSize, NSWidth(themeFrameRect), _titlebarSize);
    [_titlebarView setFrame:titleFrame];

    // Relayout content view
    NSRect contentFrame = [[self contentView] frame];
    contentFrame.size.height = [self contentViewHeight];
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
