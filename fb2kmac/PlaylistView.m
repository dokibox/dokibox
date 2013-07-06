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

@implementation PlaylistView
@synthesize playlist = _playlist;

- (id)initWithFrame:(NSRect)frame
{
	if((self = [super initWithFrame:frame])) {
        
        _objectContext = [PlaylistCoreDataManager newContext];

        _playlist = [NSEntityDescription insertNewObjectForEntityForName:@"playlist" inManagedObjectContext:_objectContext];
        
        NSRect b = self.bounds;
        NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:b];
        [scrollView setHasVerticalScroller:YES];
        _tableView = [[NSTableView alloc] initWithFrame: [[scrollView contentView] bounds]];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setHeaderView:nil];
        [_tableView setIntercellSpacing:NSMakeSize(0, 0)];
        [_tableView setDoubleAction:@selector(doubleClickReceived:)];
        [scrollView setDocumentView:_tableView];
        
        NSTableColumn *firstColumn = [[NSTableColumn alloc] initWithIdentifier:@"main"];
        [_tableView addTableColumn:firstColumn];
        [firstColumn setWidth:[_tableView bounds].size.width];

        [self addSubview:scrollView];
        
        /*[_tableView setMaintainContentOffsetAfterReload:TRUE];
        [_tableView setClipsToBounds:TRUE];
        [_tableView setPasteboardReceiveDraggingEnabled:TRUE];*/
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedAddTrackToCurrentPlaylistNotification:) name:@"addTrackToCurrentPlaylist" object:nil];
	}
	return self;
}

- (void)receivedAddTrackToCurrentPlaylistNotification:(NSNotification *)notification
{
    NSArray *tracks = [notification object];
    for (NSString *s in tracks) {
        if([MusicController isSupportedAudioFile:s]) {
            PlaylistTrack *t = [PlaylistTrack trackWithFilename:s inContext:_objectContext];
            [_playlist addTrack:t];
        }
    }
    [_tableView reloadData];
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    PlaylistTrackCellView *view = [tableView makeViewWithIdentifier:@"playlistTrackCellView" owner:self];
    
    if(view == nil) {
        NSRect frame = NSMakeRect(0, 0, 0, 0);
        view = [[PlaylistTrackCellView alloc] initWithFrame:frame];
        view.identifier = @"playlistTrackCellView";
    }
    
    [view setTrack:[_playlist trackAtIndex:row]];
    return view;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    CGFloat row_height = 25.0;
    return row_height;
}

- (void)doubleClickReceived:(id)sender
{
    [_playlist playTrackAtIndex:[_tableView clickedRow]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_playlist numberOfTracks];
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
