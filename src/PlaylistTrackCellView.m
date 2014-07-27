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
        [_textField setFont:[NSFont fontWithName:@"Lucida Grande" size:11]];
        [_textField setAutoresizingMask:NSViewWidthSizable | NSViewMaxXMargin];
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
            NSString *text;
            
            if([_track albumArtistName] && [[_track albumArtistName] isEqual:[_track trackArtistName]] == NO) {
                // If album artist exists and isn't the same as the track artist, append the track artist to the title
                text = [NSString stringWithFormat:@"%@ // %@", [_track name], [_track trackArtistName]];
            }
            else {
                text = [_track name];
            }
            
            [_textField setStringValue:text];
        }
        else if([_columnIdentifier isEqualToString:@"album"]) {
            [_textField setStringValue:[_track albumName]];
        }
        else if([_columnIdentifier isEqualToString:@"artist"]) {
            NSString *text;
            
            if([_track albumArtistName] && [[_track albumArtistName] isEqual:@""] == NO) {
                // If album artist exists and isn't "", use it instead of track artist
                text = [_track albumArtistName];
            }
            else {
                text = [_track trackArtistName];
            }
            
            [_textField setStringValue:text];
        }
        else if([_columnIdentifier isEqualToString:@"length"]) {
            int length = [[_track length] intValue];
            NSString *timeString = [[NSString alloc] initWithFormat:@"%02d:%02d", (int)(length/60.0), (int)length%60];
            [_textField setStringValue:timeString];
        }
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    
}

@end
