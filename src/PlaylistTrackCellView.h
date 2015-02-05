//
//  PlaylistTrackCellView.h
//  dokibox
//
//  Created by Miles Wu on 05/07/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PlaylistTrack.h"

@interface PlaylistTrackCellView : NSView {
    PlaylistTrack *_track;
    NSTextField *_textField;
}

@property PlaylistTrack* track;
@property NSString* columnIdentifier;

@end
