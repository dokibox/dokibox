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
#import "LibraryFolder.h"
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

@implementation LibraryView

- (id)initWithFrame:(CGRect)frame andLibrary:(Library *)library
{
    if((self = [super initWithFrame:frame])) {
        _libraryScrollView = [[RBLScrollView alloc] initWithFrame:[self bounds]];
        [_libraryScrollView setHasVerticalScroller:YES];

        _tableView = [[RBLTableView alloc] initWithFrame:[[_libraryScrollView contentView] bounds]];
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
        [self addSubview:_libraryScrollView];

        _library = library;
        _objectContext = [[_library coreDataManager] newContext];

        _searchQueue = dispatch_queue_create("com.uguu.dokibox.LibraryView.search", NULL);
        _searchQueueDepth = 0;
        
        _searchMatchedObjects = [[NSMutableSet alloc] init];
        [self runSearch:@""];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLibrarySavedNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

-(void)receivedLibrarySavedNotificationWithChanges:(NSMutableDictionary *)changes
{
    for(NSMutableDictionary *dict in [changes objectForKey:NSDeletedObjectsKey]) {
        NSManagedObject *m = [_objectContext objectWithID:[dict objectForKey:@"objectID"]];
        NSLog(@"deleting %@", [m valueForKey:@"name"]);
        NSUInteger index = [_rowData indexOfObject:m];
        if(index != NSNotFound) {
            [self collapseRow:index];
            [_rowData removeObjectAtIndex:index];
        }
    }

    for(NSMutableDictionary *dict in [changes objectForKey:NSInsertedObjectsKey]) {
        NSManagedObject *m = [_objectContext objectWithID:[dict objectForKey:@"objectID"]];
        
        if([m isKindOfClass:[LibraryFolder class]])
            continue;
        
        NSString *name = [m valueForKey:@"name"];
        NSLog(@"inserting %@", name);

        if([m isKindOfClass:[LibraryArtist class]]) {
            NSUInteger insertIndex = [_rowData count];
            if([_rowData count] == 0) { // if list is empty, only one place to go
                insertIndex = 0;
            }
            else {
                for(NSUInteger i = 0; i < [_rowData count]; i++) {
                    if([[_rowData objectAtIndex:i] isKindOfClass:[LibraryTrack class]] || [[_rowData objectAtIndex:i] isKindOfClass:[LibraryAlbum class]]) {
                        continue; // skip over tracks and albums
                    }
                    if([name localizedCaseInsensitiveCompare:[[_rowData objectAtIndex:i] valueForKey:@"name"]] == NSOrderedAscending) {
                        insertIndex = i; // if we are above this item, then we know to put it here
                        break;
                    }
                }
            }
            [_rowData insertObject:m atIndex:insertIndex];
        }

        if([m isKindOfClass:[LibraryAlbum class]]) {
            LibraryAlbum *a = (LibraryAlbum *)m;
            NSUInteger parent_index = [_rowData indexOfObject:[a artist]];

            if(parent_index != NSNotFound && [self isRowExpanded:parent_index]) { // check to see if parent artist is expanded
                NSUInteger insertIndex = [_rowData count];
                for(NSUInteger i = parent_index + 1; i < [_rowData count]; i++) {
                    if([[_rowData objectAtIndex:i] isKindOfClass:[LibraryArtist class]]) {
                        insertIndex = i; //reached the end of the expanded block
                        break;
                    }
                    if([[_rowData objectAtIndex:i] isKindOfClass:[LibraryTrack class]]) {
                        continue; //skip over tracks
                    }
                    if([name localizedCaseInsensitiveCompare:[[_rowData objectAtIndex:i] valueForKey:@"name"]] == NSOrderedAscending) {
                        insertIndex = i;
                        break;
                    }
                }
                [_rowData insertObject:m atIndex:insertIndex];
            }
        }
        if([m isKindOfClass:[LibraryTrack class]]) {
            LibraryTrack *t = (LibraryTrack *)m;
            NSUInteger parent_index = [_rowData indexOfObject:[t album]];

            if(parent_index != NSNotFound && [self isRowExpanded:parent_index]) { // check to see if parent album is expanded
                NSUInteger insertIndex = [_rowData count];
                for(NSUInteger i = parent_index + 1; i < [_rowData count]; i++) {
                    if([[_rowData objectAtIndex:i] isKindOfClass:[LibraryAlbum class]] || [[_rowData objectAtIndex:i] isKindOfClass:[LibraryArtist class]]) {
                        insertIndex = i; //reached the end of the expanded block
                        break;
                    }
                    if([[m valueForKey:@"trackNumber"] compare:[[_rowData objectAtIndex:i] valueForKey:@"trackNumber"]] == NSOrderedAscending) {
                        insertIndex = i;
                        break;
                    }
                }
                [_rowData insertObject:m atIndex:insertIndex];
            }
        }
    }
}

-(void)receivedLibrarySavedNotification:(NSNotification *)notification
{
    if([_objectContext belongsToSameStoreAs:[notification object]] == false) return;

    NSMutableDictionary *changes = [NSMutableDictionary dictionary];
    NSArray *keys = [[notification userInfo] allKeys];

    for(id<NSCopying> key in keys) {
        NSMutableArray *arr = [NSMutableArray array];
        for(NSManagedObject *m in [[notification userInfo] objectForKey:key]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:[m class] forKey:@"class"];
            [dict setObject:[m objectID] forKey:@"objectID"];
            [arr addObject:dict];
        }
        [changes setObject:arr forKey:key];
    }

    void (^block)() = ^{
        [_objectContext mergeChangesFromContextDidSaveNotification:notification];
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

    NSObject *obj = [_rowData objectAtIndex:row];
    if([obj isKindOfClass:[LibraryArtist class]]) {
        view = [tableView makeViewWithIdentifier:@"libraryViewArtistCell" owner:self];

        if(view == nil) {
            NSRect frame = NSMakeRect(0, 0, 200, [self tableView:tableView heightOfRow:row]);
            view = [[LibraryViewArtistCell alloc] initWithFrame:frame];
            view.identifier = @"libraryViewArtistCell";
        }

        [((LibraryViewArtistCell *)view) setArtist:(LibraryArtist *)[_rowData objectAtIndex:row]];
    }
    else if([obj isKindOfClass:[LibraryAlbum class]]) {
        view = [tableView makeViewWithIdentifier:@"libraryViewAlbumCell" owner:self];

        if(view == nil) {
            NSRect frame = NSMakeRect(0, 0, 200, [self tableView:tableView heightOfRow:row]);
            view = [[LibraryViewAlbumCell alloc] initWithFrame:frame];
            view.identifier = @"libraryViewAlbumCell";
        }

        [((LibraryViewAlbumCell *)view) setAlbum:(LibraryAlbum *)[_rowData objectAtIndex:row]];
    }
    else if([obj isKindOfClass:[LibraryTrack class]]) {
        view = [tableView makeViewWithIdentifier:@"libraryViewTrackCell" owner:self];

        if(view == nil) {
            NSRect frame = NSMakeRect(0, 0, 200, [self tableView:tableView heightOfRow:row]);
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
        
    NSMutableArray *trackFilenames = [[NSMutableArray alloc] init];
    for(id i in clickedObjects) {
        if([i isKindOfClass:[LibraryTrack class]]) {
            LibraryTrack *t = (LibraryTrack*)i;
            [trackFilenames addObject:[t filename]];
        }
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"addTrackToCurrentPlaylist" object:trackFilenames];
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

-(void)showSearch
{
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
    [self addSubview:_librarySearchView];
    [_librarySearchView setFocusInSearchField];

    searchframe.origin.y += height;
    NSRect libraryframe = [self bounds];
    libraryframe.origin.y += height;
    libraryframe.size.height -= height;

    [NSAnimationContext beginGrouping];
    [[_librarySearchView animator] setFrame:searchframe];
    [[_libraryScrollView animator] setFrame:libraryframe];
    [NSAnimationContext endGrouping];
}

-(void)hideSearch
{
    if(_librarySearchView == nil) {
        DDLogVerbose(@"Library search view already hidden");
        return;
    }

    NSRect libraryframe = [self bounds];
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
        
        NSDate *d1 = [NSDate date];
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
            [fetchReqArtist setPredicate:predicate];
            [fetchReqAlbum setPredicate:predicate];
            [fetchReqTrack setPredicate:predicate];
            
            NSMutableSet *fetchedArtists = [[NSMutableSet alloc] init];
            
            [fetchReqAlbum setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"artist", nil]];
            [fetchReqTrack setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"album", @"album.artist", nil]];
            
            NSArray *resultsArtist = [context executeFetchRequest:fetchReqArtist error:&error];
            NSArray *resultsAlbum = [context executeFetchRequest:fetchReqAlbum error:&error];
            NSArray *resultsTrack = [context executeFetchRequest:fetchReqTrack error:&error];
            
            [newSearchMatchedObjects addObjectsFromArray:resultsArtist];
            [newSearchMatchedObjects addObjectsFromArray:resultsAlbum];
            [newSearchMatchedObjects addObjectsFromArray:resultsTrack];
            
            [fetchedArtists addObjectsFromArray:resultsArtist];
            for (LibraryAlbum *a in resultsAlbum)
                [fetchedArtists addObject:[a artist]];
            for (LibraryTrack *t in resultsTrack)
                [fetchedArtists addObject:[[t album] artist]];

            [newCellData addObjectsFromArray:[fetchedArtists sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sorter, nil]]];
            
            NSUInteger i;
            for(i=0; i<[newCellData count]; i++) {
                if([newSearchMatchedObjects member:[newCellData objectAtIndex:i]]) continue;
                
                [self expandRow:i recursive:NO onCellData:newCellData andMatchedObjects:newSearchMatchedObjects];
            }
        }
                
        NSDate *d2 = [NSDate date];
        DDLogVerbose(@"Runining search for %@", text);
        DDLogVerbose(@"Fetching %lu cells took %f sec", [newCellData count], [d2 timeIntervalSinceDate:d1]);
        
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

            for(NSManagedObjectID *i in newCellDataIDs)
                [_rowData addObject:[_objectContext objectWithID:i]];
            for(NSManagedObjectID *i in newSearchMatchedObjectIDs)
                [_searchMatchedObjects addObject:[_objectContext objectWithID:i]];
            [_rowData endBulkUpdate];
            
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
            LibraryTrack *t = (LibraryTrack*)i;
            [trackFilenames addObject:[t filename]];
        }
    }

    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:trackFilenames];
    [pboard declareTypes:[NSArray arrayWithObject:@"trackFilenames"] owner:self];
    [pboard setData:archivedData forType:@"trackFilenames"];
    return YES;
}

@end
