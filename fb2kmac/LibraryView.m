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
        
	}
	return self;
}

- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{/*
    if([indexPath row] == 0)
        return 25.0;
    else if([indexPath row] == 1)
        return 50.0;
    else
        return 20.0;*/
    return 25.0;
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
    
    cell = reusableTableCellOfClass(tableView, LibraryViewArtistCell);
    [((LibraryViewArtistCell *)cell) setArtist:(Artist *)[_celldata objectAtIndex:[indexPath row]]];
	
	return cell;
}

@end
