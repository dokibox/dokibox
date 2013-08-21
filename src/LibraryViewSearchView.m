//
//  LibraryViewSearchView.m
//  dokibox
//
//  Created by Miles Wu on 19/08/2013.
//
//

#import "LibraryViewSearchView.h"

@implementation LibraryViewSearchView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setWantsLayer:YES];
        
        NSRect b = CGRectInset([self bounds], 3, 3);
        b.size.height -= 1;
        _searchField = [[NSSearchField alloc] initWithFrame:b];
        [[_searchField cell] setControlSize:NSSmallControlSize];
        [_searchField setFont:[NSFont fontWithName:@"Lucida Grande" size:10]];
        [self addSubview:_searchField];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redisplay) name:NSWindowDidResignKeyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redisplay) name:NSWindowDidBecomeKeyNotification object:nil];

    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    NSRect b = [self bounds];
    
    int isActive = [[self window] isMainWindow] && [[NSApplication sharedApplication] isActive];
    if(isActive)
        CGContextSetStrokeColorWithColor(ctx, [[NSColor colorWithDeviceWhite:0.7 alpha:1.0] CGColor]);
    else
        CGContextSetStrokeColorWithColor(ctx, [[NSColor colorWithDeviceWhite:0.75 alpha:1.0] CGColor]);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, b.origin.x, b.origin.y + b.size.height-0.5);
    CGContextAddLineToPoint(ctx, b.origin.x + b.size.width, b.origin.y + b.size.height-0.5);
    CGContextStrokePath(ctx);
}

- (void)redisplay
{
    [self setNeedsDisplay:YES];
}

@end
