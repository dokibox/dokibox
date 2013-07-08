//
//  PlaylistView.h
//  fb2kmac
//
//  Created by Miles Wu on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TUIKit.h"
#import "Playlist.h"
#import "RBLTableView.h"

@interface PlaylistView : NSView <NSTableViewDataSource, NSTableViewDelegate>
{
    RBLTableView *_trackTableView;
    RBLTableView *_playlistTableView;
    Playlist *_currentPlaylist;
    NSArray *_playlists;
    NSManagedObjectContext *_objectContext;
}

- (void)fetchPlaylists;
- (void)receivedAddTrackToCurrentPlaylistNotification:(NSNotification *)notification;
- (void)doubleClickReceived:(id)sender;

@property Playlist *currentPlaylist;

@end
