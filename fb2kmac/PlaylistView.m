//
//  PlaylistView.m
//  fb2kmac
//
//  Created by Miles Wu on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaylistView.h"
#import "PlaylistTrack.h"
#import "MusicController.h"
#import "PlaylistCoreDataManager.h"
#import "PlaylistTrackCellView.h"
#import "PlaylistTrackRowView.h"
#import "RBLScrollView.h"
#import "PlaylistCellView.h"
#import "PlaylistRowView.h"

@implementation PlaylistView
@synthesize currentPlaylist = _currentPlaylist;

#define playlistHeight 100

- (id)initWithFrame:(NSRect)frame
{
	if((self = [super initWithFrame:frame])) {
        
        // Fetch stuff
        _objectContext = [PlaylistCoreDataManager newContext];
        [self fetchPlaylists];
        
        // Playlist table view
        NSRect playlistScrollViewFrame = self.bounds;
        playlistScrollViewFrame.size.height = playlistHeight;
        RBLScrollView *playlistScrollView = [[RBLScrollView alloc] initWithFrame:playlistScrollViewFrame];
        [playlistScrollView setHasVerticalScroller:YES];
        _playlistTableView = [[RBLTableView alloc] initWithFrame: [[playlistScrollView contentView] bounds]];
        [_playlistTableView setDelegate:self];
        [_playlistTableView setDataSource:self];
        [_playlistTableView setHeaderView:nil];
        [_playlistTableView setIntercellSpacing:NSMakeSize(0, 0)];
        [_playlistTableView setAllowsEmptySelection:NO];
        [_playlistTableView setDoubleAction:@selector(doubleClickReceived:)];
        [playlistScrollView setDocumentView:_playlistTableView];
        [playlistScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable | NSViewMaxYMargin];
        NSTableColumn *playlistFirstColumn = [[NSTableColumn alloc] initWithIdentifier:@"main"];
        [_playlistTableView addTableColumn:playlistFirstColumn];
        [playlistFirstColumn setWidth:[_playlistTableView bounds].size.width];
        [self addSubview:playlistScrollView];
        [_playlistTableView reloadData];

        // Select first playlist
        if([_playlists count] == 0) {
            [self newPlaylist];
        }
        [_playlistTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];

        
        // Track table view
        NSRect trackScrollViewFrame = self.bounds;
        trackScrollViewFrame.origin.y += playlistHeight;
        trackScrollViewFrame.size.height -= playlistHeight;
        RBLScrollView *trackScrollView = [[RBLScrollView alloc] initWithFrame:trackScrollViewFrame];
        [trackScrollView setHasVerticalScroller:YES];
        _trackTableView = [[RBLTableView alloc] initWithFrame: [[trackScrollView contentView] bounds]];
        [_trackTableView setDelegate:self];
        [_trackTableView setDataSource:self];
        [_trackTableView setHeaderView:nil];
        [_trackTableView setIntercellSpacing:NSMakeSize(0, 0)];
        [_trackTableView setDoubleAction:@selector(doubleClickReceived:)];
        [_trackTableView setAllowsMultipleSelection:YES];
        [trackScrollView setDocumentView:_trackTableView];
        [trackScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable | NSViewMinYMargin];

        
        NSTableColumn *trackFirstColumn = [[NSTableColumn alloc] initWithIdentifier:@"main"];
        [_trackTableView addTableColumn:trackFirstColumn];
        [trackFirstColumn setWidth:[_trackTableView bounds].size.width];

        [self addSubview:trackScrollView];
        [_trackTableView reloadData];
        
        

        /*[_tableView setMaintainContentOffsetAfterReload:TRUE];
        [_tableView setClipsToBounds:TRUE];
        [_tableView setPasteboardReceiveDraggingEnabled:TRUE];*/
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedAddTrackToCurrentPlaylistNotification:) name:@"addTrackToCurrentPlaylist" object:nil];
	}
	return self;
}

