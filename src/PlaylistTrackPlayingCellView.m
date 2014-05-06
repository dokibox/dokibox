//
//  PlaylistTrackPlayingCellView.m
//  dokibox
//
//  Created by Miles Wu on 15/12/2013.
//
//

#import "PlaylistTrackPlayingCellView.h"
#import "PlaylistTrack.h"

@implementation PlaylistTrackPlayingCellView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)dealloc
{
    [self setTrack:nil]; //clear out observers and binds
}

-(PlaylistTrack *)track
{
    return _track;
}

- (void)setTrack:(PlaylistTrack *)track
{
    if(_track) {
        [_track removeObserver:self forKeyPath:@"playbackStatus"];
        [_track removeObserver:self forKeyPath:@"hasErrorOpeningFile"];
    }
    
    _track = track;
    [_track addObserver:self forKeyPath:@"playbackStatus" options:NSKeyValueObservingOptionNew context:NULL];
    [_track addObserver:self forKeyPath:@"hasErrorOpeningFile" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath compare:@"playbackStatus"] == NSOrderedSame || [keyPath compare:@"hasErrorOpeningFile"] == NSOrderedSame) {
        [self setNeedsDisplay:YES];
    }
}


- (void)drawRect:(NSRect)dirtyRect
{
    if([[self track] playbackStatus] != MusicControllerPlaying && [[self track] playbackStatus] != MusicControllerPaused && [[self track] hasErrorOpeningFile] != YES) return;
    
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGRect b = [self bounds];
    CGPoint middle = CGPointMake(CGRectGetMidX(b), CGRectGetMidY(b));
    middle.x += 2; // left offset
    CGContextSaveGState(ctx);
    
    float size = 5.5;
    float gradient_height;
    
    // This is mostly copied from TitlebarViewNS.m (perhaps dedup this sometime)
    if([[self track] hasErrorOpeningFile]) {
        float radius = 1.5;
        
        CGContextAddArc(ctx, middle.x, middle.y - 4.5, radius, 0, 2*pi, 0);
        CGContextMoveToPoint(ctx, middle.x - radius, middle.y - 2);
        CGContextAddLineToPoint(ctx, middle.x - radius, middle.y + 6);
        CGContextAddLineToPoint(ctx, middle.x + radius, middle.y + 6);
        CGContextAddLineToPoint(ctx, middle.x + radius, middle.y - 2);
        CGContextClip(ctx);
        gradient_height = 6.0;
    }
    else if([[self track] playbackStatus] == MusicControllerPaused) {
        float height = size*sqrt(3.0), width = 3, seperation = 1.5;
        CGRect rects[] = {
            CGRectMake(middle.x - seperation/2.0 - width, middle.y - height/2.0, width, height),
            CGRectMake(middle.x + seperation/2.0, middle.y - height/2.0, width, height)
        };
        CGContextClipToRects(ctx, rects, 2);
        gradient_height = height/2.0;
    }
    else if([[self track] playbackStatus] == MusicControllerPlaying) {
        CGPoint playPoints[] =
        {
            CGPointMake(middle.x + size, middle.y),
            CGPointMake(middle.x - size*0.5, middle.y + size*sqrt(3.0)*0.5),
            CGPointMake(middle.x - size*0.5, middle.y - size*sqrt(3.0)*0.5),
            CGPointMake(middle.x + size, middle.y)
        };
        CGAffineTransform trans = CGAffineTransformMakeTranslation(-1,0);
        for (int i=0; i<4; i++) {
            playPoints[i] = CGPointApplyAffineTransform(playPoints[i],trans);
        }
        CGContextAddLines(ctx, playPoints, 4);
        gradient_height = size*sqrt(3)*0.5;
        CGContextClip(ctx);
    }
    
    NSColor *gradientEndColor;
    NSColor *gradientStartColor;
    if([[self track] hasErrorOpeningFile]) {
        gradientEndColor = [NSColor colorWithCalibratedRed:0.65 green:0.0 blue:0.0 alpha:1.0];
        gradientStartColor = [NSColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    }
    else { // regular playback
        gradientEndColor = [NSColor colorWithCalibratedRed:0.057 green:0.474 blue:0.865 alpha:1.000];
        gradientStartColor = [NSColor colorWithCalibratedRed:0.457 green:0.693 blue:0.875 alpha:1.000];
    }
    
    NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                       (id)[gradientEndColor CGColor], nil];
    CGFloat locations[] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);
    
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(middle.x, middle.y + gradient_height), CGPointMake(middle.x, middle.y - gradient_height), 0);
    CGGradientRelease(gradient);
    CGContextRestoreGState(ctx);
}

@end
