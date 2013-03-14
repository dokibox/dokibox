//
//  LibaryView.m
//  fb2kmac
//
//  Created by Miles Wu on 05/02/2013.
//
//

#import "LibraryView.h"
#import "LibraryViewArtistCell.h"
#import "LibraryViewAlbumCell.h"
#import "LibraryViewTrackCell.h"
#import "CoreDataManager.h"
#import "Artist.h"

@implementation LibraryView

- (id)initWithFrame:(CGRect)frame
{
	if((self = [super initWithFrame:frame])) {
		self.backgroundColor = [TUIColor colorWithWhite:0.5 alpha:1.0];
                
        _tableView = [[TUITableView alloc] initWithFrame:self.bounds];
        [_tableView setAutoresizingMask:TUIViewAutoresizingFlexibleSize];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setMaintainContentOffsetAfterReload:TRUE];
        [_tableView setClipsToBounds:TRUE];
        [_tableView setPasteboardReceiveDraggingEnabled:TRUE];
        [self addSubview:_tableView];
        
        _celldata = [[NSMutableArray alloc] init];
        NSError *error;
        CoreDataManager *cdm = [CoreDataManager sharedInstance];
        NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"artist"];
        [fr setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil]];
        NSDate *d1 = [NSDate date];
        NSArray *results = [[cdm context] executeFetchRequest:fr error:&error];
        [_celldata addObjectsFromArray:results];
        NSDate *d2 = [NSDate date];
        NSLog(@"Fetching %lu artists took %f sec", [_celldata count], [d2 timeIntervalSinceDate:d1]);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLibraryUpdatedNotification:) name:@"libraryUpdated" object:nil];
	}
	return self;
}

-(void)receivedLibraryUpdatedNotification:(NSNotification *)notification
{
    [_celldata removeAllObjects];
    NSError *error;
    CoreDataManager *cdm = [CoreDataManager sharedInstance];
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"artist"];
    [fr setSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES], nil]];
    NSDate *d1 = [NSDate date];
    NSArray *results = [[cdm context] executeFetchRequest:fr error:&error];
    [_celldata addObjectsFromArray:results];
    NSDate *d2 = [NSDate date];
    NSLog(@"Fetching %lu artists took %f sec", [_celldata count], [d2 timeIntervalSinceDate:d1]);
    
    [_tableView reloadData];
}

- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    NSObject *obj = [_celldata objectAtIndex:[indexPath row]];
    if([obj isKindOfClass:[Artist class]]) {
        return 25.0;
    }
    else if([obj isKindOfClass:[Album class]]) {
        return 50.0;
    }
    else if([obj isKindOfClass:[Track class]]) {
        return 20.0;
    }
    else {
        return 1.0;
    }
}

- (NSInteger)tableView:(TUITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return [_celldata count];
}

- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    TUITableViewCell *cell;
    /*if([indexPath row] == 0)
        cell = reusableTableCellOfClass(tableView, LibraryViewArtistCell);
	else if([indexPath row] == 1)
        cell = reusableTableCellOfClass(tableView, LibraryViewAlbumCell);
    else
        cell = reusableTableCellOfClass(tableView, LibraryViewTrackCell);*/
    
    NSObject *obj = [_celldata objectAtIndex:[indexPath row]];
    if([obj isKindOfClass:[Artist class]]) {
        cell = reusableTableCellOfClass(tableView, LibraryViewArtistCell);
        [((LibraryViewArtistCell *)cell) setArtist:(Artist *)[_celldata objectAtIndex:[indexPath row]]];
    }
    else if([obj isKindOfClass:[Album class]]) {
        cell = reusableTableCellOfClass(tableView, LibraryViewAlbumCell);
        [((LibraryViewAlbumCell *)cell) setAlbum:(Album *)[_celldata objectAtIndex:[indexPath row]]];
    }
    else if([obj isKindOfClass:[Track class]]) {
        cell = reusableTableCellOfClass(tableView, LibraryViewTrackCell);
        [((LibraryViewTrackCell *)cell) setTrack:(Track *)[_celldata objectAtIndex:[indexPath row]]];
    }
    
    
    
	return cell;
}

