//
//  LibraryViewTrackCell.h
//  dokibox
//
//  Created by Miles Wu on 07/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "LibraryTrack.h"

@interface LibraryViewTrackCell : NSView {
    LibraryTrack *_track;

}

@property() LibraryTrack *track;
@property(assign) BOOL isEvenRow;

@end