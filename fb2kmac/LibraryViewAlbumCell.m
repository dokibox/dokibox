//
//  LibraryViewAlbumCell.m
//  fb2kmac
//
//  Created by Miles Wu on 06/02/2013.
//
//

#import "LibraryViewAlbumCell.h"

@implementation LibraryViewAlbumCell

@synthesize album = _album;

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
	
    if(false) {
        //if(self.selected) {
		// selected background
		CGContextSetRGBFillColor(ctx, .87, .87, .87, 1);
		CGContextFillRect(ctx, b);
	} else {
        CGContextSetRGBFillColor(ctx, .87, .90, .94, 1);
		CGContextFillRect(ctx, b);
	}
    
    CGFloat imagesize = 50;
    {   // Draw text for name
        TUIAttributedString *astr = [TUIAttributedString stringWithString:[[self album] name]];
        [astr setFont:[TUIFont fontWithName:@"Helvetica-Oblique" size:13]];
        [astr setColor:[TUIColor blackColor]];
        
        CGRect textRect = CGRectOffset(b, 10+imagesize, -17);
        [_textRenderer setAttributedString:astr];
        [_textRenderer setFrame: textRect]; //CGRectOffset(textRect, offset, 0)];
        [_textRenderer draw];
    }
    
    { // Draw alt text
        NSImage *nimage = [[NSImage alloc] initWithContentsOfFile:[@"~/Desktop/IMAG0102.jpg" stringByExpandingTildeInPath]];
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
            
        CGContextRestoreGState(ctx);
        
        TUIAttributedString *astr = [TUIAttributedString stringWithString:@"5 tracks"];
        [astr setFont:[TUIFont fontWithName:@"Helvetica-Oblique" size:10]];
        [astr setColor:[TUIColor colorWithWhite:0.35 alpha:1.0]];
        NSSize textSize = [astr size];
        
        CGRect textRect = CGRectOffset(b, b.size.width - textSize.width - 10, -17);
        //textRect.size.width -= textRect.origin.x - b.origin.x;
        [_textRenderer setAttributedString:astr];
        [_textRenderer setFrame: textRect]; //CGRectOffset(textRect, offset, 0)];
        [_textRenderer draw];
    }
}



@end