- (void)fetchPlaylists
{
    NSError *error;
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"playlist"];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                initWithKey:@"name"
                                ascending:YES
                                selector:@selector(localizedCaseInsensitiveCompare:)];
    [fr setSortDescriptors:[NSArray arrayWithObjects:sorter, nil]];
    _playlists = [_objectContext executeFetchRequest:fr error:&error];
}

- (void)newPlaylist
{
    _currentPlaylist = [NSEntityDescription insertNewObjectForEntityForName:@"playlist" inManagedObjectContext:_objectContext];
    [_currentPlaylist setName:@"New playlist"];
    [_currentPlaylist save];
    [self fetchPlaylists];
    [_playlistTableView reloadData];
    [_playlistTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[_playlists indexOfObject:_currentPlaylist]] byExtendingSelection:NO];
}

- (void)receivedAddTrackToCurrentPlaylistNotification:(NSNotification *)notification
{
    NSArray *tracks = [notification object];
    for (NSString *s in tracks) {
        if([MusicController isSupportedAudioFile:s]) {
            PlaylistTrack *t = [PlaylistTrack trackWithFilename:s andPlaylist:_currentPlaylist inContext:_objectContext];
            [_currentPlaylist addTrack:t];
        }
    }
    [_trackTableView reloadData];
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    if(tableView == _trackTableView) {
        PlaylistTrackCellView *view = [tableView makeViewWithIdentifier:@"playlistTrackCellView" owner:self];
        
        if(view == nil) {
            NSRect frame = NSMakeRect(0, 0, 200, 55);
            view = [[PlaylistTrackCellView alloc] initWithFrame:frame];
            view.identifier = @"playlistTrackCellView";
        }
        
        [view setTrack:[_currentPlaylist trackAtIndex:row]];
        return view;
    }
    else if (tableView == _playlistTableView) {
        PlaylistCellView *view = [tableView makeViewWithIdentifier:@"playlistCellView" owner:self];
        
        if(view == nil) {
            NSRect frame = NSMakeRect(0, 0, 200, 22);
            view = [[PlaylistCellView alloc] initWithFrame:frame];
            view.identifier = @"playlistCellView";
        }
        
        [view setPlaylist:[_playlists objectAtIndex:row]];
        return view;
    }
    else {
        DDLogError(@"Unknown table view");
        return nil;
    }

}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    if(tableView == _trackTableView) {
        return 55.0;
    }
    else if (tableView == _playlistTableView) {
        return 22.0;
    }
    else {
        DDLogError(@"Unknown table view");
        return 0.0;
    }
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    if(tableView == _trackTableView) {
        PlaylistTrackRowView *view = [tableView makeViewWithIdentifier:@"playlistTrackRowView" owner:self];
        
        if(view == nil) {
            NSRect frame = NSMakeRect(0, 0, 0, 0);
            view = [[PlaylistTrackRowView alloc] initWithFrame:frame];
            view.identifier = @"playlistTrackRowView";
        }
        
        return view;
    }
    else if (tableView == _playlistTableView) {
        PlaylistRowView *view = [tableView makeViewWithIdentifier:@"playlistRowView" owner:self];
        
        if(view == nil) {
            NSRect frame = NSMakeRect(0, 0, 0, 0);
            view = [[PlaylistRowView alloc] initWithFrame:frame];
            view.identifier = @"playlistRowView";
        }
        
        return view;
    }
    else {
        DDLogError(@"Unknown table view");
        return nil;
    }
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if([notification object] == _playlistTableView) {
        _currentPlaylist = [_playlists objectAtIndex:[_playlistTableView selectedRow]];
        [_trackTableView reloadData];
    }
}

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem
{
    SEL action = [anItem action];
    if(action == @selector(delete:)) {
        id selectedTableView = [[self window] firstResponder];
        if(selectedTableView == _playlistTableView && [[_playlistTableView selectedRowIndexes] count] != 0)
            return YES;
        if(selectedTableView == _trackTableView && [[_trackTableView selectedRowIndexes] count] != 0)
            return YES;
        else
            return NO;
    }
    else {
        return NO;
    }
}

