//
//  LibraryViewAlbumCell.h
//  dokibox
//
//  Created by Miles Wu on 06/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "LibraryAlbum.h"

@interface LibraryViewAlbumCell : NSView {
    LibraryAlbum *_album;
    NSProgressIndicator *_progressIndicator;
}

+(NSImage*)placeholderImage;

@property() LibraryAlbum* album;
@property(weak) NSSet* searchMatchedObjects;

@end
