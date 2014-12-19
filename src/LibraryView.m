//
//  LibaryView.m
//  dokibox
//
//  Created by Miles Wu on 05/02/2013.
//
//

#import "LibraryView.h"
#import "LibraryArtist.h"
#import "LibraryAlbum.h"
#import "LibraryTrack.h"
#import "LibraryMonitoredFolder.h"
#import "LibraryViewCell.h"
#import "LibraryViewArtistCell.h"
#import "LibraryViewAlbumCell.h"
#import "LibraryViewTrackCell.h"
#import "LibraryCoreDataManager.h"
#import "LibraryArtist.h"
#import "RBLScrollView.h"
#import "LibraryViewSearchView.h"
#import "TableViewRowData.h"
#import "LibraryViewArtistRowView.h"
#import "LibraryViewAlbumRowView.h"
#import "LibraryViewTrackRowView.h"
#import "NSManagedObjectContext+Helpers.h"
#import "Library.h"
#import "NSView+CGDrawing.h"
#import "LibraryNoTracksView.h"

@implementation LibraryView

- (id)initWithFrame:(CGRect)frame andLibrary:(Library *)library
{
    if((self = [super initWithFrame:frame])) {
        NSRect libraryframe = [self bounds];
        libraryframe.size.height -= 1; // for grey line
        _libraryScrollView = [[RBLScrollView alloc] initWithFrame:libraryframe];
        [_libraryScrollView setHasVerticalScroller:YES];

        _tableView = [[NSTableView alloc] initWithFrame:[[_libraryScrollView contentView] bounds]];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setHeaderView:nil];
        [_tableView setAction:@selector(clickRecieved:)];
        [_tableView setIntercellSpacing:NSMakeSize(0, 0)];
        
        _rowData = [[TableViewRowData alloc] init];
        [_rowData setTableViewDelegate:_tableView];
        [_rowData setInsertAnimation:NSTableViewAnimationSlideDown];
        [_rowData setRemoveAnimation:NSTableViewAnimationSlideUp];

        NSTableColumn *libraryFirstColumn = [[NSTableColumn alloc] initWithIdentifier:@"main"];
        [_tableView addTableColumn:libraryFirstColumn];
        [libraryFirstColumn setWidth:[_libraryScrollView contentSize].width];

        [_libraryScrollView setDocumentView:_tableView];
        [_libraryScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
        _libraryNoTracksView = [[LibraryNoTracksView alloc] initWithFrame:NSMakeRect(libraryframe.origin.x, NSMidY(libraryframe)-40, libraryframe.size.width, 80)];
        [_libraryNoTracksView setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin | NSViewMinYMargin];

        _library = library;
        _objectContext = [[_library coreDataManager] newContext];

        _searchQueue = dispatch_queue_create("com.uguu.dokibox.LibraryView.search", NULL);
        _searchQueueDepth = 0;
        
        _searchMatchedObjects = [[NSMutableSet alloc] init];
        [self runSearch:@""];
        [self updateLibraryVisibility]; // show library table or no-track-stuff as appropriate

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLibrarySavedNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

-(void)dealloc
{
    dispatch_release(_searchQueue);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
}

-(void)updateLibraryVisibility
{
    // If there is no search running, and there is nothing to show -> no tracks in library
    if([_searchString isEqual:@""] && [_rowData count] == 0) {
        if([[self subviews] containsObject:_libraryScrollView]) {
            // If library showing, remove it and add no-tracks stuff
            [_libraryScrollView removeFromSuperview];
            [self addSubview:_libraryNoTracksView];
        }
    }
    else {
        if(![[self subviews] containsObject:_libraryScrollView]) {
            // If no library showing, add it and remove no-track stuff
            [_libraryNoTracksView removeFromSuperview];
            [self addSubview:_libraryScrollView];
        }
    }
}

- (void)drawRect:(NSRect)rect
{
    CGRect b = [self bounds];
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    
    // Background color
    CGContextSetRGBFillColor(ctx, .91, .91, .91, 1.0);
    CGContextFillRect(ctx, b);
    
    CGContextSetStrokeColorWithColor(ctx, [[NSColor colorWithDeviceWhite:TRACK_TABLEVIEW_HEADER_TOP_COLOR alpha:1.0] CGColor]);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, b.origin.x, b.origin.y + b.size.height - 0.5);
    CGContextAddLineToPoint(ctx, b.origin.x + b.size.width, b.origin.y + b.size.height - 0.5);
    CGContextStrokePath(ctx);
}

-(void)receivedLibrarySavedNotificationWithChanges:(NSMutableDictionary *)changes
{
    [_tableView beginUpdates]; // To group the animations
    
    NSMutableArray *objectsToDelete = [[NSMutableArray alloc] initWithArray:[changes objectForKey:NSDeletedObjectsKey]];
    NSMutableArray *objectsToInsert = [[NSMutableArray alloc] initWithArray:[changes objectForKey:NSInsertedObjectsKey]];
    
    // Updated objects
    for(NSManagedObject *m in [changes objectForKey:NSUpdatedObjectsKey]) {
        NSInteger currentIndex = [_rowData indexOfObject:m];
        NSInteger insertIndex = [self insertionIndexFor:m];
        if(insertIndex != currentIndex) {
            // Need to delete and re-add, as the object will move positions
            [objectsToDelete addObject:m];
            [objectsToInsert addObject:m];
        }
        else {
            // No position move, so just need to refresh it
            // Technically albums and artist will never move, because their name (and in the case of albums, the parent artist) never change. Instead if all the tracks change their album/artist name, a new album/artist is created and the old deleted.
            if(currentIndex != NSNotFound) {
                [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:currentIndex] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            }
        }
        DDLogVerbose(@"updating %@ [index: current=%ld insert=%ld]", [m valueForKey:@"name"], currentIndex, insertIndex);
    }

    // Deleted objects
    for(NSManagedObject *m in objectsToDelete) {
        DDLogVerbose(@"deleting %@", [m valueForKey:@"name"]);
        NSUInteger index = [_rowData indexOfObject:m];
        if(index != NSNotFound) {
            [self collapseRow:index];
            [_rowData removeObjectAtIndex:index];
        }
    }

    // Inserted objects
    for(NSManagedObject *m in objectsToInsert) {
        DDLogVerbose(@"inserting %@", [m valueForKey:@"name"]);
        NSInteger insertIndex = [self insertionIndexFor:m];
        if(insertIndex != NSNotFound) {
            [_rowData insertObject:m atIndex:insertIndex];
        }
    }
    
    [_tableView endUpdates];
    [self updateLibraryVisibility];
}

-(NSInteger)insertionIndexFor:(NSManagedObject *)m
{
    NSInteger insertIndex = NSNotFound; // no insertion
    NSString *name = [m valueForKey:@"name"];

    if([m isKindOfClass:[LibraryArtist class]]) {
        insertIndex = [_rowData count];
        if([_rowData count] == 0) { // if list is empty, only one place to go
            insertIndex = 0;
        }
        else {
            for(NSUInteger i = 0; i < [_rowData count]; i++) {
                if([[_rowData objectAtIndex:i] isKindOfClass:[LibraryTrack class]] || [[_rowData objectAtIndex:i] isKindOfClass:[LibraryAlbum class]]) {
                    continue; // skip over tracks and albums
                }
                if([name localizedCaseInsensitiveCompare:[[_rowData objectAtIndex:i] valueForKey:@"name"]] != NSOrderedDescending) {
                    insertIndex = i; // if we are above this item, then we know to put it here
                    break;
                }
            }
        }
    }
    
    if([m isKindOfClass:[LibraryAlbum class]]) {
        LibraryAlbum *a = (LibraryAlbum *)m;
        NSUInteger parent_index = [_rowData indexOfObject:[a artist]];
        
        if(parent_index != NSNotFound && [self isRowExpanded:parent_index]) { // check to see if parent artist is expanded
            insertIndex = [_rowData count];
            for(NSUInteger i = parent_index + 1; i < [_rowData count]; i++) {
                if([[_rowData objectAtIndex:i] isKindOfClass:[LibraryArtist class]]) {
                    insertIndex = i; //reached the end of the expanded block
                    break;
                }
                if([[_rowData objectAtIndex:i] isKindOfClass:[LibraryTrack class]]) {
                    continue; //skip over tracks
                }
                if([name localizedCaseInsensitiveCompare:[[_rowData objectAtIndex:i] valueForKey:@"name"]] != NSOrderedDescending) {
                    insertIndex = i;
                    break;
                }
            }
        }
    }
    
    if([m isKindOfClass:[LibraryTrack class]]) {
        LibraryTrack *t = (LibraryTrack *)m;
        NSUInteger parent_index = [_rowData indexOfObject:[t album]];
        
        if(parent_index != NSNotFound && [self isRowExpanded:parent_index]) { // check to see if parent album is expanded
            insertIndex = [_rowData count];
            for(NSUInteger i = parent_index + 1; i < [_rowData count]; i++) {
                if([[_rowData objectAtIndex:i] isKindOfClass:[LibraryAlbum class]] || [[_rowData objectAtIndex:i] isKindOfClass:[LibraryArtist class]]) {
                    insertIndex = i; //reached the end of the expanded block
                    break;
                }
                if([[m valueForKey:@"trackNumber"] compare:[[_rowData objectAtIndex:i] valueForKey:@"trackNumber"]] != NSOrderedDescending) {
                    insertIndex = i;
                    break;
                }
            }
        }
    }
    
    return insertIndex;
}

-(void)receivedLibrarySavedNotification:(NSNotification *)notification
{
    if([_objectContext belongsToSameStoreAs:[notification object]] == false) return;

    void (^block)() = ^{
        // Merge the changes into the main thread context
        [_objectContext mergeChangesFromContextDidSaveNotification:notification];
        
        // Fetch the main thread version of the CoreData objects in the save notification
        NSMutableDictionary *changes = [NSMutableDictionary dictionary];
        for(id<NSCopying> key in [[notification userInfo] allKeys]) {
            NSMutableArray *arr = [NSMutableArray array];
            for(NSManagedObject *m_otherThread in [[notification userInfo] objectForKey:key]) {
                NSManagedObject *m_mainThread = [_objectContext objectWithID:[m_otherThread objectID]];
                
                if([m_mainThread isKindOfClass:[LibraryMonitoredFolder class]])
                    continue; // No need to include these, as we don't use them in LibraryView

                [arr addObject:m_mainThread];
            }
            [changes setObject:arr forKey:key];
        }
        
        // Update UI in this
        [self receivedLibrarySavedNotificationWithChanges:changes];
    };
    
    if(dispatch_get_current_queue() == dispatch_get_main_queue())
        block();
    else
        dispatch_sync(dispatch_get_main_queue(), block);
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    NSObject *obj = [_rowData objectAtIndex:row];
    if([obj isKindOfClass:[LibraryArtist class]]) {
        return 25.0;
    }
    else if([obj isKindOfClass:[LibraryAlbum class]]) {
        return 50.0;
    }
    else if([obj isKindOfClass:[LibraryTrack class]]) {
        return 20.0;
    }
    else {
        DDLogError(@"Unknown table cell type in LibraryView");
        return 0.0;
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_rowData count];
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    LibraryViewCell *view;
    /*if([indexPath row] == 0)
        cell = reusableTableCellOfClass(tableView, LibraryViewArtistCell);
    else if([indexPath row] == 1)
        cell = reusableTableCellOfClass(tableView, LibraryViewAlbumCell);
    else
        cell = reusableTableCellOfClass(tableView, LibraryViewTrackCell);*/
    NSRect frame = [_tableView frameOfCellAtColumn:[[_tableView tableColumns] indexOfObject:tableColumn] row:row];

    NSObject *obj = [_rowData objectAtIndex:row];
    if([obj isKindOfClass:[LibraryArtist class]]) {
        view = [tableView makeViewWithIdentifier:@"libraryViewArtistCell" owner:self];

        if(view == nil) {
            view = [[LibraryViewArtistCell alloc] initWithFrame:frame];
            view.identifier = @"libraryViewArtistCell";
        }

        [((LibraryViewArtistCell *)view) setArtist:(LibraryArtist *)[_rowData objectAtIndex:row]];
    }
    else if([obj isKindOfClass:[LibraryAlbum class]]) {
        view = [tableView makeViewWithIdentifier:@"libraryViewAlbumCell" owner:self];

        if(view == nil) {
            view = [[LibraryViewAlbumCell alloc] initWithFrame:frame];
            view.identifier = @"libraryViewAlbumCell";
        }

        [((LibraryViewAlbumCell *)view) setAlbum:(LibraryAlbum *)[_rowData objectAtIndex:row]];
    }
    else if([obj isKindOfClass:[LibraryTrack class]]) {
        view = [tableView makeViewWithIdentifier:@"libraryViewTrackCell" owner:self];

        if(view == nil) {
            view = [[LibraryViewTrackCell alloc] initWithFrame:frame];
            view.identifier = @"libraryViewTrackCell";
        }

        [((LibraryViewTrackCell *)view) setTrack:(LibraryTrack *)[_rowData objectAtIndex:row]];
    }
    
    [view setSearchMatchedObjects:_searchMatchedObjects];
    [view setLibraryView:self];

    return view;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    NSObject *obj = [_rowData objectAtIndex:row];
    if([obj isKindOfClass:[LibraryArtist class]]) {
        LibraryViewArtistRowView *view = [tableView makeViewWithIdentifier:@"libraryViewArtistRowView" owner:self];
        
        if(view == nil) {
            NSRect frame = NSMakeRect(0, 0, 0, [self tableView:tableView heightOfRow:row]);
            view = [[LibraryViewArtistRowView alloc] initWithFrame:frame];
            view.identifier = @"libraryViewArtistRowView";
        }
        return view;
    }
    else if([obj isKindOfClass:[LibraryAlbum class]]) {
        LibraryViewAlbumRowView *view = [tableView makeViewWithIdentifier:@"libraryViewAlbumRowView" owner:self];
        
        if(view == nil) {
            NSRect frame = NSMakeRect(0, 0, 0, [self tableView:tableView heightOfRow:row]);
            view = [[LibraryViewAlbumRowView alloc] initWithFrame:frame];
            view.identifier = @"libraryViewAlbumRowView";
        }
        return view;
    }
    else if([obj isKindOfClass:[LibraryTrack class]]) {
        LibraryViewTrackRowView *view = [tableView makeViewWithIdentifier:@"libraryViewTrackRowView" owner:self];
        
        if(view == nil) {
            NSRect frame = NSMakeRect(0, 0, 0, [self tableView:tableView heightOfRow:row]);
            view = [[LibraryViewTrackRowView alloc] initWithFrame:frame];
            view.identifier = @"libraryViewTrackRowView";
        }
        
        // Setting alternating colors
        NSInteger albumPosition;
        for(albumPosition=row; albumPosition >= 0; albumPosition--) {
            if([[_rowData objectAtIndex:albumPosition] isKindOfClass:[LibraryAlbum class]])
                break;
        }
        [((LibraryViewTrackRowView *)view) setIsEvenRow:((row-albumPosition)%2 == 0)];
        
        return view;
    }
    else {
        return nil;
    }
}

-(BOOL)isRowExpanded:(NSUInteger)row
{
    return [self isRowExpanded:row inCellData:_rowData];
}

-(BOOL)isRowExpanded:(NSUInteger)row inCellData:(NSMutableArray*)celldata
{
    if(row == [celldata count] - 1) //last item, so can't be expanded
        return NO;
    
    NSObject *c1 = [celldata objectAtIndex:row];
    NSObject *c2 = [celldata objectAtIndex:row+1];
    if([c1 isKindOfClass:[LibraryArtist class]]) {
        if([c2 isKindOfClass:[LibraryAlbum class]])
            return YES;
        else
            return NO;
    }
    else if([c1 isKindOfClass:[LibraryAlbum class]]) {
        if([c2 isKindOfClass:[LibraryTrack class]])
            return YES;
        else
            return NO;
    }
    else //Tracks can't be expanded
        return NO;
}

- (void)addButtonPressed:(id)sender
{
    NSMutableArray *clickedObjects = [[NSMutableArray alloc] init];
    
    if([sender isKindOfClass:[LibraryViewArtistCell class]]) {
        LibraryArtist *a = [((LibraryViewArtistCell *)sender) artist];
        [clickedObjects addObject:a];
    }
    else if([sender isKindOfClass:[LibraryViewAlbumCell class]]) {
        LibraryAlbum *a = [((LibraryViewAlbumCell *)sender) album];
        [clickedObjects addObject:a];
    }
    else if([sender isKindOfClass:[LibraryViewTrackCell class]]) {
        LibraryTrack *t = [((LibraryViewTrackCell *)sender) track];
        [clickedObjects addObject:t];
    }
    else {
        DDLogError(@"Unrecognized sender in addButtonPressed of LibraryView");
        return;
    }

    [self expandRow:0 recursive:YES onCellData:clickedObjects andMatchedObjects:_searchMatchedObjects];
        
    NSMutableArray *tracks = [[NSMutableArray alloc] init];
    for(id i in clickedObjects) {
        if([i isKindOfClass:[LibraryTrack class]]) {
            [tracks addObject:i];
        }
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"addTrackToCurrentPlaylist" object:tracks];
}


- (void)clickRecieved:(id)sender
{
    NSTableView *tv = (NSTableView *)sender;
    NSUInteger row = [tv clickedRow];
    if(row == -1) return;

    [_tableView beginUpdates];
    if([self isRowExpanded:row]) {
        [self collapseRow:row];
    }
    else {
        [self expandRow:row];
    }
    [_tableView endUpdates];
}

-(void)collapseRow:(NSUInteger)row
{
    if(![self isRowExpanded:row]) return;

    NSObject *obj = [_rowData objectAtIndex:row];

    NSUInteger size = 0;
    for(NSUInteger i = row + 1; i < [_rowData count];i++) {
        if([[_rowData objectAtIndex:i] isKindOfClass:[LibraryArtist class]]) break;
        if([obj isKindOfClass:[LibraryAlbum class]])
            if([[_rowData objectAtIndex:i] isKindOfClass:[LibraryAlbum class]]) break;
        size++;
    }

    [_rowData removeObjectsInRange:NSMakeRange(row + 1, size)];
}

-(void)expandRow:(NSUInteger)row
{
    [self expandRow:row recursive:NO];
}
-(void)expandRow:(NSUInteger)row recursive:(BOOL)recursive;
{
    [self expandRow:row recursive:recursive onCellData:_rowData andMatchedObjects:_searchMatchedObjects];
}

-(void)expandRow:(NSUInteger)row recursive:(BOOL)recursive onCellData:(NSMutableArray*)celldata andMatchedObjects:(NSMutableSet*)matchedObjects
{
    NSObject *obj = [celldata objectAtIndex:row];

    if([obj isKindOfClass:[LibraryArtist class]]) {
        LibraryArtist *artist = (LibraryArtist *)obj;
        NSUInteger i = row + 1;

        if(![self isRowExpanded:row inCellData:celldata]) {
            NSSortDescriptor *sortd = [[NSSortDescriptor alloc]
                                        initWithKey:@"name"
                                        ascending:YES
                                        selector:@selector(localizedCaseInsensitiveCompare:)];
            NSSet *albums;
            if([matchedObjects count] == 0) { // not doing search atm
                albums = [artist albums];
            }
            else {
                albums = [artist albumsFromSet:matchedObjects];
            }

            for(LibraryAlbum *album in [albums sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortd, nil]]) {
                [celldata insertObject:album atIndex:i];
                i++;
            }
        }
        if(recursive) {
            for(i = row + 1; i<[celldata count]; i++) {
                NSObject *obj2 = [celldata objectAtIndex:i];
                if([obj2 isKindOfClass:[LibraryArtist class]])
                    break;
                else if([obj2 isKindOfClass:[LibraryAlbum class]])
                    [self expandRow:i recursive:NO onCellData:celldata andMatchedObjects:matchedObjects];
            }
        }
    }
    else if([obj isKindOfClass:[LibraryAlbum class]]) {
        if([self isRowExpanded:row inCellData:celldata]) return;

        LibraryAlbum *album = (LibraryAlbum *)obj;
        NSUInteger i = row + 1;

        // this needs to be changed to tracknumber
        NSSortDescriptor *sortd = [[NSSortDescriptor alloc]
                                   initWithKey:@"trackNumber"
                                   ascending:YES
                                   selector:@selector(compare:)];

        NSSet *tracks;
        if([matchedObjects count] == 0) { // not doing search atm
            tracks = [album tracks];
        }
        else {
            tracks = [album tracksFromSet:matchedObjects];
        }

        for(LibraryTrack *track in [tracks sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortd, nil]]) {
            [celldata insertObject:track atIndex:i];
            i++;
        }
    }
}

