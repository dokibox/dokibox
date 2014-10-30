//
//  PlaylistTrackCellView.m
//  dokibox
//
//  Created by Miles Wu on 05/07/2013.
//
//

#import "PlaylistTrackCellView.h"

@implementation PlaylistTrackCellView

@synthesize track = _track;
@synthesize columnIdentifier = _columnIdentifier;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSRect textRect = NSInsetRect([self bounds], 4, 5);
        _textField = [[NSTextField alloc] initWithFrame:textRect];
        [_textField setEditable:NO];
        [_textField setBordered:NO];
        [_textField setBezeled:NO];
        [_textField setDrawsBackground:NO];
        [_textField setFont:[NSFont systemFontOfSize:11]];
        [_textField setAutoresizingMask:NSViewWidthSizable | NSViewMaxXMargin];
        [[_textField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [self addSubview:_textField];
        
        [self addObserver:self forKeyPath:@"track" options:NULL context:nil];
    }

    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"track"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"track"]) {
        if([_columnIdentifier isEqualToString:@"title"]) {
            [_textField setStringValue:[_track displayName]];
        }
        else if([_columnIdentifier isEqualToString:@"album"]) {
            [_textField setStringValue:[_track displayAlbumName]];
        }
        else if([_columnIdentifier isEqualToString:@"artist"]) {
            [_textField setStringValue:[_track displayArtistName]];
        }
        else if([_columnIdentifier isEqualToString:@"length"]) {
            int length = [[_track length] intValue];
            NSString *timeString = [[NSString alloc] initWithFormat:@"%02d:%02d", (int)(length/60.0), (int)length%60];
            [_textField setStringValue:timeString];
        }
    }
}

@end
