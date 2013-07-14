//
//  PlaylistCellView.m
//  fb2kmac
//
//  Created by Miles Wu on 07/07/2013.
//
//

#import "PlaylistCellView.h"

@implementation PlaylistCellView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect b = [self bounds];
        
        b.origin.x += 7;
        b.size.width += 7;
        b.size.height -= 8;
        _playlistNameTextField = [[NSTextField alloc] initWithFrame:b];
        [_playlistNameTextField setDelegate:self];
        [_playlistNameTextField setEditable:YES];
        [_playlistNameTextField setBordered:NO];
        [_playlistNameTextField setBezeled:NO];
        [_playlistNameTextField setDrawsBackground:NO];
        [_playlistNameTextField setFont:[NSFont fontWithName:@"Lucida Grande" size:10]];        
        [_playlistNameTextField setAutoresizingMask:NSViewWidthSizable | NSViewMinXMargin | NSViewMaxXMargin];
        [self addSubview:_playlistNameTextField];
                
        b = [self bounds];
        b.origin.x += b.size.width - 40;
        b.size.width -= b.size.width - 40 + 15;
        b.size.height -= 9;
        _noTracksTextField = [[NSTextField alloc] initWithFrame:b];
        [[_noTracksTextField cell] setUsesSingleLineMode:YES];
        [_noTracksTextField setAlignment:NSRightTextAlignment];
        [_noTracksTextField setStringValue:@"4"];
        [_noTracksTextField setBordered:NO];
        [_noTracksTextField setBezeled:NO];
        [_noTracksTextField setDrawsBackground:NO];
        [_noTracksTextField setEditable:NO];
        [_noTracksTextField setFont:[NSFont fontWithName:@"Lucida Grande" size:9]];
        [_noTracksTextField setAutoresizingMask:NSViewWidthSizable | NSViewMinXMargin | NSViewMaxXMargin];
        [_noTracksTextField setTextColor:[NSColor colorWithDeviceWhite:0.34 alpha:1.0]];
        [self addSubview:_noTracksTextField];

    }
    
    return self;
}

-(Playlist *)playlist
{
    return _playlist;
}

- (void)setPlaylist:(Playlist *)playlist
{
    _playlist = playlist;
    [_playlistNameTextField bind:@"value" toObject:_playlist withKeyPath:@"name" options:nil];
    [_noTracksTextField bind:@"value" toObject:_playlist withKeyPath:@"tracks.@count" options:nil];
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGRect b = self.bounds;
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextSaveGState(ctx);
    
    CGRect cliprect = CGRectMake(b.origin.x + b.size.width - 28, b.origin.y + 3, 17, b.size.height - 6);
    CGContextClipToRect(ctx, cliprect);
    NSColor *gradientStartColor = [NSColor colorWithDeviceWhite:0.55 alpha:0.65];
    NSColor *gradientEndColor = [NSColor colorWithDeviceWhite:0.95 alpha:0.65];
    
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
