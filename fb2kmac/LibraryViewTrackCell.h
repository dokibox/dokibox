//
//  LibraryViewTrackCell.h
//  fb2kmac
//
//  Created by Miles Wu on 07/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "TUIKit.h"
#import "Track.h"

@interface LibraryViewTrackCell : TUITableViewCell {
    TUITextRenderer *_textRenderer;
    Track *_track;
    
}

@property() Track *track;

@end