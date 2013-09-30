//
//  LibraryViewAlbumCell.h
//  dokibox
//
//  Created by Miles Wu on 06/02/2013.
//
//

#import <Foundation/Foundation.h>

#import "LibraryViewCell.h"

@class LibraryAlbum;
@class ProportionalImageView;

@interface LibraryViewAlbumCell : LibraryViewCell {
    LibraryAlbum *_album;
    
    NSProgressIndicator *_progressIndicator;
    ProportionalImageView *_coverImageView;
}

+(NSImage*)placeholderImage;

@property() LibraryAlbum* album;

@end