-(BOOL)isRowExpanded:(NSUInteger)row
{
    if(row == [_celldata count] - 1) //last item, so can't be expanded
        return NO;
    
    NSObject *c1 = [_celldata objectAtIndex:row];
    NSObject *c2 = [_celldata objectAtIndex:row+1];
    if([c1 isKindOfClass:[Artist class]]) {
        if([c2 isKindOfClass:[Album class]])
            return YES;
        else
            return NO;
    }
    else if([c1 isKindOfClass:[Album class]]) {
        if([c2 isKindOfClass:[Track class]])
            return YES;
        else
            return NO;
    }
    else //Tracks can't be expanded
        return NO;
}

- (void)tableView:(TUITableView *)tableView didClickRowAtIndexPath:(TUIFastIndexPath *)indexPath withEvent:(NSEvent *)event {
    if([event clickCount] == 2) { //double click
        NSLog(@"double click");
        
        [self expandRow:[indexPath row] recursive:YES];
        
        NSObject *obj = [_celldata objectAtIndex:[indexPath row]];
        NSMutableArray *tracks = [[NSMutableArray alloc] init];
        if([obj isKindOfClass:[Track class]]) { // if its a track, only one
            [tracks addObject:[((Track *)obj) filename]];
        }
        else {
            for(NSUInteger i = [indexPath row] + 1; i<[_celldata count]; i++) {
                NSObject *obj2 = [_celldata objectAtIndex:i];
                if([obj isKindOfClass:[Album class]] && ([obj2 isKindOfClass:[Album class]] || [obj2 isKindOfClass:[Album class]]))
                    break;
                if([obj isKindOfClass:[Artist class]] && [obj2 isKindOfClass:[Artist class]])
                    break;

                if([obj2 isKindOfClass:[Track class]])
                    [tracks addObject:[((Track *)obj2) filename]];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addTrackToCurrentPlaylist" object:tracks];
        
        [tableView reloadData];
        return;
    }
    
    if([self isRowExpanded:[indexPath row]]) {
        [self collapseRow:[indexPath row]];
    }
    else {
        [self expandRow:[indexPath row]];
    }
    

    [tableView reloadData];
}

-(void)collapseRow:(NSUInteger)row
{
    if(![self isRowExpanded:row]) return;
    
    NSObject *obj = [_celldata objectAtIndex:row];
    
    NSUInteger size = 0;
    for(NSUInteger i = row + 1; i < [_celldata count];i++) {
        if([[_celldata objectAtIndex:i] isKindOfClass:[Artist class]]) break;
        if([obj isKindOfClass:[Album class]])
            if([[_celldata objectAtIndex:i] isKindOfClass:[Album class]]) break;
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
    
    if([obj isKindOfClass:[Artist class]]) {
        Artist *artist = (Artist *)obj;
        NSUInteger i = row + 1;
        
        if(![self isRowExpanded:row]) {
            NSSortDescriptor *sortd = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
            for(Album *album in [[artist albums] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortd, nil]]) {
                [_celldata insertObject:album atIndex:i];
                i++;
            }
        }
        if(recursive) {
            for(i = row + 1; i<[_celldata count]; i++) {
                NSObject *obj2 = [_celldata objectAtIndex:i];
                if([obj2 isKindOfClass:[Artist class]])
                    break;
                else if([obj2 isKindOfClass:[Album class]])
                    [self expandRow:i];
            }
        }
    }
    else if([obj isKindOfClass:[Album class]]) {
        if([self isRowExpanded:row]) return;

        Album *album = (Album *)obj;
        NSUInteger i = row + 1;
        
        // this needs to be changed to tracknumber
        NSSortDescriptor *sortd = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        
        for(Track *track in [[album tracks] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortd, nil]]) {
            [_celldata insertObject:track atIndex:i];
            i++;
        }
    }
}

@end