- (IBAction)delete:(id)sender
{
    id selectedTableView = [[self window] firstResponder];
    if(selectedTableView == _playlistTableView) {
        for(PlaylistTrack *t in [_currentPlaylist tracks])
            [_objectContext deleteObject:t];
        [_objectContext deleteObject:_currentPlaylist];
        [_currentPlaylist save];
        [self fetchPlaylists];
        if([_playlists count] == 0) {
            [self newPlaylist];
        }
        else {
            [_playlistTableView reloadData];
            [_playlistTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        }
    }
    else if (selectedTableView == _trackTableView) {
        NSIndexSet *indexSet = [_trackTableView selectedRowIndexes];
        NSUInteger index = [indexSet firstIndex];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        while (index != NSNotFound) {
            [arr addObject:[_currentPlaylist trackAtIndex:index]];
            index = [indexSet indexGreaterThanIndex:index];
        }
        for (PlaylistTrack *t in arr) {
            [_objectContext deleteObject:t];
        }
        [_currentPlaylist save];
        [_trackTableView reloadData];
    }
    else {
        DDLogError(@"Unknown table view");
    }
}

- (void)doubleClickReceived:(id)sender
{
    if(sender == _trackTableView)
        [_currentPlaylist playTrackAtIndex:[_trackTableView clickedRow]];
    else if (sender == _playlistTableView) {
        
    }
    else {
        DDLogError(@"Unknown table view");
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if(tableView == _trackTableView)
        return [_currentPlaylist numberOfTracks];
    else if (tableView == _playlistTableView)
        return [_playlists count];
    else {
        DDLogError(@"Unknown table view");
        return 0;
    }
}

/*
-(BOOL)tableView:(TUITableView *)tableView canMoveRowAtIndexPath:(TUIFastIndexPath *)indexPath {
    // return TRUE to enable row reordering by dragging; don't implement this method or return
    // FALSE to disable
    return TRUE;
}

-(void)tableView:(TUITableView *)tableView moveRowAtIndexPath:(TUIFastIndexPath *)fromIndexPath toIndexPath:(TUIFastIndexPath *)toIndexPath {
    PlaylistTrack *t = [_playlist trackAtIndex:[fromIndexPath row]];
    [_playlist removeTrackAtIndex:[fromIndexPath row]];
    [_playlist insertTrack:t atIndex:[toIndexPath row]];
}

- (BOOL)tableView:(TUITableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info path:(TUIFastIndexPath *)path
{
    NSArray *filenames = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    int count=0;
    for (NSString *s in [filenames reverseObjectEnumerator]) {
        if([MusicController isSupportedAudioFile:s]) {
            count++;
            PlaylistTrack *t = [PlaylistTrack trackWithFilename:s inContext:_objectContext];
            if([path row] == [_playlist numberOfTracks])
                [_playlist addTrack:t];
            else
                [_playlist insertTrack:t atIndex:[path row]];
        }
    }
    
    if(count == 0)
        return NO;
    else
        return YES;
}

- (NSDragOperation)tableView:(TUITableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedPath:(TUIFastIndexPath *)path
{
    NSArray *filenames = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    int count=0;
    for (NSString *s in filenames)
        if([MusicController isSupportedAudioFile:s])
            count++;
    
    if(count == 0) {
        return NSDragOperationNone;
    }
    else {
        return NSDragOperationCopy;
    }
}

- (float)tableView:(TUITableView *)aTableView heightForDropGapAtIndexPath:(TUIFastIndexPath *)path drop:(id < NSDraggingInfo >)info
{
    NSArray *filenames = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    int count=0;
    for (NSString *s in filenames)
        if([MusicController isSupportedAudioFile:s])
            count++;
    
    return ((float)count)*25.0;
}
*/

@end
