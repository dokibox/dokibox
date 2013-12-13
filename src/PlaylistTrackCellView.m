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
        NSRect textRect = NSInsetRect([self bounds], 7, 5);
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
            [_textField setStringValue:[_track name]];
        }
        else if([_columnIdentifier isEqualToString:@"album"]) {
            [_textField setStringValue:[_track albumName]];
        }
        else if([_columnIdentifier isEqualToString:@"artist"]) {
            [_textField setStringValue:[_track artistName]];
        }
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    
}

@end
