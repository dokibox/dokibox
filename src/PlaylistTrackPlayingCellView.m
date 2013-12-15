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

-(PlaylistTrack *)track
{
    return _track;
}

- (void)setTrack:(PlaylistTrack *)track
{
    if(_track) {
        [_track removeObserver:self forKeyPath:@"playbackStatus"];
    }
    
    _track = track;
    [_track addObserver:self forKeyPath:@"playbackStatus" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath compare:@"playbackStatus"] == NSOrderedSame) {
        [self setNeedsDisplay:YES];
    }
}


- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGRect b = self.bounds;
    
    if([[self track] playbackStatus] == MusicControllerPlaying) {
        CGContextSetRGBFillColor(ctx, 1.0, 0.0, 0.0, 1.0);
        CGContextFillRect(ctx, b);
    }
    else if([[self track] playbackStatus] == MusicControllerPaused) {
        CGContextSetRGBFillColor(ctx, 0.0, 1.0, 0.0, 1.0);
        CGContextFillRect(ctx, b);
    }
}

@end
