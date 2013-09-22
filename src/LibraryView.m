//
//  LibaryView.m
//  dokibox
//
//  Created by Miles Wu on 05/02/2013.
//
//

#import "LibraryView.h"
#import "LibraryViewArtistCell.h"
#import "LibraryViewAlbumCell.h"
#import "LibraryViewTrackCell.h"
#import "LibraryCoreDataManager.h"
#import "LibraryArtist.h"
#import "RBLScrollView.h"
#import "LibraryViewSearchView.h"

@implementation LibraryView

- (id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame])) {
        _libraryScrollView = [[RBLScrollView alloc] initWithFrame:[self bounds]];
        [_libraryScrollView setHasVerticalScroller:YES];

        _tableView = [[RBLTableView alloc] initWithFrame:[[_libraryScrollView contentView] bounds]];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setHeaderView:nil];
        [_tableView setAction:@selector(clickRecieved:)];
        [_tableView setDoubleAction:@selector(doubleClickReceived:)];
        [_tableView setIntercellSpacing:NSMakeSize(0, 0)];

        NSTableColumn *libraryFirstColumn = [[NSTableColumn alloc] initWithIdentifier:@"main"];
        [_tableView addTableColumn:libraryFirstColumn];
        [libraryFirstColumn setWidth:[_libraryScrollView contentSize].width];

        [_libraryScrollView setDocumentView:_tableView];
        [_libraryScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self addSubview:_libraryScrollView];

        _objectContext = [LibraryCoreDataManager newContext];

        _searchQueue = dispatch_queue_create("com.uguu.dokibox.LibraryView.search", NULL);
        _searchQueueDepth = 0;
        
        _celldata = [[NSMutableArray alloc] init];
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
        NSUInteger index = [_celldata indexOfObject:m];
        if(index != NSNotFound) {
            [self collapseRow:index];
            [_celldata removeObjectAtIndex:index];
        }
    }

    for(NSMutableDictionary *dict in [changes objectForKey:NSInsertedObjectsKey]) {
        NSManagedObject *m = [_objectContext objectWithID:[dict objectForKey:@"objectID"]];
        NSString *name = [m valueForKey:@"name"];
        NSLog(@"inserting %@", name);

        if([m isKindOfClass:[LibraryArtist class]]) {
            NSUInteger insertIndex = [_celldata count];
            if([_celldata count] == 0) { // if list is empty, only one place to go
                insertIndex = 0;
            }
            else {
                for(NSUInteger i = 0; i < [_celldata count]; i++) {
                    if([[_celldata objectAtIndex:i] isKindOfClass:[LibraryTrack class]] || [[_celldata objectAtIndex:i] isKindOfClass:[LibraryAlbum class]]) {
                        continue; // skip over tracks and albums
                    }
                    if([name localizedCaseInsensitiveCompare:[[_celldata objectAtIndex:i] valueForKey:@"name"]] == NSOrderedAscending) {
                        insertIndex = i; // if we are above this item, then we know to put it here
                        break;
                    }
                }
            }
            [_celldata insertObject:m atIndex:insertIndex];
        }

        if([m isKindOfClass:[LibraryAlbum class]]) {
            LibraryAlbum *a = (LibraryAlbum *)m;
            NSUInteger parent_index = [_celldata indexOfObject:[a artist]];

            if(parent_index != NSNotFound && [self isRowExpanded:parent_index]) { // check to see if parent artist is expanded
                NSUInteger insertIndex = [_celldata count];
                for(NSUInteger i = parent_index + 1; i < [_celldata count]; i++) {
                    if([[_celldata objectAtIndex:i] isKindOfClass:[LibraryArtist class]]) {
                        insertIndex = i; //reached the end of the expanded block
                        break;
                    }
                    if([[_celldata objectAtIndex:i] isKindOfClass:[LibraryTrack class]]) {
                        continue; //skip over tracks
                    }
                    if([name localizedCaseInsensitiveCompare:[[_celldata objectAtIndex:i] valueForKey:@"name"]] == NSOrderedAscending) {
                        insertIndex = i;
                        break;
                    }
                }
                [_celldata insertObject:m atIndex:insertIndex];
            }
        }
        if([m isKindOfClass:[LibraryTrack class]]) {
            LibraryTrack *t = (LibraryTrack *)m;
            NSUInteger parent_index = [_celldata indexOfObject:[t album]];

            if(parent_index != NSNotFound && [self isRowExpanded:parent_index]) { // check to see if parent album is expanded
                NSUInteger insertIndex = [_celldata count];
                for(NSUInteger i = parent_index + 1; i < [_celldata count]; i++) {
                    if([[_celldata objectAtIndex:i] isKindOfClass:[LibraryAlbum class]] || [[_celldata objectAtIndex:i] isKindOfClass:[LibraryArtist class]]) {
                        insertIndex = i; //reached the end of the expanded block
                        break;
                    }
                    if([[m valueForKey:@"trackNumber"] compare:[[_celldata objectAtIndex:i] valueForKey:@"trackNumber"]] == NSOrderedAscending) {
                        insertIndex = i;
                        break;
                    }
                }
                [_celldata insertObject:m atIndex:insertIndex];
            }
        }
    }

    [_tableView reloadData];
}

