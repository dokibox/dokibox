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
        b.size.height -= 8;
        _playlistNameTextField = [[NSTextField alloc] initWithFrame:b];
        [_playlistNameTextField setStringValue:@"hi"];
        [_playlistNameTextField setBordered:NO];
        [_playlistNameTextField setBezeled:NO];
        [_playlistNameTextField setDrawsBackground:NO];
        [_playlistNameTextField setFont:[NSFont fontWithName:@"Lucida Grande" size:10]];
        [self addSubview:_playlistNameTextField];
        
        [_playlistNameTextField setAutoresizingMask:NSViewWidthSizable | NSViewMinXMargin | NSViewMaxXMargin];
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
    [_playlistNameTextField setStringValue:[_playlist name]];
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGRect b = self.bounds;
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
}

@end
