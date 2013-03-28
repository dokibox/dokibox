//
//  LibraryViewArtistCell.m
//  fb2kmac
//
//  Created by Miles Wu on 06/02/2013.
//
//

#import "LibraryViewArtistCell.h"
#import "Album.h"
#import "CoreDataManager.h"

@implementation LibraryViewArtistCell

@synthesize artist = _artist;

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
        TUIColor *gradientStartColor, *gradientEndColor;
        gradientStartColor = [TUIColor colorWithWhite:0.82 alpha:1.0];
        gradientEndColor = [TUIColor colorWithWhite:0.98 alpha:1.0];
        
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
    
    {   // Draw text for name
        TUIAttributedString *astr = [TUIAttributedString stringWithString:[[self artist] name]];
        [astr setFont:[TUIFont fontWithName:@"Lucida Grande" size:13]];
        [astr setColor:[TUIColor blackColor]];
        
        CGRect textRect = CGRectOffset(b, 10, -4);
        [_textRenderer setAttributedString:astr];
        [_textRenderer setFrame: textRect]; //CGRectOffset(textRect, offset, 0)];
        [_textRenderer draw];
    }
    
    { // Draw alt text
        NSString *str = [[NSString alloc] initWithFormat:@"%ld albums, %ld tracks", [[[self artist] albums] count],[[[self artist] tracks] count]];
        TUIAttributedString *astr = [TUIAttributedString stringWithString:str];
        [astr setFont:[TUIFont fontWithName:@"Helvetica-Oblique" size:10]];
        [astr setColor:[TUIColor colorWithWhite:0.35 alpha:1.0]];
        NSSize textSize = [astr size];
        
        CGRect textRect = CGRectOffset(b, b.size.width - textSize.width - 10, -6);
        //textRect.size.width -= textRect.origin.x - b.origin.x;
        [_textRenderer setAttributedString:astr];
        [_textRenderer setFrame: textRect]; //CGRectOffset(textRect, offset, 0)];
        [_textRenderer draw];
    }
}


-(void)prepareForReuse
{
    [super prepareForReuse];
    [[[self artist] managedObjectContext] refreshObject:[self artist] mergeChanges:NO];
}

@end
