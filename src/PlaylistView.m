//
//  PlaylistView.m
//  dokibox
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
#import "NSView+CGDrawing.h"

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
        playlistScrollViewFrame.size.height = playlistHeight - 15.0;
        RBLScrollView *playlistScrollView = [[RBLScrollView alloc] initWithFrame:playlistScrollViewFrame];
        [playlistScrollView setHasVerticalScroller:YES];
        _playlistTableView = [[RBLTableView alloc] initWithFrame: [[playlistScrollView contentView] bounds]];
        [_playlistTableView setDelegate:self];
        [_playlistTableView setDataSource:self];
        [_playlistTableView registerForDraggedTypes:[NSArray arrayWithObjects:@"trackFilenames", NSFilenamesPboardType, @"playlistTrackIDs", nil]];
        [_playlistTableView setHeaderView:nil];
        [_playlistTableView setIntercellSpacing:NSMakeSize(0, 0)];
        [_playlistTableView setAllowsEmptySelection:NO];
        [_playlistTableView setDoubleAction:@selector(doubleClickReceived:)];
        [playlistScrollView setDocumentView:_playlistTableView];
        [playlistScrollView setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];
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
        [_trackTableView registerForDraggedTypes:[NSArray arrayWithObjects:@"trackFilenames", NSFilenamesPboardType, @"playlistTrackIDs", nil]];
        [_trackTableView setHeaderView:nil];
        [_trackTableView setIntercellSpacing:NSMakeSize(0, 0)];
        [_trackTableView setDoubleAction:@selector(doubleClickReceived:)];
        [_trackTableView setAllowsMultipleSelection:YES];
        [trackScrollView setDocumentView:_trackTableView];
        [trackScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];


        NSTableColumn *trackFirstColumn = [[NSTableColumn alloc] initWithIdentifier:@"main"];
        [_trackTableView addTableColumn:trackFirstColumn];
        [trackFirstColumn setWidth:[_trackTableView bounds].size.width];

        [self addSubview:trackScrollView];
        [_trackTableView reloadData];

        /*[_tableView setMaintainContentOffsetAfterReload:TRUE];
        [_tableView setClipsToBounds:TRUE];
        [_tableView setPasteboardReceiveDraggingEnabled:TRUE];*/
        
        _addingQueue = dispatch_queue_create(NULL, NULL);

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedAddTrackToCurrentPlaylistNotification:) name:@"addTrackToCurrentPlaylist" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPlaylistSavedNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize
{
    [super resizeSubviewsWithOldSize:oldBoundsSize];
    [[[_playlistTableView tableColumns] objectAtIndex:0] setWidth:[_playlistTableView bounds].size.width];
    [[[_trackTableView tableColumns] objectAtIndex:0] setWidth:[_trackTableView bounds].size.width];
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];

    CGRect barRect = [self bounds];
    barRect.origin.y += playlistHeight - 15.0;
    barRect.size.height = 15.0;

    [self CGContextVerticalGradient:barRect context:ctx bottomColor:[NSColor colorWithDeviceWhite:0.8 alpha:1.0] topColor:[NSColor colorWithDeviceWhite:0.92 alpha:1.0]];

    // Line top/bottom
    CGContextSetStrokeColorWithColor(ctx, [[NSColor colorWithDeviceWhite:0.8 alpha:1.0] CGColor]);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, barRect.origin.x, barRect.origin.y + barRect.size.height - 0.5);
    CGContextAddLineToPoint(ctx, barRect.origin.x + barRect.size.width, barRect.origin.y + barRect.size.height - 0.5);
    CGContextStrokePath(ctx);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, barRect.origin.x, barRect.origin.y + 0.5);
    CGContextAddLineToPoint(ctx, barRect.origin.x + barRect.size.width, barRect.origin.y + 0.5);
    CGContextStrokePath(ctx);

    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    [attr setObject:[NSFont fontWithName:@"Lucida Grande" size:9] forKey:NSFontAttributeName];
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Playlist Collection" attributes:attr];
    CGPoint strPoint = NSMakePoint(barRect.origin.x + barRect.size.width/2.0 - [str size].width/2.0, barRect.origin.y + barRect.size.height/2.0 - [str size].height/2.0);
    CGContextSetShouldSmoothFonts(ctx, YES);
    [str drawAtPoint:strPoint];
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

- (void)addTracks:(NSArray*)filenames toPlaylist:(Playlist *)p
{
    [self insertTracksToCurrentPlaylist:filenames atIndex:-1];
}

- (void)addTracksToCurrentPlaylist:(NSArray*)filenames
{
    [self addTracks:filenames toPlaylist:_currentPlaylist];
}

- (void)insertTracksToCurrentPlaylist:(NSArray*)filenames atIndex:(NSInteger)index
{
    [self insertTracks:filenames toPlaylist:_currentPlaylist atIndex:index];
}

- (void)insertTracks:(NSArray*)filenames toPlaylist:(Playlist *)p atIndex:(NSInteger)index;
{
    Playlist *playlistMainThread = p;
    NSManagedObjectID *playlistID = [playlistMainThread objectID];
    
    dispatch_async(_addingQueue, ^() { // Do in background thread to prevent ui lockup
        NSInteger block_index = index;
        NSManagedObjectContext *context = [PlaylistCoreDataManager newContext];
        Playlist *playlist = (Playlist*)[context objectWithID:playlistID];
        
        for (NSString *s in filenames) {
            if([MusicController isSupportedAudioFile:s]) {
                if(block_index < 0) {
                    [playlist addTrackWithFilename:s];
                }
                else {
                    [playlist insertTrackWithFilename:s atIndex:block_index];
                    block_index = block_index + 1;
                }
                [playlist save];
                
                // Update UI
                dispatch_sync(dispatch_get_main_queue(), ^() {
                    if(playlistMainThread == _currentPlaylist) // selection could have changed, so no point updating if it has
                        [_trackTableView reloadData];
                });
            }
        }
    });
}

