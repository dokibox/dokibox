//
//  LibraryViewAlbumCell.h
//  dokibox
//
//  Created by Miles Wu on 06/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "TUIKit.h"
#import "LibraryAlbum.h"

@interface LibraryViewAlbumCell : TUITableViewCell {
    TUITextRenderer *_textRenderer;
    LibraryAlbum *_album;
}

@property() LibraryAlbum* album;

@end
