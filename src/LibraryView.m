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

@implementation LibraryView

- (id)initWithFrame:(CGRect)frame
{
	if((self = [super initWithFrame:frame])) {
        RBLScrollView *libraryScrollView = [[RBLScrollView alloc] initWithFrame:[self bounds]];
        [libraryScrollView setHasVerticalScroller:YES];        
        
        _tableView = [[RBLTableView alloc] initWithFrame:[[libraryScrollView contentView] bounds]];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setHeaderView:nil];
        [_tableView setAction:@selector(clickRecieved:)];
        [_tableView setDoubleAction:@selector(doubleClickReceived:)];
        [_tableView setIntercellSpacing:NSMakeSize(0, 0)];
        
        NSTableColumn *libraryFirstColumn = [[NSTableColumn alloc] initWithIdentifier:@"main"];
        [_tableView addTableColumn:libraryFirstColumn];
        [libraryFirstColumn setWidth:[libraryScrollView contentSize].width];

        [libraryScrollView setDocumentView:_tableView];
        //[libraryScrollView setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];
        [self addSubview:libraryScrollView];

        _celldata = [[NSMutableArray alloc] init];
        _objectContext = [LibraryCoreDataManager newContext];

        NSError *error;
        NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"artist"];
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                     initWithKey:@"name"
                                     ascending:YES
                                     selector:@selector(localizedCaseInsensitiveCompare:)];
        [fr setSortDescriptors:[NSArray arrayWithObjects:sorter, nil]];
        NSDate *d1 = [NSDate date];
        NSArray *results = [_objectContext executeFetchRequest:fr error:&error];
        [_celldata addObjectsFromArray:results];
        NSDate *d2 = [NSDate date];
        NSLog(@"Fetching %lu artists took %f sec", [_celldata count], [d2 timeIntervalSinceDate:d1]);
        [_tableView reloadData];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLibrarySavedNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
	}
	return self;
}

-(void)drawRect:(NSRect)dirtyRect
{
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(ctx, .87, .17, .87, 1);
    CGContextFillRect(ctx, [self bounds]);
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
    }
    else if([obj isKindOfClass:[LibraryAlbum class]]) {
        view = [tableView makeViewWithIdentifier:@"libraryViewAlbumCell" owner:self];
        
        if(view == nil) {
            NSRect frame = NSMakeRect(0, 0, 200, 25);
            view = [[LibraryViewAlbumCell alloc] initWithFrame:frame];
            view.identifier = @"libraryViewAlbumCell";
        }
        
        [((LibraryViewAlbumCell *)view) setAlbum:(LibraryAlbum *)[_celldata objectAtIndex:row]];
    }
    else if([obj isKindOfClass:[LibraryTrack class]]) {
        view = [tableView makeViewWithIdentifier:@"libraryViewTrackCell" owner:self];
        
        if(view == nil) {
            NSRect frame = NSMakeRect(0, 0, 200, 25);
            view = [[LibraryViewTrackCell alloc] initWithFrame:frame];
            view.identifier = @"libraryViewTrackCell";
        }
        
        [((LibraryViewTrackCell *)view) setTrack:(LibraryTrack *)[_celldata objectAtIndex:row]];
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
            for(LibraryAlbum *album in [[artist albums] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortd, nil]]) {
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

        for(LibraryTrack *track in [[album tracks] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortd, nil]]) {
            [_celldata insertObject:track atIndex:i];
            i++;
        }
    }
}

@end
