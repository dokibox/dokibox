//
//  Window.m
//  dokibox
//
//  Created by Miles Wu on 14/08/2012.
//
//

#import "Window.h"

@implementation Window

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    if ((self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag])) {
        [self setMovableByWindowBackground:YES];
        [self setAutorecalculatesContentBorderThickness:NO forEdge:NSMaxYEdge];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relayout) name:NSWindowDidResizeNotification object:self];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:self];
}

- (void)relayout
{
    // Ensure content view always covers the entirety of the window
    [[self contentView] setFrame:[[[self contentView] superview] bounds]];
    
    // Move control buttons down
    NSUInteger buttonTypes[] = {NSWindowCloseButton, NSWindowMiniaturizeButton, NSWindowZoomButton};
    for(int i=0; i<3; i++) {
        NSButton *button = [self standardWindowButton:buttonTypes[i]];
        NSRect buttonframe = [button frame];
        buttonframe.origin.y = round([self frame].size.height - [self titlebarSize]/2 - buttonframe.size.height/2.0);
        [button setFrameOrigin:NSMakePoint(buttonframe.origin.x, buttonframe.origin.y)];
    }
    
    // Fix tracking areas for control buttons
    [[[self contentView] superview] viewWillStartLiveResize];
    [[[self contentView] superview] viewDidEndLiveResize];
    
    // Ensure titlebar view is positioned correctly within the content view
    if(_titlebarView)
        [_titlebarView setFrame:NSMakeRect(0, [self frame].size.height-[self titlebarSize], [self frame].size.width, [self titlebarSize]) ];
}

- (CGFloat)titlebarSize
{
    return _titlebarSize;
}

- (void)setTitlebarSize:(CGFloat)titlebarSize
{
    _titlebarSize = titlebarSize;
    [self setContentBorderThickness:titlebarSize forEdge:NSMaxYEdge];
}

- (NSView *)titlebarView
{
    return _titlebarView;
}


- (void)setTitlebarView:(NSView *)titlebarView
{
    _titlebarView = titlebarView;
    [[self contentView] addSubview:_titlebarView];
    [self relayout];
}

- (void)setContentView:(NSView *)view
{
    [super setContentView:view];
    [self relayout];
}

@end
