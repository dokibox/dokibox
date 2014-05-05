//
//  SliderBar.m
//  dokibox
//
//  Created by Miles Wu on 11/10/2012.
//
//

#import "SliderBar.h"

@implementation SliderBar

@synthesize percentage = _percentage;
@synthesize movable = _movable;
@synthesize hoverable = _hoverable;
@synthesize drawHandle = _drawHandle;
@synthesize delegate = _delegate;
@synthesize dragable = _dragable;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _percentage = 0.0;
    }

    // Mouse tracking for hovers
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow | NSTrackingInVisibleRect owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];

    return self;
}

-(BOOL)isOpaque {
    return YES;
}

-(float)convertMouseEventToPercentage:(NSEvent *)event
{
    NSPoint event_location = [event locationInWindow];
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    float p = local_point.x / [self bounds].size.width;
    
    if(p < 0) {
        p = 0;
    }
    else if(p > 1) {
        p = 1;
    }

    return p;
}

-(void)mouseEntered:(NSEvent *)event
{
    if(_hoverable != YES)
        return;

    NSPoint event_location = [event locationInWindow];
    NSPoint screen_location = [[self window] convertBaseToScreen:event_location];
    NSLog(@"entered at %f %f", screen_location.x, screen_location.y);

    float width = 40;
    float height = 50;
    NSRect contentRect = NSMakeRect(0, 0, width, height);
    NSRect frame = contentRect;

    _hoverWindow = [[NSWindow alloc] initWithContentRect: contentRect
                                               styleMask: NSBorderlessWindowMask
                                                 backing: NSBackingStoreBuffered
                                                   defer: NO];
    [_hoverWindow setHidesOnDeactivate:YES];
    [_hoverWindow setReleasedWhenClosed:NO];
    [_hoverWindow setOpaque:NO];
    [_hoverWindow setIgnoresMouseEvents:YES];
    //[_hoverWindow setAlphaValue:0.80];
    [_hoverWindow setBackgroundColor:[NSColor colorWithDeviceRed:1.0 green:0.96 blue:0.76 alpha:0.0]];
    [_hoverWindow setHasShadow:YES];
    [_hoverWindow setLevel:NSStatusWindowLevel];

    _hoverView = [[SliderBarHoverView alloc] initWithFrame:frame];
    [_hoverWindow setContentView:_hoverView];
    [_hoverWindow orderFront:nil];

    [self mouseMoved:event];
}

-(void)mouseExited:(NSEvent *)event
{
    if(_hoverable != YES)
        return;
    
    if(_inDrag == YES) // Prevent hover from disappearing during drag
        return;

    NSPoint event_location = [event locationInWindow];
    NSPoint screen_location = [[self window] convertBaseToScreen:event_location];
    NSLog(@"exited at %f %f", screen_location.x, screen_location.y);

    [_hoverWindow close];
    _hoverWindow = nil;
    _hoverView = nil;
}

