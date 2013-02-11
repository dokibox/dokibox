//
//  LibraryViewAlbumCell.h
//  fb2kmac
//
//  Created by Miles Wu on 06/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "TUIKit.h"
#import "Album.h"

@interface LibraryViewAlbumCell : TUITableViewCell {
    TUITextRenderer *_textRenderer;
    Album *_album;
}

@property() Album* album;

@end
