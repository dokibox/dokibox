//
//  PlaylistTrackCellView.m
//  fb2kmac
//
//  Created by Miles Wu on 05/07/2013.
//
//

#import "PlaylistTrackCellView.h"

@implementation PlaylistTrackCellView

@synthesize track = _track;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{    
    CGRect b = self.bounds;
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    
    /*if(false) {
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
    }*/
    
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    [attr setObject:[NSFont fontWithName:@"HelveticaNeue" size:12] forKey:NSFontAttributeName];    
    NSAttributedString *trackName = [[NSAttributedString alloc] initWithString:[_track name]];
    
    NSMutableDictionary *boldattr = [NSMutableDictionary dictionaryWithDictionary:attr];
    [boldattr setObject:[NSFont fontWithName:@"HelveticaNeue-Bold" size:12] forKey:NSFontAttributeName];
    NSAttributedString *artistName = [[NSAttributedString alloc] initWithString:[_track artistName] attributes:boldattr];
    
    NSAttributedString *spacing = [[NSAttributedString alloc] initWithString:@" " attributes:attr];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    [text appendAttributedString:artistName];
    [text appendAttributedString:spacing];
    [text appendAttributedString:trackName];
    
    //CGContextSetShouldSmoothFonts(ctx, true);
    NSSize textSize = [text size];
    NSPoint textPoint = NSMakePoint(b.origin.x + 10.0, b.origin.y + b.size.height/2.0 - textSize.height/2.0);
    [text drawAtPoint:textPoint];
}

@end