-(void)receivedLibrarySavedNotification:(NSNotification *)notification
{
    if([LibraryCoreDataManager contextBelongs:[notification object]] == false) return;

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

    dispatch_sync(dispatch_get_main_queue(), ^{
        [_objectContext mergeChangesFromContextDidSaveNotification:notification];
        [self receivedLibrarySavedNotificationWithChanges:changes];
    });
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    NSObject *obj = [_celldata objectAtIndex:row];
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
    return [_celldata count];

}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    NSView *view;
    /*if([indexPath row] == 0)
        cell = reusableTableCellOfClass(tableView, LibraryViewArtistCell);
    else if([indexPath row] == 1)
        cell = reusableTableCellOfClass(tableView, LibraryViewAlbumCell);
    else
        cell = reusableTableCellOfClass(tableView, LibraryViewTrackCell);*/

    NSObject *obj = [_celldata objectAtIndex:row];
    if([obj isKindOfClass:[LibraryArtist class]]) {
        view = [tableView makeViewWithIdentifier:@"libraryViewArtistCell" owner:self];

        if(view == nil) {
            NSRect frame = NSMakeRect(0, 0, 200, 25);
            view = [[LibraryViewArtistCell alloc] initWithFrame:frame];
            view.identifier = @"libraryViewArtistCell";
        }

        [((LibraryViewArtistCell *)view) setArtist:(LibraryArtist *)[_celldata objectAtIndex:row]];
        [((LibraryViewArtistCell *)view) setSearchMatchedObjects:_searchMatchedObjects];
    }
    else if([obj isKindOfClass:[LibraryAlbum class]]) {
        view = [tableView makeViewWithIdentifier:@"libraryViewAlbumCell" owner:self];

        if(view == nil) {
            NSRect frame = NSMakeRect(0, 0, 200, 25);
            view = [[LibraryViewAlbumCell alloc] initWithFrame:frame];
            view.identifier = @"libraryViewAlbumCell";
        }

        [((LibraryViewAlbumCell *)view) setAlbum:(LibraryAlbum *)[_celldata objectAtIndex:row]];
        [((LibraryViewAlbumCell *)view) setSearchMatchedObjects:_searchMatchedObjects];
    }
    else if([obj isKindOfClass:[LibraryTrack class]]) {
        view = [tableView makeViewWithIdentifier:@"libraryViewTrackCell" owner:self];

        if(view == nil) {
            NSRect frame = NSMakeRect(0, 0, 200, 25);
            view = [[LibraryViewTrackCell alloc] initWithFrame:frame];
            view.identifier = @"libraryViewTrackCell";
        }

        [((LibraryViewTrackCell *)view) setTrack:(LibraryTrack *)[_celldata objectAtIndex:row]];

        NSInteger albumPosition;
        for(albumPosition=row; albumPosition >= 0; albumPosition--) {
            if([[_celldata objectAtIndex:albumPosition] isKindOfClass:[LibraryAlbum class]])
                break;
        }
        [((LibraryViewTrackCell *)view) setIsEvenRow:((row-albumPosition)%2 == 0)];
    }

    return view;
}

