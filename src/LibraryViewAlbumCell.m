//
//  LibraryViewAlbumCell.m
//  dokibox
//
//  Created by Miles Wu on 06/02/2013.
//
//

#import "LibraryViewAlbumCell.h"
#import "ProportionalImageView.h"
#import "LibraryAlbum.h"

@implementation LibraryViewAlbumCell

@synthesize album = _album;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat imageSize = 50;

        CGRect nameTextRect = NSInsetRect(_textRect, 0, 12);
        nameTextRect.origin.x += 10;
        nameTextRect.origin.y += 5;
        nameTextRect.size.width -= imageSize + 10;
        [_nameTextField setFrame:nameTextRect];
        [_nameTextField setFont:[[NSFontManager sharedFontManager] convertFont:[NSFont systemFontOfSize:13] toHaveTrait:NSItalicFontMask]];
        [_nameTextField bind:@"value" toObject:self withKeyPath:@"album.name" options:nil];
        
        CGRect altTextRect = nameTextRect;
        altTextRect.origin.y -= 16;
        [_altTextField setFrame: altTextRect];
        [_altTextField setAutoresizingMask:NSViewWidthSizable];
        [_altTextField setAlignment:NSLeftTextAlignment];
        [self addSubview:_altTextField];
                
        _coverImageView = [[ProportionalImageView alloc] initWithFrame:NSMakeRect([self bounds].size.width - imageSize, 0, imageSize, imageSize)];
        [_coverImageView setAutoresizingMask:NSViewMinXMargin];
        [self addSubview:_coverImageView];
        
        [self addObserver:self forKeyPath:@"album" options:NULL context:nil];
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:@"libraryViewShowPlacerholderAlbumCovers" options:NSKeyValueObservingOptionNew context:NULL];
    }
    
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"album"];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:@"libraryViewShowPlacerholderAlbumCovers"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"album"]) {
        // Set alt text
        NSUInteger trackCount;
        if([[self searchMatchedObjects] count] == 0) { // no search being done
            trackCount = [[[self album] tracks] count];
        }
        else {
            trackCount = [[[self album] tracksFromSet:[self searchMatchedObjects]] count];
        }
        NSString *str = [[NSString alloc] initWithFormat:@"%ld track%@", trackCount, trackCount>1 ? @"s" : @""];
        [_altTextField setStringValue:str];
        
        // Load cover
        if([_album isCoverFetched] == false) {
            [_coverImageView setImage:[LibraryViewAlbumCell placeholderImage]];
            if(_progressIndicator == nil) {
                _progressIndicator = [[NSProgressIndicator alloc] init];
                CGFloat imagesize = 50;
                CGRect imrect = CGRectMake([self bounds].origin.x + [self bounds].size.width - imagesize, [self bounds].origin.y, imagesize, imagesize);
                [_progressIndicator setFrame:imrect];
                [_progressIndicator setStyle: NSProgressIndicatorSpinningStyle];
                [_progressIndicator setUsesThreadedAnimation:YES];
                
                [_progressIndicator startAnimation:self];
                // NB: This causes weird flashing: in particular if you add new spinning progress indicators for other albums
                // (say during expansion) it causes all of them to flash white sometimes.
                
                [self addSubview:_progressIndicator];
            }
            
            [_album fetchCoverAsync:^(LibraryAlbum *album) {
                if(album != _album) {
                    // If the album cell view is reused and assigned to another Album while this fetch is running,
                    // _album will have changed by the time the callback block runs. The new _album might not have a
                    // cover loaded as the callback is telling us the old _album now has a cover, so we ignore this callback
                    return;
                }
                
                if(_progressIndicator) {
                    [_progressIndicator stopAnimation:self];
                    [_progressIndicator removeFromSuperview];
                    _progressIndicator = nil;
                }
                
                if([_album cover])
                    [_coverImageView setImage:[_album cover]];
            }];
        }
        else {
            if([_album cover])
                [_coverImageView setImage:[_album cover]];
            else
                [_coverImageView setImage:[LibraryViewAlbumCell placeholderImage]];
        }
    }
    else if([keyPath isEqualToString:@"libraryViewShowPlacerholderAlbumCovers"]) {
        // This is needed for when the preference is updated and we need to either show the placeholder or hide it
        if([_album cover] == nil) {
            [_coverImageView setImage:[LibraryViewAlbumCell placeholderImage]];
        }
    }
}

+(NSImage*)placeholderImage
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"libraryViewShowPlacerholderAlbumCovers"] == YES) {
        static dispatch_once_t pred;
        static NSImage *image = nil;

        dispatch_once(&pred, ^{
            image = [[NSImage alloc] initWithContentsOfFile:@"/Library/User Pictures/Instruments/Piano.tif"];
        });
        
        return image;
    }
    else {
        return nil;
    }
}

@end
