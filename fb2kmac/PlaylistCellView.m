//
//  PlaylistCellView.m
//  fb2kmac
//
//  Created by Miles Wu on 07/07/2013.
//
//

#import "PlaylistCellView.h"

@implementation PlaylistCellView

@synthesize playlist = _playlist;

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
        
    NSString *name = [_playlist name];
    name = name == nil ? @"" : name;
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    [attr setObject:[NSFont fontWithName:@"HelveticaNeue" size:12] forKey:NSFontAttributeName];
    NSAttributedString *nameAttStr = [[NSAttributedString alloc] initWithString:name attributes:attr];
    
    //CGContextSetShouldSmoothFonts(ctx, true);
    NSSize textSize = [nameAttStr size];
    NSPoint textPoint = NSMakePoint(b.origin.x + 10.0, b.origin.y + b.size.height/2.0 - textSize.height/2.0);
    [nameAttStr drawAtPoint:textPoint];
}

@end
