//
//  PlaylistView.h
//  fb2kmac
//
//  Created by Miles Wu on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TUIKit.h"
#import "Playlist.h"

@interface PlaylistView : NSView <NSTableViewDataSource, NSTableViewDelegate>
{
    NSTableView *_tableView;
    Playlist *_playlist;
    NSManagedObjectContext *_objectContext;
}

- (void)receivedAddTrackToCurrentPlaylistNotification:(NSNotification *)notification;
- (void)doubleClickReceived:(id)sender;

@property Playlist *playlist;

@end