-(BOOL)searchVisible
{
    return _searchVisible;
}

-(void)setSearchVisible:(BOOL)searchVisible
{
    _searchVisible = searchVisible;
    
    if(_searchVisible == YES) { // show
        if(_librarySearchView) {
            [_librarySearchView setFocusInSearchField];
            return;
        }
        
        CGFloat height = 26;
        
        NSRect searchframe = [self bounds];
        searchframe.size.height = height;
        searchframe.origin.y -= height;
        _librarySearchView = [[LibraryViewSearchView alloc] initWithFrame:searchframe];
        [_librarySearchView setLibraryView:self];
        [_librarySearchView setAutoresizingMask:NSViewWidthSizable];
        [self addSubview:_librarySearchView];
        [_librarySearchView setFocusInSearchField];
        
        searchframe.origin.y += height;
        NSRect libraryframe = [self bounds];
        libraryframe.origin.y += height;
        libraryframe.size.height -= height;
        libraryframe.size.height -= 1; // for grey line
        
        [NSAnimationContext beginGrouping];
        [[_librarySearchView animator] setFrame:searchframe];
        [[_libraryScrollView animator] setFrame:libraryframe];
        [NSAnimationContext endGrouping];
    }
    else { // hide
        if(_librarySearchView == nil) {
            DDLogVerbose(@"Library search view already hidden");
            return;
        }
        
        [_librarySearchView resetSearch];
        
        NSRect libraryframe = [self bounds];
        libraryframe.size.height -= 1; // for grey line
        NSRect searchframe = [_librarySearchView frame];
        searchframe.origin.y -= searchframe.size.height;
        
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [_librarySearchView removeFromSuperview];
            _librarySearchView = nil;
        }];
        [[_libraryScrollView animator] setFrame:libraryframe];
        [[_librarySearchView animator] setFrame:searchframe];
        [NSAnimationContext endGrouping];
    }
}

