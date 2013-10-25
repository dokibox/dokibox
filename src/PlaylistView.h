//
//  PlaylistView.h
//  dokibox
//
//  Created by Miles Wu on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Playlist.h"
#import "RBLTableView.h"

@class PlaylistCoreDataManager;

@interface PlaylistView : NSView <NSTableViewDataSource, NSTableViewDelegate>
{
    RBLTableView *_trackTableView;
    RBLTableView *_playlistTableView;
    Playlist *_currentPlaylist;
    NSArray *_playlists;
    PlaylistCoreDataManager *_playlistCoreDataManger;
    NSManagedObjectContext *_objectContext;
    
    dispatch_queue_t _addingQueue;
}

- (void)addTracksToCurrentPlaylist:(NSArray*)filenames;
- (void)addTracks:(NSArray*)filenames toPlaylist:(Playlist *)p;
- (void)insertTracksToCurrentPlaylist:(NSArray*)filenames atIndex:(NSInteger)index;
- (void)insertTracks:(NSArray*)filenames toPlaylist:(Playlist *)p atIndex:(NSInteger)index;

- (void)fetchPlaylists;
- (void)receivedAddTrackToCurrentPlaylistNotification:(NSNotification *)notification;
- (void)doubleClickReceived:(id)sender;
- (void)newPlaylist;

@property Playlist *currentPlaylist;

@end
