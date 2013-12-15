//
//  PlaylistTrackPlayingCellView.h
//  dokibox
//
//  Created by Miles Wu on 15/12/2013.
//
//

#import <Cocoa/Cocoa.h>

@class PlaylistTrack;

@interface PlaylistTrackPlayingCellView : NSTableCellView {
    PlaylistTrack *_track;
}

@property PlaylistTrack* track;

@end
