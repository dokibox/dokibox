//
//  LibraryViewAlbumCell.m
//  dokibox
//
//  Created by Miles Wu on 06/02/2013.
//
//

#import "LibraryViewAlbumCell.h"
#import "CoreDataManager.h"

@implementation LibraryViewAlbumCell

@synthesize album = _album;

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
        CGContextSetRGBFillColor(ctx, .87, .90, .94, 1);
		CGContextFillRect(ctx, b);
	}

    CGContextSetShouldSmoothFonts(ctx, YES);
    CGFloat imagesize = 50;
    {   // Draw text for name
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        [attr setObject:[NSFont fontWithName:@"Helvetica-Oblique" size:13] forKey:NSFontAttributeName];
        NSAttributedString *astr = [[NSAttributedString alloc] initWithString:[[self album] name] attributes:attr];

        CGRect textRect = CGRectOffset(b, 10+imagesize, -17);
        [astr drawInRect:textRect];
    }

    { // Draw alt text
        /*NSImage *nimage = [[NSImage alloc] initWithContentsOfFile:[@"~/Desktop/IMAG0102.jpg" stringByExpandingTildeInPath]];
        TUIImage *timage = [TUIImage imageWithNSImage:nimage];
        //[timage drawAtPoint:b.origin];
        CGContextSaveGState(ctx);
        CGContextAddRect(ctx, CGRectMake(b.origin.x, b.origin.y, imagesize, imagesize));
        CGContextClip(ctx);
        if([timage size].width < [timage size].height) { //height larger
            CGFloat excess = imagesize / [timage size].width * [timage size].height - imagesize;
            [timage drawInRect:CGRectMake(b.origin.x, b.origin.y - 0.5*excess, imagesize, imagesize + excess)];
        }
        else { //width larger
            CGFloat excess = imagesize / [timage size].height * [timage size].width - imagesize;
            [timage drawInRect:CGRectMake(b.origin.x - 0.5*excess, b.origin.y, imagesize+ excess, imagesize)];
        }

        CGContextRestoreGState(ctx);*/

        NSString *str = [[NSString alloc] initWithFormat:@"%ld tracks", [[[self album] tracks] count]];
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        [attr setObject:[NSFont fontWithName:@"Helvetica-Oblique" size:10] forKey:NSFontAttributeName];
        [attr setObject:[NSColor colorWithDeviceWhite:0.35 alpha:1.0] forKey:NSForegroundColorAttributeName];
        NSAttributedString *astr = [[NSAttributedString alloc] initWithString:str attributes:attr];

        NSSize textSize = [astr size];
        CGRect textRect = CGRectOffset(b, b.size.width - textSize.width - 10, -17);
        //textRect.size.width -= textRect.origin.x - b.origin.x;
        [astr drawInRect:textRect];
    }
}

@end
