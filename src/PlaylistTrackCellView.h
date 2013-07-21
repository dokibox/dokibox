//
//  PlaylistTrackCellView.h
//  dokibox
//
//  Created by Miles Wu on 05/07/2013.
//
//

#import <Cocoa/Cocoa.h>
#import "PlaylistTrack.h"

@interface PlaylistTrackCellView : NSView {
    PlaylistTrack *_track;
}

@property PlaylistTrack* track;


@end