-(void)runSearch:(NSString *)text
{
    // Run search in background thread so not to lock up UI
    _searchQueueDepth++;
    dispatch_async(_searchQueue, ^{
        if (_searchQueueDepth > 1) { // This indicates it's not the latest required search so we skip it.
            _searchQueueDepth--;
            return;
        }
        
        NSManagedObjectContext *context = [[_library coreDataManager] newContext];
        NSMutableArray *newCellData = [[NSMutableArray alloc] init];
        NSMutableSet *newSearchMatchedObjects = [[NSMutableSet alloc] init];
        
        NSMutableArray *timingArray = [[NSMutableArray alloc] init];
        NSMutableArray *timingArrayNames = [[NSMutableArray alloc] init];
        [timingArray addObject:[NSDate date]];
        [timingArrayNames addObject:@"initial"];
        NSError *error;
        
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                    initWithKey:@"name"
                                    ascending:YES
                                    selector:@selector(localizedCaseInsensitiveCompare:)];
        
        if([text isEqualToString:@""]) { // empty search string
            NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"artist"];
            [fr setSortDescriptors:[NSArray arrayWithObjects:sorter, nil]];
            
            NSArray *results = [context executeFetchRequest:fr error:&error];
            [newCellData addObjectsFromArray:results];
        }
        else { // search to do
            /*NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"artist"];
             [fr setSortDescriptors:[NSArray arrayWithObjects:sorter, nil]];
             
             NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name contains[cd] %@) OR (ANY albums.name contains[cd] %@) OR (SUBQUERY(albums, $a, SUBQUERY($a.tracks, $t, $t.name contains[cd] %@).@count !=0).@count != 0)", text, text, text];
             [fr setPredicate:predicate];
             
             NSArray *results = [_objectContext executeFetchRequest:fr error:&error];
             [_rowData addObjectsFromArray:results];*/
            // Left in for refernece
            // The above method is only faster for single letter queries etc. (please see commit comment for tests)
            
            NSFetchRequest *fetchReqArtist = [NSFetchRequest fetchRequestWithEntityName:@"artist"];
            NSFetchRequest *fetchReqAlbum = [NSFetchRequest fetchRequestWithEntityName:@"album"];
            NSFetchRequest *fetchReqTrack = [NSFetchRequest fetchRequestWithEntityName:@"track"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", text];
            NSPredicate *predicate_track = [NSPredicate predicateWithFormat:@"name contains[cd] %@ or trackArtistName contains[cd] %@", text, text];
            [fetchReqArtist setPredicate:predicate];
            [fetchReqAlbum setPredicate:predicate];
            [fetchReqTrack setPredicate:predicate_track];
            
            NSMutableSet *fetchedArtists = [[NSMutableSet alloc] init];
            
            [fetchReqAlbum setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"artist", nil]];
            [fetchReqTrack setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"album", @"album.artist", nil]];
            
            NSArray *resultsArtist = [context executeFetchRequest:fetchReqArtist error:&error];
            NSArray *resultsAlbum = [context executeFetchRequest:fetchReqAlbum error:&error];
            NSArray *resultsTrack = [context executeFetchRequest:fetchReqTrack error:&error];
            [timingArray addObject:[NSDate date]];
            [timingArrayNames addObject:@"fetch"];

            [newSearchMatchedObjects addObjectsFromArray:resultsArtist];
            [newSearchMatchedObjects addObjectsFromArray:resultsAlbum];
            [newSearchMatchedObjects addObjectsFromArray:resultsTrack];
            [timingArray addObject:[NSDate date]];
            [timingArrayNames addObject:@"collect"];

            [fetchedArtists addObjectsFromArray:resultsArtist];
            for (LibraryAlbum *a in resultsAlbum)
                [fetchedArtists addObject:[a artist]];
            for (LibraryTrack *t in resultsTrack)
                [fetchedArtists addObject:[[t album] artist]];
            [timingArray addObject:[NSDate date]];
            [timingArrayNames addObject:@"uniq"];

            [newCellData addObjectsFromArray:[fetchedArtists sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sorter, nil]]];
            [timingArray addObject:[NSDate date]];
            [timingArrayNames addObject:@"add"];

            NSUInteger i;
            for(i=0; i<[newCellData count]; i++) {
                if([newSearchMatchedObjects member:[newCellData objectAtIndex:i]]) continue;
                
                [self expandRow:i recursive:NO onCellData:newCellData andMatchedObjects:newSearchMatchedObjects];
            }
            [timingArray addObject:[NSDate date]];
            [timingArrayNames addObject:@"expand"];
        }
        
        DDLogVerbose(@"Runining search for %@", text);
        DDLogVerbose(@"Fetching %lu cells took %f sec", [newCellData count], [[NSDate date] timeIntervalSinceDate:[timingArray objectAtIndex:0]]);
        
        // Timing array unpack
        if([timingArray count] > 1) {
            NSMutableArray *timingString = [[NSMutableArray alloc] init];
            for(int i=1; i < [timingArray count]; i++) {
                NSString *s = [[NSString alloc] initWithFormat:@"%@=%f", [timingArrayNames objectAtIndex:i], [[timingArray objectAtIndex:i] timeIntervalSinceDate:[timingArray objectAtIndex:i-1]]];
                [timingString addObject:s];
            }
            DDLogVerbose(@"%@", [timingString componentsJoinedByString:@", "]);
        }
        
        NSMutableArray *newCellDataIDs = [[NSMutableArray alloc] init];
        NSMutableArray *newSearchMatchedObjectIDs = [[NSMutableArray alloc] init];
        for(NSManagedObject *i in newCellData)
            [newCellDataIDs addObject:[i objectID]];
        for(NSManagedObject *i in newSearchMatchedObjects)
            [newSearchMatchedObjectIDs addObject:[i objectID]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDate *d3 = [NSDate date];
            [_rowData startBulkUpdate];
            [_rowData removeAllObjects];
            [_searchMatchedObjects removeAllObjects];
            _searchString = text;

            for(NSManagedObjectID *i in newCellDataIDs)
                [_rowData addObject:[_objectContext objectWithID:i]];
            for(NSManagedObjectID *i in newSearchMatchedObjectIDs)
                [_searchMatchedObjects addObject:[_objectContext objectWithID:i]];
            [_rowData endBulkUpdate];
            
            [self updateLibraryVisibility];
            
            DDLogVerbose(@"Back on main thread took %f sec", -[d3 timeIntervalSinceNow]);
        });
        
        _searchQueueDepth--;
    });
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
    NSMutableArray *selectedObjects = [NSMutableArray arrayWithArray:[_rowData objectsAtIndexes:rowIndexes]];
    
    for(int i=0; i<[selectedObjects count]; i++)
        [self expandRow:i recursive:YES onCellData:selectedObjects andMatchedObjects:_searchMatchedObjects];
    
    NSMutableArray *trackFilenames = [[NSMutableArray alloc] init];
    for(id i in selectedObjects) {
        if([i isKindOfClass:[LibraryTrack class]]) {
            [trackFilenames addObject:[[i objectID] URIRepresentation]];
        }
    }

    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:trackFilenames];
    [pboard declareTypes:[NSArray arrayWithObject:@"libraryTrackIDs"] owner:self];
    [pboard setData:archivedData forType:@"libraryTrackIDs"];
    return YES;
}

@end
