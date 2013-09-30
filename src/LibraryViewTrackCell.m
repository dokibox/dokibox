//
//  LibraryViewTrackCell.m
//  dokibox
//
//  Created by Miles Wu on 07/02/2013.
//
//

#import "LibraryViewTrackCell.h"
#import "CoreDataManager.h"
#import "LibraryViewAddButton.h"

@implementation LibraryViewTrackCell
@synthesize track = _track;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat altTextWidth = 40;
        CGFloat altTextMargin = 10;
        
        CGRect textRect = NSInsetRect([self bounds], 5, 4);
        textRect.origin.x += 17; // for button
        textRect.size.width -= 17; // for button
        
        CGRect nameTextRect = NSInsetRect(textRect, 0, 0);
        nameTextRect.origin.x += 4 + 5;
        nameTextRect.size.width -= altTextMargin + altTextWidth + 4 + 5;
        _nameTextField = [[NSTextField alloc] initWithFrame:nameTextRect];
        [_nameTextField setEditable:NO];
        [_nameTextField setBordered:NO];
        [_nameTextField setBezeled:NO];
        [_nameTextField setDrawsBackground:NO];
        [_nameTextField setFont:[NSFont fontWithName:@"Lucida Grande" size:10]];
        [[_nameTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [_nameTextField setAutoresizingMask:NSViewWidthSizable];
        [self addSubview:_nameTextField];
        
        CGRect altTextRect = NSInsetRect(textRect, 0, 0);
        altTextRect.size.width = altTextWidth;
        altTextRect.origin.x += textRect.size.width - altTextWidth;
        _altTextField = [[NSTextField alloc] initWithFrame:altTextRect];
        [_altTextField setEditable:NO];
        [_altTextField setBordered:NO];
        [_altTextField setBezeled:NO];
        [_altTextField setDrawsBackground:NO];
        [_altTextField setFont:[NSFont fontWithName:@"Helvetica-Oblique" size:10]];
        [_altTextField setTextColor:[NSColor colorWithDeviceWhite:0.35 alpha:1.0]];
        [_altTextField setAlignment:NSRightTextAlignment];
        [_altTextField setAutoresizingMask:NSViewMinXMargin];
        [self addSubview:_altTextField];
        
        CGRect buttonFrame = NSMakeRect(2, NSMidY([self bounds])-10, 20, 20);
        LibraryViewAddButton *addButton = [[LibraryViewAddButton alloc] initWithFrame:buttonFrame];
        [addButton setAutoresizingMask:NSViewMaxXMargin];
        [self addSubview:addButton];
        
        [self addObserver:self forKeyPath:@"track" options:NULL context:nil];
    }
    
    return self;
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

- (void)drawRect:(CGRect)rect
{
    // Need a drawRect function for subpixel font rendering to work in NSTextField
}

@end
