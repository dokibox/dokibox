//
//  LibraryViewArtistCell.m
//  dokibox
//
//  Created by Miles Wu on 06/02/2013.
//
//

#import "LibraryViewArtistCell.h"
#import "LibraryAlbum.h"
#import "LibraryArtist.h"

@implementation LibraryViewArtistCell

@synthesize artist = _artist;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat altTextWidth = 140;
        CGFloat altTextMargin = 10;
        
        CGRect nameTextRect = _textRect;
        nameTextRect.size.width -= altTextMargin + altTextWidth;
        [_nameTextField setFrame:nameTextRect];
        [_nameTextField setFont:[NSFont fontWithName:@"Lucida Grande" size:12]];
        [_nameTextField bind:@"value" toObject:self withKeyPath:@"artist.name" options:nil];
        
        CGRect altTextRect = _textRect;
        altTextRect.size.height -= 2;
        altTextRect.size.width = altTextWidth;
        altTextRect.origin.x += _textRect.size.width - altTextWidth;
        [_altTextField setFrame:altTextRect];
        
        [self addObserver:self forKeyPath:@"artist" options:NULL context:nil];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"artist"]) {
        NSUInteger albumCount, trackCount;
        if([[self searchMatchedObjects] count] == 0) { // no search being done
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

@end
