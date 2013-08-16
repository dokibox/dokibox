//
//  LibraryViewArtistCell.m
//  dokibox
//
//  Created by Miles Wu on 06/02/2013.
//
//

#import "LibraryViewArtistCell.h"
#import "LibraryAlbum.h"
#import "CoreDataManager.h"

@implementation LibraryViewArtistCell

@synthesize artist = _artist;

- (void)drawRect:(CGRect)rect
{
	CGRect b = self.bounds;
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];

    if(false) {
	//if(self.selected) {
		// selected background
		CGContextSetRGBFillColor(ctx, .87, .87, .87, 1);
		CGContextFillRect(ctx, b);
	} else {
        NSColor *gradientStartColor, *gradientEndColor;
        gradientStartColor = [NSColor colorWithDeviceWhite:0.82 alpha:1.0];
        gradientEndColor = [NSColor colorWithDeviceWhite:0.98 alpha:1.0];

        NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                           (id)[gradientEndColor CGColor], nil];
        CGFloat locations[] = { 0.0, 1.0 };
        CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(b.origin.x, b.origin.y), CGPointMake(b.origin.x, b.origin.y+b.size.height), 0);
        CGGradientRelease(gradient);

		// emboss
		/*CGContextSetRGBFillColor(ctx, 1, 1, 1, 0.9); // light at the top
		CGContextFillRect(ctx, CGRectMake(0, b.size.height-1, b.size.width, 1));
		CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.08); // dark at the bottom
		CGContextFillRect(ctx, CGRectMake(0, 0, b.size.width, 1));*/
	}
    
    CGContextSetShouldSmoothFonts(ctx, YES);
    {   // Draw text for name
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        [attr setObject:[NSFont fontWithName:@"Lucida Grande" size:12] forKey:NSFontAttributeName];
        NSAttributedString *astr = [[NSAttributedString alloc] initWithString:[[self artist] name] attributes:attr];

        CGRect textRect = CGRectOffset(b, 10, -4);
        [astr drawInRect:textRect];
    }

    { // Draw alt text
        NSString *str = [[NSString alloc] initWithFormat:@"%ld albums, %ld tracks", [[[self artist] albums] count],[[[self artist] tracks] count]];
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        [attr setObject:[NSFont fontWithName:@"Helvetica-Oblique" size:10] forKey:NSFontAttributeName];
        [attr setObject:[NSColor colorWithDeviceWhite:0.35 alpha:1.0] forKey:NSForegroundColorAttributeName];
        NSAttributedString *astr = [[NSAttributedString alloc] initWithString:str attributes:attr];
        
        NSSize textSize = [astr size];
        CGRect textRect = CGRectOffset(b, b.size.width - textSize.width - 10, -6);
        //textRect.size.width -= textRect.origin.x - b.origin.x;
        [astr drawInRect:textRect];
    }
}

@end
