//
//  LibraryViewTrackCell.m
//  dokibox
//
//  Created by Miles Wu on 07/02/2013.
//
//

#import "LibraryViewTrackCell.h"
#import "LibraryViewAddButton.h"
#import "LibraryTrack.h"

@implementation LibraryViewTrackCell
@synthesize track = _track;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat altTextWidth = 40;
        CGFloat altTextMargin = 10;
        
        CGRect nameTextRect = _textRect;
        nameTextRect.origin.x += 4 + 5;
        nameTextRect.size.width -= altTextMargin + altTextWidth + 4 + 5;
        [_nameTextField setFrame:nameTextRect];
        [_nameTextField setFont:[NSFont fontWithName:@"Lucida Grande" size:10]];
        
        CGRect altTextRect = NSInsetRect(_textRect, 0, 0);
        altTextRect.size.width = altTextWidth;
        altTextRect.origin.x += _textRect.size.width - altTextWidth;
        [_altTextField setFrame:altTextRect];
        
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
        {
            NSMutableString *str = [[NSMutableString alloc] init];
            if([[self track] trackNumber]) {
                [str appendFormat:@"%d. ", [[[self track] trackNumber] intValue]];
            }
            [str appendString:[[self track] name]];
            [_nameTextField setStringValue:str];
        }
        
        {
            int length = [[[self track] length] intValue];
            NSString *str = [NSString stringWithFormat:@"%d:%.2d", length/60, length%60];
            [_altTextField setStringValue:str];
        }
    }
}

@end