-(void)mouseMoved:(NSEvent *)event
{
    // Update hover window
    if(_hoverable != YES)
        return;

    NSPoint event_location = [event locationInWindow];
    NSPoint pointInView = [self convertPoint:[event locationInWindow] fromView:nil];
    
    // Clip location so that it is not left of 0% or right of 100%
    if(pointInView.x < 0 ) {
        event_location.x = [self convertPoint:[self bounds].origin toView:nil].x;
    }
    else if(pointInView.x > [self bounds].size.width) {
        NSPoint p = [self bounds].origin;
        p.x += [self bounds].size.width;
        event_location.x = [self convertPoint:p toView:nil].x;
    }
    
    NSPoint window_location_of_topbar = [self convertPoint:NSMakePoint(0.0, [self frame].size.height) toView:nil];
    event_location.y = window_location_of_topbar.y + [_hoverWindow frame].size.height; // window_location_of_bottombar.y; //;
    event_location.x -= 0.5*[_hoverWindow frame].size.width;

    NSPoint screen_location = [[self window] convertBaseToScreen:event_location];
    [_hoverWindow setFrameTopLeftPoint:screen_location];

    float p = [self convertMouseEventToPercentage:event];
    NSString *str;
    if(_delegate) {
        str = [_delegate sliderBar:self textForHoverAt:p];
    }
    else {
        str = [[NSString alloc] initWithFormat:@"%.0f%%", p*100.0];
    }
    [_hoverView setStringValue:str];
    [_hoverView setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event
{
    // Set slider and also begin drag
    if(_movable != YES)
        return;
    
    float p = [self convertMouseEventToPercentage:event];
    [self setPercentage:p];
    [self sendNewPercentageToDelegate];

    if(_dragable == YES) {
        _inDrag = YES;
        if(_delegate) {
            [_delegate sliderBarDidBeginDrag:[NSNotification notificationWithName:@"SliderBarDidBeginDrag" object:self]];
        }
    }
    else {
    }
}

- (void)mouseUp:(NSEvent *)event
{
    // End drag
    if(_inDrag == YES) {
        _inDrag = NO;
        NSPoint pointInView = [self convertPoint:[event locationInWindow] fromView:nil];
        if([self mouse:pointInView inRect:[self bounds]] == NO) {
            // mouse exited during drag so need to remove hover
            [self mouseExited:event];
        }
    }
    
    if(_movable != YES)
        return;
    
    if(_dragable == YES) {
        if(_delegate) {
            [_delegate sliderBarDidEndDrag:[NSNotification notificationWithName:@"SliderBarDidEndDrag" object:self]];
        }
    }
}

-(void)mouseDragged:(NSEvent *)event
{
    // Update during drag
    if(_dragable != YES || _movable != YES)
        return;
    
    float p = [self convertMouseEventToPercentage:event];
    [self setPercentage:p];
    [self sendNewPercentageToDelegate];
    [self mouseMoved:event]; //Update hover window
}

-(void)sendNewPercentageToDelegate
{
    if(!_delegate)
        return;
    
    NSNumber *percentage = [NSNumber numberWithFloat:[self percentage]];
    NSNotification *notification = [NSNotification notificationWithName:@"SliderBarMoved" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:percentage, @"percentage", nil]];
    [_delegate sliderBarDidMove:notification];
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGRect b = [self bounds];
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];

    // Draw bar
    NSColor *gradientStartColor, *gradientEndColor;
    gradientStartColor = [NSColor colorWithDeviceWhite:0.77 alpha:1.0];
    gradientEndColor = [NSColor colorWithDeviceWhite:0.82 alpha:1.0];

    NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                       (id)[gradientEndColor CGColor], nil];
    CGFloat locations[] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(b.origin.x, b.origin.y), CGPointMake(b.origin.x/*+b.size.width*/, b.origin.y+b.size.height), 0);
    CGGradientRelease(gradient);


    // Draw darkened completed area
    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 0.2);
    CGRect progressrect = b;
    progressrect.size.width *= _percentage;
    CGContextFillRect(ctx, progressrect);

    // Draw inner drop shadow
    CGMutablePathRef shadowpath = CGPathCreateMutable();
    CGPathAddRect(shadowpath, NULL, CGRectInset(b, -10, -10));
    CGPathAddRect(shadowpath, NULL, b);
    CGPathCloseSubpath(shadowpath);

    CGContextSaveGState(ctx);
    CGContextAddRect(ctx, b);
    CGContextClip(ctx);

    NSColor *shadowcolor = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.7];
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, -1), 5, [shadowcolor CGColor]);
    CGContextSetRGBFillColor(ctx, 1.0, 0.0, 0.0, 0.5);
    CGContextAddPath(ctx, shadowpath);

    CGContextEOFillPath(ctx);
    CGContextRestoreGState(ctx);
    CGPathRelease(shadowpath);

    // Draw Handle
    if(_drawHandle) {

    }
}

-(void)setPercentage:(float)percentage {
    _percentage = percentage;
    [self setNeedsDisplay:YES];
}

@end
