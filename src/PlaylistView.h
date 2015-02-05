//
//  PlaylistView.h
//  dokibox
//
//  Created by Miles Wu on 01/07/2012.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "Playlist.h"

@class PlaylistCoreDataManager;
@class RBLScrollView;
@class Library;

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
    
    Library *_library;
    
    dispatch_queue_t _addingQueue;
    
    NSTrackingArea *_dividerTrackingArea;
    BOOL _dividerBeingDragged;
    CGFloat _playlistHeight;
    BOOL _playlistsVisible;
}

- (id)initWithFrame:(CGRect)frame andLibrary:(Library *)library;

- (void)updateDividerTrackingArea;
- (NSRect)playlistScrollViewFrame;
- (NSRect)trackScrollViewFrame;
- (NSRect)playlistTableHeaderFrame;

- (void)setPlaylistVisiblity:(BOOL)visible;

- (void)addTracksToCurrentPlaylistFromFilenames:(NSArray*)filenames;
- (void)addTracksFromFilenames:(NSArray*)filenames toPlaylist:(Playlist *)p;
- (void)insertTracksToCurrentPlaylistFromFilenames:(NSArray*)filenames atIndex:(NSInteger)index;
- (void)insertTracksFromFilenames:(NSArray*)filenames toPlaylist:(Playlist *)p atIndex:(NSInteger)index;

- (void)addTracksToCurrentPlaylistFromLibraryTracks:(NSArray*)libraryTracks;
- (void)addTracksFromLibraryTracks:(NSArray*)libraryTracks toPlaylist:(Playlist *)p;
- (void)insertTracksToCurrentPlaylistFromLibraryTracks:(NSArray*)libraryTracks atIndex:(NSInteger)index;
- (void)insertTracksFromLibraryTracks:(NSArray*)libraryTracks toPlaylist:(Playlist *)p atIndex:(NSInteger)index;

- (void)removeOrphanedPlaylistTracks;
- (void)fetchPlaylists;
- (void)receivedAddTrackToCurrentPlaylistNotification:(NSNotification *)notification;
- (void)doubleClickReceived:(id)sender;
- (void)newPlaylist;

@property Playlist *currentPlaylist;

@end
