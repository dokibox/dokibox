//
//  PlaylistTrackCell.m
//  fb2kmac
//
//  Created by Miles Wu on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaylistTrackCell.h"

@implementation PlaylistTrackCell

@synthesize track = _track;

- (id)initWithStyle:(TUITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		_textRenderer = [[TUITextRenderer alloc] init];
        // This is for event routing for dictionary/selection
		self.textRenderers = [NSArray arrayWithObjects:_textRenderer, nil];
        
        _font = [TUIFont fontWithName:@"HelveticaNeue" size:12];
	}
	return self;
}


- (void)drawRect:(CGRect)rect
{
	CGRect b = self.bounds;
	CGContextRef ctx = TUIGraphicsGetCurrentContext();
	
	if(self.selected) {
		// selected background
		CGContextSetRGBFillColor(ctx, .87, .87, .87, 1);
		CGContextFillRect(ctx, b);
	} else {
		// light gray background
		CGContextSetRGBFillColor(ctx, .97, .97, .97, 1);
		CGContextFillRect(ctx, b);
		
		// emboss
		CGContextSetRGBFillColor(ctx, 1, 1, 1, 0.9); // light at the top
		CGContextFillRect(ctx, CGRectMake(0, b.size.height-1, b.size.width, 1));
		CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.08); // dark at the bottom
		CGContextFillRect(ctx, CGRectMake(0, 0, b.size.width, 1));
	}
    
    NSMutableArray *arr = [NSMutableArray array];
    CGRect textRect = CGRectOffset(b, 10, -5);
    
    [arr addObject:[[Column alloc] initWithKey:@"title" offset:0]];
    [arr addObject:[[Column alloc] initWithKey:@"album" offset:100]];    
    for(Column *c in arr) {
        if([[_track attributes] objectForKey:[c key]] == nil) {
            continue;
        }
        TUIAttributedString *astr = [TUIAttributedString stringWithString:[[_track attributes] objectForKey:[c key]]];
        [astr setFont:_font];
        [astr setColor:[TUIColor blackColor]];
        
        int offset = [c offset];
        TUIImage *im = [c image];
        if(im != nil) {
            CGPoint impoint = textRect.origin;
            impoint.x += [c offset];
            impoint.y += [im size].height/2 + 2;
            [im drawAtPoint:impoint];
            offset += [im size].width + 5;
        }
        
        [_textRenderer setAttributedString:astr];
        [_textRenderer setFrame: CGRectOffset(textRect, offset, 0)];
        [_textRenderer draw];
    }
}

@end
