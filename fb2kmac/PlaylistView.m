//
//  PlaylistView.m
//  fb2kmac
//
//  Created by Miles Wu on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaylistView.h"

@implementation PlaylistView

- (id)initWithFrame:(CGRect)frame
{
    _playlistTracks= [NSMutableArray array];
    PlaylistTrack *t = [[PlaylistTrack alloc] init];
    [[t attributes] setObject:@"titl2e" forKey:@"title"];
    [[t attributes] setObject:@"albmu" forKey:@"album"];
    [_playlistTracks addObject:t];
    
	if((self = [super initWithFrame:frame])) {
		self.backgroundColor = [TUIColor colorWithWhite:0.5 alpha:1.0];
        
        _tableView = [[TUITableView alloc] initWithFrame:self.bounds];
        [_tableView setAutoresizingMask:TUIViewAutoresizingFlexibleSize];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setMaintainContentOffsetAfterReload:TRUE];
        [_tableView setClipsToBounds:TRUE];
        [_tableView setPasteboardDraggingEnabled:TRUE];
        [self addSubview:_tableView];

        
	}
	return self;
}

- (CGFloat)tableView:(TUITableView *)tableView heightForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
    CGFloat row_height = 25.0;
    return row_height;
}

- (void)tableView:(TUITableView *)tableView didClickRowAtIndexPath:(TUIFastIndexPath *)indexPath withEvent:(NSEvent *)event {
    if([event clickCount] == 2) { // Double click
        
    }
}

- (NSInteger)tableView:(TUITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return [_playlistTracks count];
}

- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
	PlaylistTrackCell *cell = reusableTableCellOfClass(tableView, PlaylistTrackCell);
    [cell setTrack:[_playlistTracks objectAtIndex:[indexPath row]]];
	
	/*TUIAttributedString *s = [TUIAttributedString stringWithString:[NSString stringWithFormat:@"example cell %d", indexPath.row]];
	s.color = [TUIColor blackColor];
	s.font = exampleFont1;
	[s setFont:exampleFont2 inRange:NSMakeRange(8, 4)]; // make the word "cell" bold
	cell.attributedString = s;*/
	
	return cell;
}

-(BOOL)tableView:(TUITableView *)tableView canMoveRowAtIndexPath:(TUIFastIndexPath *)indexPath {
    // return TRUE to enable row reordering by dragging; don't implement this method or return
    // FALSE to disable
    return TRUE;
}

-(void)tableView:(TUITableView *)tableView moveRowAtIndexPath:(TUIFastIndexPath *)fromIndexPath toIndexPath:(TUIFastIndexPath *)toIndexPath {
    // update the model to reflect the changed index paths; since this example isn't backed by
    // a "real" model, after dropping a cell the table will revert to it's previous state
    NSLog(@"Move dragged row: %@ => %@", fromIndexPath, toIndexPath);
}

-(TUIFastIndexPath *)tableView:(TUITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(TUIFastIndexPath *)fromPath toProposedIndexPath:(TUIFastIndexPath *)proposedPath {
    // optionally revise the drag-to-reorder drop target index path by returning a different index path
    // than proposedPath.  if proposedPath is suitable, return that.  if this method is not implemented,
    // proposedPath is used by default.
    return proposedPath;
}




@end
