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

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSRect textRect = NSInsetRect([self bounds], 7, 1);
        _textField = [[NSTextField alloc] initWithFrame:textRect];
        [_textField setEditable:YES];
        [_textField setBordered:NO];
        [_textField setBezeled:NO];
        [_textField setDrawsBackground:NO];
        [_textField setFont:[NSFont fontWithName:@"Lucida Grande" size:10]];
        [_textField setAutoresizingMask:NSViewWidthSizable | NSViewMaxXMargin];
        [self addSubview:_textField];
        
        [self addObserver:self forKeyPath:@"track" options:NULL context:nil];
    }

    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"track"]) {
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        [attr setObject:[NSFont fontWithName:@"HelveticaNeue" size:12] forKey:NSFontAttributeName];
        NSAttributedString *trackName = [[NSAttributedString alloc] initWithString:[_track name]];
        
        NSMutableDictionary *boldattr = [NSMutableDictionary dictionaryWithDictionary:attr];
        [boldattr setObject:[NSFont fontWithName:@"HelveticaNeue-Bold" size:12] forKey:NSFontAttributeName];
        NSAttributedString *artistName = [[NSAttributedString alloc] initWithString:[_track artistName] attributes:boldattr];
        
        NSAttributedString *spacing = [[NSAttributedString alloc] initWithString:@" " attributes:attr];
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
        [text appendAttributedString:artistName];
        [text appendAttributedString:spacing];
        [text appendAttributedString:trackName];
        
        [_textField setAttributedStringValue:text];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    
}

@end
