//
//  LibraryViewTrackCell.m
//  fb2kmac
//
//  Created by Miles Wu on 07/02/2013.
//
//

#import "LibraryViewTrackCell.h"

@implementation LibraryViewTrackCell

- (id)initWithStyle:(TUITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		_textRenderer = [[TUITextRenderer alloc] init];
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
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
        TUIAttributedString *astr = [TUIAttributedString stringWithString:@"1. The Song Remains the Same"];
        [astr setFont:[TUIFont fontWithName:@"Lucida Grande" size:10]];
        [astr setColor:[TUIColor blackColor]];
        
        CGRect textRect = CGRectOffset(b, 10, -4);
        [_textRenderer setAttributedString:astr];
        [_textRenderer setFrame: textRect]; //CGRectOffset(textRect, offset, 0)];
        [_textRenderer draw];
    }
    
    { // Draw alt text
        TUIAttributedString *astr = [TUIAttributedString stringWithString:@"3:01"];
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

@end
