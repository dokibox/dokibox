//
//  PlaylistView.h
//  fb2kmac
//
//  Created by Miles Wu on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TUIKit.h"
#import "PlaylistTrackCell.h"
#import "PlaylistTrack.h"
#import "Playlist.h"

@interface PlaylistView : TUIView <TUITableViewDelegate, TUITableViewDataSource>
{
    TUITableView *_tableView;
    Playlist *_playlist;
}

- (id)initWithFrame:(CGRect)frame andPlaylist:(Playlist *)playlist;
@property Playlist *playlist;

@end
