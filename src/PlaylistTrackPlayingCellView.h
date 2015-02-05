//
//  PlaylistTrackPlayingCellView.h
//  dokibox
//
//  Created by Miles Wu on 15/12/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PlaylistTrack;

@interface PlaylistTrackPlayingCellView : NSTableCellView {
    PlaylistTrack *_track;
}

@property PlaylistTrack* track;

@end
