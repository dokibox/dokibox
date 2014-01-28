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
#import "NSManagedObjectContext+Helpers.h"
#import "PlaylistTrackHeaderCell.h"
#import "PlaylistTrackPlayingCellView.h"
#import "PlaylistTableHeader.h"

@implementation PlaylistView
@synthesize currentPlaylist = _currentPlaylist;

- (id)initWithFrame:(NSRect)frame
{
    if((self = [super initWithFrame:frame])) {
        _playlistHeight = 100;

        // Fetch stuff
        _playlistCoreDataManger = [[PlaylistCoreDataManager alloc] init];
        _objectContext = [_playlistCoreDataManger newContext];
        [self fetchPlaylists];

        // Playlist table view
        _playlistScrollView = [[RBLScrollView alloc] initWithFrame:[self playlistScrollViewFrame]];
        [_playlistScrollView setHasVerticalScroller:YES];
        _playlistTableView = [[RBLTableView alloc] initWithFrame: [[_playlistScrollView contentView] bounds]];
        [_playlistTableView setDelegate:self];
        [_playlistTableView setDataSource:self];
        [_playlistTableView registerForDraggedTypes:[NSArray arrayWithObjects:@"trackFilenames", NSFilenamesPboardType, @"playlistTrackIDs", nil]];
        [_playlistTableView setHeaderView:nil];
        [_playlistTableView setIntercellSpacing:NSMakeSize(0, 0)];
        [_playlistTableView setDoubleAction:@selector(doubleClickReceived:)];
        [_playlistScrollView setDocumentView:_playlistTableView];
        [_playlistScrollView setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];
        NSTableColumn *playlistFirstColumn = [[NSTableColumn alloc] initWithIdentifier:@"main"];
        [_playlistTableView addTableColumn:playlistFirstColumn];
        [playlistFirstColumn setWidth:[_playlistTableView bounds].size.width];

        // Loading up previously selected playlist
        NSURL *lastPlaylistURL = [[NSUserDefaults standardUserDefaults] URLForKey:@"currentlySelectedPlaylistCoreDataURL"];
        // If no playlists, create one and select it
        if([_playlists count] == 0) {
            [self newPlaylist];
            [_playlistTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        }
        else if(lastPlaylistURL) {
            BOOL found = false;
            NSLog(@"url: %@", [lastPlaylistURL absoluteString]);
            for(Playlist *p in _playlists) {
                NSLog(@"url compare: %@", [[[p objectID] URIRepresentation] absoluteString]);
                if([[[p objectID] URIRepresentation] isEqual:lastPlaylistURL] == true) {
                    found = true;
                    [_playlistTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[_playlists indexOfObject:p]] byExtendingSelection:NO];
                    break;
                }
            }
            if(found == false) {
                DDLogWarn(@"Previously selected playlist's Core Data URL cannot be found");
                [_playlistTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
            }
        }
        else {
            // no previous saved, select anything
            [_playlistTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        }

        [_playlistTableView setAllowsEmptySelection:NO];
        [_playlistTableView setEnabled:NO];
        [self addSubview:_playlistScrollView];

        // Track table view
        _trackScrollView = [[RBLScrollView alloc] initWithFrame:[self trackScrollViewFrame]];
        [_trackScrollView setHasVerticalScroller:YES];
        [_trackScrollView setHasHorizontalScroller:YES];
        _trackTableView = [[RBLTableView alloc] initWithFrame: [[_trackScrollView contentView] bounds]];
        [_trackTableView setDelegate:self];
        [_trackTableView setDataSource:self];
        [_trackTableView registerForDraggedTypes:[NSArray arrayWithObjects:@"trackFilenames", NSFilenamesPboardType, @"playlistTrackIDs", nil]];
        [_trackTableView setIntercellSpacing:NSMakeSize(0, 0)];
        [_trackTableView setDoubleAction:@selector(doubleClickReceived:)];
        [_trackTableView setAllowsMultipleSelection:YES];
        [_trackScrollView setDocumentView:_trackTableView];
        [_trackScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

        NSTableColumn *trackPlayingColumn = [[NSTableColumn alloc] initWithIdentifier:@"playing"];
        [_trackTableView addTableColumn:trackPlayingColumn];
        [trackPlayingColumn setHeaderCell:[[PlaylistTrackHeaderCell alloc] initTextCell:@""]];
        [trackPlayingColumn setWidth:13];
        [trackPlayingColumn setMaxWidth:13];
        [trackPlayingColumn setMinWidth:13];

        NSTableColumn *trackTitleColumn = [[NSTableColumn alloc] initWithIdentifier:@"title"];
        [_trackTableView addTableColumn:trackTitleColumn];
        [trackTitleColumn setHeaderCell:[[PlaylistTrackHeaderCell alloc] initTextCell:@"Track"]];
        [trackTitleColumn setWidth:150];
        [trackTitleColumn setMinWidth:50];
        
        NSTableColumn *trackAlbumColumn = [[NSTableColumn alloc] initWithIdentifier:@"album"];
        [_trackTableView addTableColumn:trackAlbumColumn];
        [trackAlbumColumn setHeaderCell:[[PlaylistTrackHeaderCell alloc] initTextCell:@"Album"]];
        [trackAlbumColumn setWidth:150];
        [trackAlbumColumn setMinWidth:50];
        
        NSTableColumn *trackArtistColumn = [[NSTableColumn alloc] initWithIdentifier:@"artist"];
        [_trackTableView addTableColumn:trackArtistColumn];
        [trackArtistColumn setHeaderCell:[[PlaylistTrackHeaderCell alloc] initTextCell:@"Artist"]];
        [trackArtistColumn setWidth:150];
        [trackArtistColumn setMinWidth:50];
        
        NSTableColumn *trackLengthColumn = [[NSTableColumn alloc] initWithIdentifier:@"length"];
        [_trackTableView addTableColumn:trackLengthColumn];
        [trackLengthColumn setHeaderCell:[[PlaylistTrackHeaderCell alloc] initTextCell:@"Length"]];
        [trackLengthColumn setMinWidth:50];
        

        [self addSubview:_trackScrollView];
        [_trackTableView reloadData];
        [_trackTableView setAutosaveName:@"trackTableView"];
        [_trackTableView setAutosaveTableColumns:YES];
        [_trackTableView setUsesAlternatingRowBackgroundColors:YES];
        [_trackTableView setRowHeight:25.0];
        [_trackScrollView setAutohidesScrollers:YES];
        
        // Adding queue
        _addingQueue = dispatch_queue_create(NULL, NULL);
        
        // Playlist table header
        _playlistTableHeader = [[PlaylistTableHeader alloc] initWithFrame:[self playlistTableHeaderFrame]];
        [_playlistTableHeader setWantsLayer:YES];
        [self addSubview:_playlistTableHeader];
        
        // Ensure playing column is always first
        [_trackTableView moveColumn:[_trackTableView columnWithIdentifier:@"playing"] toColumn:0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedAddTrackToCurrentPlaylistNotification:) name:@"addTrackToCurrentPlaylist" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPlaylistSavedNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
        
        [self updateDividerTrackingArea];
    }
    return self;
}

- (void)dealloc
{
    dispatch_release(_addingQueue);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"addTrackToCurrentPlaylist" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
}

- (void)updateDividerTrackingArea
{
    if(_dividerTrackingArea) {
        [self removeTrackingArea:_dividerTrackingArea];
    }
    
    if(_playlistsVisible == YES) { // only have tracking rect if the playlists are visible
        NSRect trackingRect = [self bounds];
        
        trackingRect.origin.y += _playlistHeight;
        trackingRect.size.height = 6.0;
        trackingRect.origin.y -= 3.0;
        
        _dividerTrackingArea = [[NSTrackingArea alloc] initWithRect:trackingRect options:NSTrackingCursorUpdate|NSTrackingActiveInKeyWindow owner:self userInfo:nil];
        [self addTrackingArea:_dividerTrackingArea];
    }
}

-(void)cursorUpdate:(NSEvent *)event
{
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    
    if (_dividerBeingDragged == YES || [self mouse:point inRect:[_dividerTrackingArea rect]]) {
        [[NSCursor resizeUpDownCursor] set];
    } else {
        [super cursorUpdate:event];
    }
}

- (NSView *)hitTest:(NSPoint)aPoint
{
    NSPoint point = [self convertPoint:aPoint fromView:[self superview]]; // convert to our coordinate system
    if ([self mouse:point inRect:[_dividerTrackingArea rect]]) {
        return self; // Capture mouse clicks even though they are on top of other views
    }
    else {
        return [super hitTest:aPoint];
    }
}

-(void)mouseDown:(NSEvent *)event
{
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    
    if ([self mouse:point inRect:[_dividerTrackingArea rect]]) {
        _dividerBeingDragged = YES;
    }
    else {
        [super mouseDown:event];
    }
}

-(void)mouseUp:(NSEvent *)event
{
    if (_dividerBeingDragged) {
        _dividerBeingDragged = NO;
    }
    else {
        [super mouseUp:event];
    }
}


-(void)mouseDragged:(NSEvent *)event
{
    if(_dividerBeingDragged == YES) {
        NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
        
        _playlistHeight = round(point.y);
        if(_playlistHeight < 50)
            _playlistHeight = 50;
        else if (_playlistHeight > [self bounds].size.height - 50)
            _playlistHeight = [self bounds].size.height - 50;
        
        [self resizeSubviewsWithOldSize:[self bounds].size];
    }
}

- (NSRect)playlistScrollViewFrame
{
    NSRect playlistScrollViewFrame = self.bounds;
    playlistScrollViewFrame.size.height = _playlistHeight - 15.0;
    if(_playlistsVisible == NO) {
        playlistScrollViewFrame.origin.y -= _playlistHeight; // keep offscreen for slide in animation
    }
    
    return playlistScrollViewFrame;
}

- (NSRect)trackScrollViewFrame
{
    NSRect trackScrollViewFrame = self.bounds;
    trackScrollViewFrame.size.height += 1;
    if(_playlistsVisible == YES) {
        trackScrollViewFrame.origin.y += _playlistHeight;
        trackScrollViewFrame.size.height -= _playlistHeight;
    }
    return trackScrollViewFrame;
}

- (NSRect)playlistTableHeaderFrame
{
    NSRect barRect = self.bounds;
    barRect.origin.y += _playlistHeight - 15.0;
    barRect.size.height = 15.0;
    if(_playlistsVisible == NO) {
        barRect.origin.y -= _playlistHeight; // keep offscreen for slide in animation
    }
    return barRect;
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldBoundsSize
{
    [super resizeSubviewsWithOldSize:oldBoundsSize];
    [[[_playlistTableView tableColumns] objectAtIndex:0] setWidth:[_playlistTableView bounds].size.width];
    
    [_playlistScrollView setFrame:[self playlistScrollViewFrame]];
    [_trackScrollView setFrame:[self trackScrollViewFrame]];
    [_playlistTableHeader setFrame:[self playlistTableHeaderFrame]];

    [self updateDividerTrackingArea];
}

- (void)setPlaylistVisiblity:(BOOL)visible
{
    _playlistsVisible = visible;
    
    [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setCompletionHandler:^{
         [self resizeSubviewsWithOldSize:[self bounds].size];
    }];
    [[_playlistScrollView animator] setFrame:[self playlistScrollViewFrame]];
    [[_trackScrollView animator] setFrame:[self trackScrollViewFrame]];
    [[_playlistTableHeader animator] setFrame:[self playlistTableHeaderFrame]];
    [NSAnimationContext endGrouping];
    
    [_playlistTableView setEnabled:visible];
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
    [self setPlaylistVisiblity:YES];
    Playlist *newPlaylist = [NSEntityDescription insertNewObjectForEntityForName:@"playlist" inManagedObjectContext:_objectContext];
    [newPlaylist setName:@"New playlist"];
    [newPlaylist save];
    [self fetchPlaylists];
    [_playlistTableView reloadData]; // _currentPlaylist is reset to selection
    [_playlistTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[_playlists indexOfObject:newPlaylist]] byExtendingSelection:NO]; // this changes _currentPlaylist
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
    if([filenames count] == 0) return;
    __weak Playlist *weakP = p;

    dispatch_async(_addingQueue, ^() {
        NSInteger blockIndex = index;
        for(NSString *s in filenames) {
            void (^completion)(void) = ^() {
                if(weakP == _currentPlaylist) // selection could have changed, so no point updating if it has
                    [_trackTableView reloadData];
            };
            
            if([MusicController isSupportedAudioFile:s]) {
                if(index < 0) {
                    [p addTrackWithFilename:s onCompletion:completion];
                }
                else {
                    [p insertTrackWithFilename:s atIndex:blockIndex onCompletion:completion];
                }
            }
            
            blockIndex = blockIndex < 0 ? blockIndex : blockIndex + 1;
        }
    });
}

-(void)receivedPlaylistSavedNotification:(NSNotification *)notification
{
    if([_objectContext belongsToSameStoreAs:[notification object]] == false) return; // only do it for playlists
    if([notification object] == _objectContext) return; // protect from self-loop
    
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
        if([[tableColumn identifier] isEqualToString:@"playing"]) {
            PlaylistTrackPlayingCellView *view = [tableView makeViewWithIdentifier:@"playlistTrackPlayingCellView" owner:self];
            
            if(view == nil) {
                NSRect frame = NSMakeRect(0, 0, 200, 25);
                view = [[PlaylistTrackPlayingCellView alloc] initWithFrame:frame];
                view.identifier = @"playlistTrackPlayingCellView";
            }
            [view setTrack:[_currentPlaylist trackAtIndex:row]];
            return view;
        }
        else {
            PlaylistTrackCellView *view = [tableView makeViewWithIdentifier:@"playlistTrackCellView" owner:self];

            if(view == nil) {
                NSRect frame = NSMakeRect(0, 0, 200, 25);
                view = [[PlaylistTrackCellView alloc] initWithFrame:frame];
                view.identifier = @"playlistTrackCellView";
            }
            
            [view setColumnIdentifier:[tableColumn identifier]]; // this must be done first before setting track
            [view setTrack:[_currentPlaylist trackAtIndex:row]];
            return view;
        }
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
    // Note: reloadData causes this to be called twice. once to change to something else and once to change back again
    if([notification object] == _playlistTableView) {
        Playlist *p = [_playlists objectAtIndex:[_playlistTableView selectedRow]];
        [[NSUserDefaults standardUserDefaults] setURL:[[p objectID] URIRepresentation] forKey:@"currentlySelectedPlaylistCoreDataURL"];
        [self setCurrentPlaylist:p];
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
    else if(action == @selector(revealTrackInFinder:)) {
        return YES;
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

- (BOOL)tableView:(NSTableView *)tableView shouldReorderColumn:(NSInteger)columnIndex toColumn:(NSInteger)newColumnIndex
{
    if(tableView == _trackTableView) {
        if(newColumnIndex == 0) // Prevent something being dragged to playing column position
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else {
        return YES;
    }
}

-(void)tableView:(NSTableView*)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn*)tableColumn
{
    if(tableView == _trackTableView) {
        if ([[tableColumn identifier] isEqualToString:@"playing"])
        {
            // Prevents playing column from being dragged. For some reason returning NO in
            // tableView:shouldReorderColumn:toColumn causes it to get stuck selected
            [tableView setAllowsColumnReordering:NO];
        }
        else
        {
            [tableView setAllowsColumnReordering:YES];
        }
    }
}

-(NSMenu *)tableView:(NSTableView*)tableView menuForTableColumnIndex:(NSInteger)columnIndex rowIndex:(NSInteger)rowIndex
{
    if(tableView == _trackTableView) {
        if(rowIndex != -1 && columnIndex != -1) {
            [tableView selectRowIndexes:[[NSIndexSet alloc] initWithIndex:rowIndex] byExtendingSelection:NO];
            NSMenu *menu = [[NSMenu alloc] initWithTitle:@"menu"];
            
            PlaylistTrack *t = [_currentPlaylist trackAtIndex:rowIndex];
            
            [menu insertItemWithTitle:[NSString stringWithFormat:@"Format: %@", [t menuItemFormatString]] action:NULL keyEquivalent:@"" atIndex:0];
            
            NSMenuItem *revealItem = [menu insertItemWithTitle:@"Reveal in Finder" action:@selector(revealTrackInFinder:) keyEquivalent:@"" atIndex:1];
            [revealItem setTarget:self];
            [revealItem setRepresentedObject:t];
            return menu;
        }
    }

    return nil;
}

-(void)revealTrackInFinder:(id)sender
{
    PlaylistTrack *t = (PlaylistTrack *)[sender representedObject];
    NSArray *urls = [NSArray arrayWithObject:[[NSURL alloc] initFileURLWithPath:[t filename]]];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:urls];
}


@end
