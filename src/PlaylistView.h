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
@class RBLScrollView;

@interface PlaylistView : NSView <NSTableViewDataSource, NSTableViewDelegate>
{
    RBLScrollView *_trackScrollView;
    RBLScrollView *_playlistScrollView;
    NSTableView *_trackTableView;
    NSTableView *_playlistTableView;
    NSView *_playlistTableHeader;
    Playlist *_currentPlaylist;
    NSArray *_playlists;
    PlaylistCoreDataManager *_playlistCoreDataManger;
    NSManagedObjectContext *_objectContext;
    
    dispatch_queue_t _addingQueue;
    
    NSTrackingArea *_dividerTrackingArea;
    BOOL _dividerBeingDragged;
    CGFloat _playlistHeight;
    BOOL _playlistsVisible;
}

- (void)updateDividerTrackingArea;
- (NSRect)playlistScrollViewFrame;
- (NSRect)trackScrollViewFrame;
- (NSRect)playlistTableHeaderFrame;

- (void)setPlaylistVisiblity:(BOOL)visible;

- (void)addTracksToCurrentPlaylist:(NSArray*)filenames;
- (void)addTracks:(NSArray*)filenames toPlaylist:(Playlist *)p;
- (void)insertTracksToCurrentPlaylist:(NSArray*)filenames atIndex:(NSInteger)index;
- (void)insertTracks:(NSArray*)filenames toPlaylist:(Playlist *)p atIndex:(NSInteger)index;

- (void)removeOrphanedPlaylistTracks;
- (void)fetchPlaylists;
- (void)receivedAddTrackToCurrentPlaylistNotification:(NSNotification *)notification;
- (void)doubleClickReceived:(id)sender;
- (void)newPlaylist;

@property Playlist *currentPlaylist;

@end
