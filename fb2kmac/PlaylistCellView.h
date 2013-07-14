//
//  PlaylistCellView.h
//  fb2kmac
//
//  Created by Miles Wu on 07/07/2013.
//
//

#import <Cocoa/Cocoa.h>
#import "Playlist.h"

@interface PlaylistCellView : NSView {
    Playlist *_playlist;
    NSTextField *_playlistNameTextField;
}

@property() Playlist *playlist;

@end
