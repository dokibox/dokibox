//
//  LibraryViewAlbumCell.m
//  dokibox
//
//  Created by Miles Wu on 06/02/2013.
//
//

#import "LibraryViewAlbumCell.h"
#import "CoreDataManager.h"
#import "ProportionalImageView.h"
#import "LibraryViewAddButton.h"

@implementation LibraryViewAlbumCell

@synthesize album = _album;
@synthesize searchMatchedObjects = _searchMatchedObjects;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat altTextWidth = 70;
        CGFloat altTextMargin = 10;
        CGFloat imageSize = 50;
        
        CGRect textRect = NSInsetRect([self bounds], 10, 4);
        textRect.size.width -= 12; // for button
        
        CGRect nameTextRect = NSInsetRect(textRect, 0, 12);
        nameTextRect.origin.x += imageSize + 5;
        nameTextRect.size.width -= altTextMargin + altTextWidth + imageSize + 5;
        _nameTextField = [[NSTextField alloc] initWithFrame:nameTextRect];
        [_nameTextField setEditable:NO];
        [_nameTextField setBordered:NO];
        [_nameTextField setBezeled:NO];
        [_nameTextField setDrawsBackground:NO];
        [_nameTextField setFont:[NSFont fontWithName:@"Helvetica-Oblique" size:13]];
        [[_nameTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [_nameTextField setAutoresizingMask:NSViewWidthSizable];
        [_nameTextField bind:@"value" toObject:self withKeyPath:@"album.name" options:nil];
        [self addSubview:_nameTextField];
        
        CGRect altTextRect = NSInsetRect(textRect, 0, 15);
        altTextRect.size.width = altTextWidth;
        altTextRect.origin.x += textRect.size.width - altTextWidth;
        _altTextField = [[NSTextField alloc] initWithFrame:altTextRect];
        [_altTextField setEditable:NO];
        [_altTextField setBordered:NO];
        [_altTextField setBezeled:NO];
        [_altTextField setDrawsBackground:NO];
        [_altTextField setFont:[NSFont fontWithName:@"Helvetica-Oblique" size:10]];
        [_altTextField setTextColor:[NSColor colorWithDeviceWhite:0.35 alpha:1.0]];
        [_altTextField setAlignment:NSRightTextAlignment];
        [_altTextField setAutoresizingMask:NSViewMinXMargin];
        [self addSubview:_altTextField];
        
        CGRect buttonFrame = NSMakeRect([self bounds].size.width-22, NSMidY([self bounds])-10, 20, 20);
        LibraryViewAddButton *addButton = [[LibraryViewAddButton alloc] initWithFrame:buttonFrame];
        [addButton setAutoresizingMask:NSViewMinXMargin];
        [self addSubview:addButton];
        
        _coverImageView = [[ProportionalImageView alloc] initWithFrame:NSMakeRect(0, 0, imageSize, imageSize)];
        [self addSubview:_coverImageView];
    }
    
    return self;
}

- (LibraryAlbum *)album
{
    return _album;
}

- (void)setAlbum:(LibraryAlbum *)album
{
    _album = album;
    
    // Set alt text
    NSUInteger trackCount;
    if([_searchMatchedObjects count] == 0) { // no search being done
        trackCount = [[[self album] tracks] count];
    }
    else {
        trackCount = [[[self album] tracksFromSet:[self searchMatchedObjects]] count];
    }
    
    NSString *str = [[NSString alloc] initWithFormat:@"%ld tracks", trackCount];
    [_altTextField setStringValue:str];
    
    // Load cover
    if([_album isCoverFetched] == false) {
        [_coverImageView setImage:[LibraryViewAlbumCell placeholderImage]];
        if(_progressIndicator == nil) {
            _progressIndicator = [[NSProgressIndicator alloc] init];
            [_progressIndicator sizeToFit]; // this sets the frame height only
            CGFloat imagesize = 50;
            CGRect imrect = CGRectMake([self bounds].origin.x, [self bounds].origin.y, imagesize, imagesize);
            [_progressIndicator setFrame:NSInsetRect(imrect, (imrect.size.width - [_progressIndicator frame].size.height)/2.0, (imrect.size.height - [_progressIndicator frame].size.height)/2.0)];
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

- (void)drawRect:(CGRect)rect
{
    // Need a drawRect function for subpixel font rendering to work in NSTextField
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
