//
//  LibraryViewTrackCell.m
//  dokibox
//
//  Created by Miles Wu on 07/02/2013.
//
//

#import "LibraryViewTrackCell.h"
#import "CoreDataManager.h"

@implementation LibraryViewTrackCell
@synthesize track = _track;

- (id)initWithStyle:(TUITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		_textRenderer = [[TUITextRenderer alloc] init];
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
    NSAssert([self track], @"track for cell nil");
	CGRect b = self.bounds;
	CGContextRef ctx = TUIGraphicsGetCurrentContext();

    // draw left background
    CGContextSetRGBFillColor(ctx, .87, .90, .94, 1);
    CGContextFillRect(ctx, b);

    // indent everything by the image size
    CGFloat indent = 50;
    b = CGRectIntersection(b, CGRectOffset(b, indent, 0));

    // draw normal background
    CGContextSetRGBFillColor(ctx, .92, .94, .99, 1);
    CGContextFillRect(ctx, b);

    {   // Draw text for name
        NSMutableString *str = [[NSMutableString alloc] init];
        if([[self track] trackNumber]) {
            [str appendFormat:@"%d. ", [[[self track] trackNumber] intValue]];
        }
        [str appendString:[[self track] name]];
        
        TUIAttributedString *astr = [TUIAttributedString stringWithString:str];
        [astr setFont:[TUIFont fontWithName:@"Lucida Grande" size:10]];
        [astr setColor:[TUIColor blackColor]];

        CGRect textRect = CGRectOffset(b, 10, -4);
        [_textRenderer setAttributedString:astr];
        [_textRenderer setFrame: textRect]; //CGRectOffset(textRect, offset, 0)];
        [_textRenderer draw];
    }

    { // Draw alt text
        if([[self track] length]) {
            int length = [[[self track] length] intValue];
            NSString *str = [NSString stringWithFormat:@"%d:%.2d", length/60, length%60];
            
            TUIAttributedString *astr = [TUIAttributedString stringWithString:str];
            [astr setFont:[TUIFont fontWithName:@"Helvetica-Oblique" size:10]];
            [astr setColor:[TUIColor colorWithWhite:0.35 alpha:1.0]];
            NSSize textSize = [astr size];
            
            CGRect textRect = CGRectOffset(b, b.size.width - textSize.width - 10, -4);
            //textRect.size.width -= textRect.origin.x - b.origin.x;
            [_textRenderer setAttributedString:astr];
            [_textRenderer setFrame: textRect]; //CGRectOffset(textRect, offset, 0)];
            [_textRenderer draw];
        }
    }
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    [[[self track] managedObjectContext] refreshObject:[self track] mergeChanges:NO];
}

@end