-(void)receivedPlaylistSavedNotification:(NSNotification *)notification
{
    if([PlaylistCoreDataManager contextBelongs:[notification object]] == false) return;
    if([notification object] == _objectContext) return;
    
    dispatch_sync(dispatch_get_main_queue(), ^() {
        [_objectContext mergeChangesFromContextDidSaveNotification:notification];
    });
}


- (void)receivedAddTrackToCurrentPlaylistNotification:(NSNotification *)notification
{
    NSArray *tracks = [notification object];
    [self addTracksToCurrentPlaylist:tracks];
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {

    if(tableView == _trackTableView) {
        PlaylistTrackCellView *view = [tableView makeViewWithIdentifier:@"playlistTrackCellView" owner:self];

        if(view == nil) {
            NSRect frame = NSMakeRect(0, 0, 200, 25);
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
        return 25.0;
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
            [_currentPlaylist removeTrack:t];
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
            [_currentPlaylist removeTrack:t];
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
    if(sender == _trackTableView) {
        if([_trackTableView clickedRow] != -1)
            [_currentPlaylist playTrackAtIndex:[_trackTableView clickedRow]];
    }
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

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    if(tableView == _trackTableView || tableView == _playlistTableView) {
        if(tableView == _trackTableView) {
            [tableView setDropRow:row dropOperation:NSTableViewDropAbove];
        }
        if(tableView == _playlistTableView) {
            NSPoint dragPosition = [tableView convertPoint:[info draggingLocation] fromView:nil];
            row = [tableView rowAtPoint:dragPosition];
            if(row == -1)
                return NSDragOperationNone;
            [tableView setDropRow:row dropOperation:NSTableViewDropOn];
        }
        
        NSPasteboard *pboard = [info draggingPasteboard];
        if([[pboard types] containsObject:@"trackFilenames"]) {
            return NSDragOperationCopy;
        }
        else if([[pboard types] containsObject:NSFilenamesPboardType]) {
            return NSDragOperationCopy;
        }
        else if([[pboard types] containsObject:@"playlistTrackIDs"]) {
            if([[[NSApplication sharedApplication] currentEvent] modifierFlags] & NSAlternateKeyMask)
                return NSDragOperationCopy;
            else
                return NSDragOperationMove;
        }
    }
    
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    NSPasteboard *pboard = [info draggingPasteboard];
    NSArray *arr;
    
    Playlist *p;
    if(tableView == _playlistTableView) {
        p = [_playlists objectAtIndex:row];
        row = [[p tracks] count];
    }
    else if(tableView == _trackTableView) {
        p = _currentPlaylist;
    }
    else {
        DDLogError(@"Unrecognized tableView in acceptDrop:");
        return NO;
    }
    
    if([[pboard types] containsObject:@"trackFilenames"]) {
        arr = [NSKeyedUnarchiver unarchiveObjectWithData:[pboard dataForType:@"trackFilenames"]];
        [self insertTracks:arr toPlaylist:p atIndex:row];
        return YES;
    }
    else if([[pboard types] containsObject:NSFilenamesPboardType]) {
        arr = [pboard propertyListForType:NSFilenamesPboardType];
        [self insertTracks:arr toPlaylist:p atIndex:row];
        return YES;
    }
    
    else if([[pboard types] containsObject:@"playlistTrackIDs"]) {
        arr = [NSKeyedUnarchiver unarchiveObjectWithData:[pboard dataForType:@"playlistTrackIDs"]];
        NSMutableArray *tracks = [[NSMutableArray alloc] init];

        for(NSURL *url in arr) {
            NSManagedObjectID *objectID = [[_objectContext persistentStoreCoordinator] managedObjectIDForURIRepresentation:url];
            if(objectID == nil) {
                continue;
            }
            
            PlaylistTrack *t = (PlaylistTrack*)[_objectContext objectWithID:objectID];
            [tracks addObject:t];
        }
        
        if([info draggingSourceOperationMask] & NSDragOperationMove) {
            for(PlaylistTrack *t in tracks) {
                [p insertTrack:t atIndex:row];
                row++;
            }
            
            [p save];
            [_trackTableView reloadData];
            return YES;
        }
        
        if([info draggingSourceOperationMask] & NSDragOperationCopy) {
            NSMutableArray *filenames = [[NSMutableArray alloc] init];
            for(PlaylistTrack *t in tracks) {
                [filenames addObject:[t filename]];
            }

            [self insertTracks:filenames toPlaylist:p atIndex:row];
            return YES;
        }

        return NO;
    }
    
    
    else {
        DDLogError(@"Unrecognized pasteboard type");
        return NO;
    }
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
    if(tableView == _trackTableView) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        NSUInteger i = [rowIndexes firstIndex];
        while(i != NSNotFound) {
            [arr addObject:[[[_currentPlaylist trackAtIndex:i] objectID] URIRepresentation]];
            i = [rowIndexes indexGreaterThanIndex: i];
        }
        
        NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:arr];
        [pboard declareTypes:[NSArray arrayWithObject:@"playlistTrackIDs"] owner:self];
        [pboard setData:archivedData forType:@"playlistTrackIDs"];
        return YES;
    }
    
    return NO;
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
