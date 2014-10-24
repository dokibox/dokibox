//
//  PlaylistCellView.m
//  dokibox
//
//  Created by Miles Wu on 07/07/2013.
//
//

#import "PlaylistCellView.h"
#import "NSView+CGDrawing.h"

@implementation PlaylistCellView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect b = [self bounds];

        b.size.width -= 60;
        b.origin.x += 7;
        b.origin.y += 5;
        b.size.height -= 2*5;
        _playlistNameTextField = [[NSTextField alloc] initWithFrame:b];
        [_playlistNameTextField setDelegate:self];
        [_playlistNameTextField setEditable:YES];
        [_playlistNameTextField setBordered:NO];
        [_playlistNameTextField setBezeled:NO];
        [_playlistNameTextField setDrawsBackground:NO];
        [_playlistNameTextField setFont:[NSFont systemFontOfSize:10]];
        [_playlistNameTextField setAutoresizingMask:NSViewWidthSizable | NSViewMaxXMargin];
        [self addSubview:_playlistNameTextField];

        b = [self bounds];
        b.origin.x += b.size.width - 40;
        b.size.width -= b.size.width - 40 + 10;
        b.origin.y += 5;
        b.size.height -= 2*5;
        _noTracksTextField = [[NSTextField alloc] initWithFrame:b];
        [[_noTracksTextField cell] setUsesSingleLineMode:YES];
        [_noTracksTextField setAlignment:NSRightTextAlignment];
        [_noTracksTextField setBordered:NO];
        [_noTracksTextField setBezeled:NO];
        [_noTracksTextField setDrawsBackground:NO];
        [_noTracksTextField setEditable:NO];
        [_noTracksTextField setFont:[NSFont systemFontOfSize:9]];
        [_noTracksTextField setAutoresizingMask:NSViewWidthSizable | NSViewMinXMargin];
        [_noTracksTextField setTextColor:[NSColor colorWithDeviceWhite:0.34 alpha:1.0]];
        [self addSubview:_noTracksTextField];

    }

    return self;
}

- (void)dealloc
{
    [self setPlaylist:nil]; //clear out observers and binds
}

-(Playlist *)playlist
{
    return _playlist;
}

- (void)setPlaylist:(Playlist *)playlist
{
    if(_playlist) {
        [_playlist removeObserver:self forKeyPath:@"tracks.@count"];
    }
    
    _playlist = playlist;
    
    if(playlist) { //playlist can be nil (used in dealloc method to removeObserver)
        [_playlistNameTextField bind:@"value" toObject:_playlist withKeyPath:@"name" options:nil];
        [_noTracksTextField bind:@"value" toObject:_playlist withKeyPath:@"tracks.@count" options:nil];
        [_playlist addObserver:self forKeyPath:@"tracks.@count" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath compare:@"tracks.@count"] == NSOrderedSame) {
        [self setNeedsDisplay:YES];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGRect b = self.bounds;
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];

    CGContextSaveGState(ctx);
    
    CGFloat noTrackTextLength = round([[_noTracksTextField attributedStringValue] size].width);
    CGRect cliprect = CGRectMake(b.origin.x + b.size.width - 17 - noTrackTextLength, b.origin.y + 3, noTrackTextLength + 10, b.size.height - 3*2);
    [self CGContextRoundedCornerPath:cliprect context:ctx radius:3.0 withHalfPixelRedution:NO];
    CGContextClip(ctx);
    NSColor *gradientStartColor = [NSColor colorWithDeviceWhite:0.55 alpha:0.65];
    NSColor *gradientEndColor = [NSColor colorWithDeviceWhite:0.85 alpha:0.65];

    NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                       (id)[gradientEndColor CGColor], nil];
    CGFloat locations[] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(b.origin.x, b.origin.x), CGPointMake(b.origin.x, b.origin.y + b.size.height), 0);
    CGGradientRelease(gradient);
    CGContextRestoreGState(ctx);
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
    [_playlist save];
}

@end
