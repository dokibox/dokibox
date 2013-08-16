//
//  LibraryViewArtistCell.h
//  dokibox
//
//  Created by Miles Wu on 06/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "TUIKit.h"
#import "LibraryArtist.h"

@interface LibraryViewArtistCell : NSView {
    TUITextRenderer *_textRenderer;
    LibraryArtist *_artist;
}

@property() LibraryArtist* artist;

@end
