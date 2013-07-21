//
//  LibraryViewTrackCell.h
//  dokibox
//
//  Created by Miles Wu on 07/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "TUIKit.h"
#import "LibraryTrack.h"

@interface LibraryViewTrackCell : TUITableViewCell {
    TUITextRenderer *_textRenderer;
    LibraryTrack *_track;

}

@property() LibraryTrack *track;

@end