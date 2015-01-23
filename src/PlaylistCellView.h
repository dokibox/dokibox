//
//  PlaylistCellView.h
//  dokibox
//
//  Created by Miles Wu on 07/07/2013.
//
//

#import <Cocoa/Cocoa.h>
#import "Playlist.h"

@interface PlaylistCellView : NSView < NSTextFieldDelegate > {
    Playlist *_playlist;
    NSTextField *_playlistNameTextField;
    NSTextField *_noTracksTextField;
}

@property() Playlist *playlist;

-(void)focusNameTextField;

@end
