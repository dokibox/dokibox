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
@synthesize searchMatchedObjects = _searchMatchedObjects;

- (LibraryAlbum *)album
{
    return _album;
}

- (void)setAlbum:(LibraryAlbum *)album
{
    _album = album;
    
    // Load cover
    if([_album isCoverFetched] == false) {
        [_album fetchCoverAsync:^() {
            [self setNeedsDisplay:YES];
        }];
    }
}

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
        NSImage *nimage = nil;
        if([_album isCoverFetched]) {
            nimage = [_album cover];
            if(nimage == nil) nimage = [LibraryViewAlbumCell placeholderImage];
        }
        else {
            nimage = [LibraryViewAlbumCell placeholderImage];
        }

        CGContextSaveGState(ctx);
        CGContextAddRect(ctx, CGRectMake(b.origin.x, b.origin.y, imagesize, imagesize));
        CGContextClip(ctx);
        if([nimage size].width < [nimage size].height) { //height larger
            CGFloat excess = imagesize / [nimage size].width * [nimage size].height - imagesize;
            [nimage drawInRect:CGRectMake(b.origin.x, b.origin.y - 0.5*excess, imagesize, imagesize + excess) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        }
        else { //width larger
            CGFloat excess = imagesize / [nimage size].height * [nimage size].width - imagesize;
            [nimage drawInRect:CGRectMake(b.origin.x - 0.5*excess, b.origin.y, imagesize+ excess, imagesize) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        }
        CGContextRestoreGState(ctx);

        NSUInteger trackCount;
        if([_searchMatchedObjects count] == 0) { // no search being done
            trackCount = [[[self album] tracks] count];
        }
        else {
            trackCount = [[[self album] tracksFromSet:[self searchMatchedObjects]] count];
        }

        NSString *str = [[NSString alloc] initWithFormat:@"%ld tracks", trackCount];
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

+(NSImage*)placeholderImage
{
    static dispatch_once_t pred;
    static NSImage *image = nil;

    dispatch_once(&pred, ^{
        image = [[NSImage alloc] initWithContentsOfFile:@"/Library/User Pictures/Instruments/Piano.tif"];
    });

    return image;
}

@end