-(BOOL)isRowExpanded:(NSUInteger)row
{
    if(row == [_celldata count] - 1) //last item, so can't be expanded
        return NO;

    NSObject *c1 = [_celldata objectAtIndex:row];
    NSObject *c2 = [_celldata objectAtIndex:row+1];
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

- (void)doubleClickReceived:(id)sender
{
    NSTableView *tv = (NSTableView *)sender;
    NSUInteger row = [tv clickedRow];
    if(row == -1) return;

    [self expandRow:row recursive:YES];

    NSObject *obj = [_celldata objectAtIndex:row];
    NSMutableArray *tracks = [[NSMutableArray alloc] init];
    if([obj isKindOfClass:[LibraryTrack class]]) { // if its a track, only one
        [tracks addObject:[((LibraryTrack *)obj) filename]];
    }
    else {
        for(NSUInteger i = row + 1; i<[_celldata count]; i++) {
            NSObject *obj2 = [_celldata objectAtIndex:i];
            if([obj isKindOfClass:[LibraryAlbum class]] && ([obj2 isKindOfClass:[LibraryAlbum class]] || [obj2 isKindOfClass:[LibraryAlbum class]]))
                break;
            if([obj isKindOfClass:[LibraryArtist class]] && [obj2 isKindOfClass:[LibraryArtist class]])
                break;

            if([obj2 isKindOfClass:[LibraryTrack class]])
                [tracks addObject:[((LibraryTrack *)obj2) filename]];
        }
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"addTrackToCurrentPlaylist" object:tracks];

    [tv reloadData];
}


- (void)clickRecieved:(id)sender
{
    NSTableView *tv = (NSTableView *)sender;
    NSUInteger row = [tv clickedRow];
    if(row == -1) return;

    if([self isRowExpanded:row]) {
        [self collapseRow:row];
    }
    else {
        [self expandRow:row];
    }

    [tv reloadData];
}

-(void)collapseRow:(NSUInteger)row
{
    if(![self isRowExpanded:row]) return;

    NSObject *obj = [_celldata objectAtIndex:row];

    NSUInteger size = 0;
    for(NSUInteger i = row + 1; i < [_celldata count];i++) {
        if([[_celldata objectAtIndex:i] isKindOfClass:[LibraryArtist class]]) break;
        if([obj isKindOfClass:[LibraryAlbum class]])
            if([[_celldata objectAtIndex:i] isKindOfClass:[LibraryAlbum class]]) break;
        size++;
    }

    [_celldata removeObjectsInRange:NSMakeRange(row + 1, size)];
}

-(void)expandRow:(NSUInteger)row
{
    [self expandRow:row recursive:NO];
}

-(void)expandRow:(NSUInteger)row recursive:(BOOL)recursive;
{
    NSObject *obj = [_celldata objectAtIndex:row];

    if([obj isKindOfClass:[LibraryArtist class]]) {
        LibraryArtist *artist = (LibraryArtist *)obj;
        NSUInteger i = row + 1;

        if(![self isRowExpanded:row]) {
            NSSortDescriptor *sortd = [[NSSortDescriptor alloc]
                                        initWithKey:@"name"
                                        ascending:YES
                                        selector:@selector(localizedCaseInsensitiveCompare:)];
            NSSet *albums;
            if([_searchMatchedObjects count] == 0) { // not doing search atm
                albums = [artist albums];
            }
            else {
                albums = [artist albumsFromSet:_searchMatchedObjects];
            }

            for(LibraryAlbum *album in [albums sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortd, nil]]) {
                [_celldata insertObject:album atIndex:i];
                i++;
            }
        }
        if(recursive) {
            for(i = row + 1; i<[_celldata count]; i++) {
                NSObject *obj2 = [_celldata objectAtIndex:i];
                if([obj2 isKindOfClass:[LibraryArtist class]])
                    break;
                else if([obj2 isKindOfClass:[LibraryAlbum class]])
                    [self expandRow:i];
            }
        }
    }
    else if([obj isKindOfClass:[LibraryAlbum class]]) {
        if([self isRowExpanded:row]) return;

        LibraryAlbum *album = (LibraryAlbum *)obj;
        NSUInteger i = row + 1;

        // this needs to be changed to tracknumber
        NSSortDescriptor *sortd = [[NSSortDescriptor alloc]
                                   initWithKey:@"trackNumber"
                                   ascending:YES
                                   selector:@selector(compare:)];

        NSSet *tracks;
        if([_searchMatchedObjects count] == 0) { // not doing search atm
            tracks = [album tracks];
        }
        else {
            tracks = [album tracksFromSet:_searchMatchedObjects];
        }

        for(LibraryTrack *track in [tracks sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortd, nil]]) {
            [_celldata insertObject:track atIndex:i];
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
        
        NSManagedObjectContext *context = [LibraryCoreDataManager newContext];
        NSMutableArray *newCellData = [[NSMutableArray alloc] init];
        NSMutableArray *newSearchMatchedObjects = [[NSMutableArray alloc] init];
        
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
             [_celldata addObjectsFromArray:results];*/
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
            
            /*NSUInteger i;
            for(i=0; i<[_celldata count]; i++) {
                if([_searchMatchedObjects member:[_celldata objectAtIndex:i]]) continue;
                
                [self expandRow:i];
                
                for(;i < [_celldata count]; i++) {
                    if([_searchMatchedObjects member:[_celldata objectAtIndex:i]]) continue;
                    [self expandRow:i];
                }
            }*/
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
            [_celldata removeAllObjects];
            [_searchMatchedObjects removeAllObjects];

            for(NSManagedObjectID *i in newCellDataIDs)
                [_celldata addObject:[_objectContext objectWithID:i]];
            for(NSManagedObjectID *i in newSearchMatchedObjectIDs)
                [_searchMatchedObjects addObject:[_objectContext objectWithID:i]];
            
            [_tableView reloadData];
            DDLogVerbose(@"Back on main thread took %f sec", -[d3 timeIntervalSinceNow]);
        });
        
        _searchQueueDepth--;
    });
}


@end
