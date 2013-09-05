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
@synthesize isEvenRow = _isEvenRow;

- (void)drawRect:(CGRect)rect
{
    NSAssert([self track], @"track for cell nil");
	CGRect b = self.bounds;
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];

    // draw left background
    CGContextSetRGBFillColor(ctx, .87, .90, .94, 1);
    CGContextFillRect(ctx, b);

    // indent everything by the image size
    CGFloat indent = 50;
    b = CGRectIntersection(b, CGRectOffset(b, indent, 0));

    // draw normal background
    if([self isEvenRow] == true)
        CGContextSetRGBFillColor(ctx, .92, .94, .99, 1);
    else
        CGContextSetRGBFillColor(ctx, .98, .99, 1.0, 1);
    CGContextFillRect(ctx, b);
    
    CGContextSetShouldSmoothFonts(ctx, YES);
    {   // Draw text for name
        NSMutableString *str = [[NSMutableString alloc] init];
        if([[self track] trackNumber]) {
            [str appendFormat:@"%d. ", [[[self track] trackNumber] intValue]];
        }
        [str appendString:[[self track] name]];
        
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        [attr setObject:[NSFont fontWithName:@"Lucida Grande" size:10] forKey:NSFontAttributeName];
        NSAttributedString *astr = [[NSAttributedString alloc] initWithString:str attributes:attr];
        
        CGRect textRect = CGRectOffset(b, 10, -4);
        [astr drawInRect:textRect];
    }

    { // Draw alt text
        if([[self track] length]) {
            int length = [[[self track] length] intValue];
            NSString *str = [NSString stringWithFormat:@"%d:%.2d", length/60, length%60];
            
            NSMutableDictionary *attr = [NSMutableDictionary dictionary];
            [attr setObject:[NSFont fontWithName:@"Helvetica-Oblique" size:10] forKey:NSFontAttributeName];
            [attr setObject:[NSColor colorWithDeviceWhite:0.35 alpha:1.0] forKey:NSForegroundColorAttributeName];
            NSAttributedString *astr = [[NSAttributedString alloc] initWithString:str attributes:attr];

            NSSize textSize = [astr size];            
            CGRect textRect = CGRectOffset(b, b.size.width - textSize.width - 10, -4);
            //textRect.size.width -= textRect.origin.x - b.origin.x;
            [astr drawInRect:textRect];
        }
    }
}

@end
