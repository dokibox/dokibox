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
@synthesize searchMatchedObjects = _searchMatchedObjects;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat altTextWidth = 140;
        CGFloat altTextMargin = 10;

        CGRect textRect = NSInsetRect([self bounds], 10, 4);
        //textRect.size.height -= 4;
        //CGRect textRect = CGRectOffset(b, 10, -4);
        
        CGRect nameTextRect = textRect;
        nameTextRect.size.width -= altTextMargin + altTextWidth;
        _nameTextField = [[NSTextField alloc] initWithFrame:textRect];
        [_nameTextField setDelegate:self];
        [_nameTextField setEditable:NO];
        [_nameTextField setBordered:NO];
        [_nameTextField setBezeled:NO];
        [_nameTextField setDrawsBackground:NO];
        [_nameTextField setFont:[NSFont fontWithName:@"Lucida Grande" size:12]];
        [_nameTextField setAutoresizingMask:NSViewWidthSizable | NSViewMaxXMargin];
        [_nameTextField bind:@"value" toObject:self withKeyPath:@"artist.name" options:nil];
        [self addSubview:_nameTextField];
        
        CGRect altTextRect = textRect;
        altTextRect.size.height -= 2;
        altTextRect.size.width = altTextWidth;
        altTextRect.origin.x += textRect.size.width - altTextWidth;
        _altTextField = [[NSTextField alloc] initWithFrame:altTextRect];
        [_altTextField setDelegate:self];
        [_altTextField setEditable:NO];
        [_altTextField setBordered:NO];
        [_altTextField setBezeled:NO];
        [_altTextField setDrawsBackground:NO];
        [_altTextField setFont:[NSFont fontWithName:@"Helvetica-Oblique" size:10]];
        [_altTextField setTextColor:[NSColor colorWithDeviceWhite:0.35 alpha:1.0]];
        [_altTextField setAlignment:NSRightTextAlignment];
        [_altTextField setAutoresizingMask:NSViewMinXMargin];
        [self addSubview:_altTextField];

        [self addObserver:self forKeyPath:@"artist" options:NULL context:nil];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"artist"]) {
        NSUInteger albumCount, trackCount;
        if([_searchMatchedObjects count] == 0) { // no search being done
            albumCount = [[[self artist] albums] count];
            trackCount = [[[self artist] tracks] count];
        }
        else {
            albumCount = [[[self artist] albumsFromSet:[self searchMatchedObjects]] count];
            trackCount = [[[self artist] tracksFromSet:[self searchMatchedObjects]] count];
        }
        NSString *str = [[NSString alloc] initWithFormat:@"%ld albums, %ld tracks", albumCount, trackCount];
        [_altTextField setStringValue:str];
    }
}

- (void)drawRect:(CGRect)rect
{
    // Need a drawRect function for subpixel font rendering to work in NSTextField
}

@end
