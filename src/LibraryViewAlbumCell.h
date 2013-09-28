//
//  LibraryViewAlbumCell.h
//  dokibox
//
//  Created by Miles Wu on 06/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "LibraryAlbum.h"

@class ProportionalImageView;

@interface LibraryViewAlbumCell : NSView {
    LibraryAlbum *_album;
    
    NSProgressIndicator *_progressIndicator;
    NSTextField *_nameTextField;
    NSTextField *_altTextField;
    ProportionalImageView *_coverImageView;
}

+(NSImage*)placeholderImage;

@property() LibraryAlbum* album;
@property(weak) NSSet* searchMatchedObjects;

@end
