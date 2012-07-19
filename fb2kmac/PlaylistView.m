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
    
    t = [[PlaylistTrack alloc] init];
    [[t attributes] setObject:@"titl3e" forKey:@"title"];
    [[t attributes] setObject:@"albmu" forKey:@"album"];
    [_playlistTracks addObject:t];
    t = [[PlaylistTrack alloc] init];
    [[t attributes] setObject:@"titl4e" forKey:@"title"];
    [[t attributes] setObject:@"albmu" forKey:@"album"];
    [_playlistTracks addObject:t];
    t = [[PlaylistTrack alloc] init];
    [[t attributes] setObject:@"titl5e" forKey:@"title"];
    [[t attributes] setObject:@"albmu" forKey:@"album"];
    [_playlistTracks addObject:t];
    t = [[PlaylistTrack alloc] init];
    [[t attributes] setObject:@"titl6e" forKey:@"title"];
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
        [_tableView setPasteboardReceiveDraggingEnabled:TRUE];
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
    PlaylistTrack *t = [_playlistTracks objectAtIndex:[fromIndexPath row]];
    [_playlistTracks removeObjectAtIndex:[fromIndexPath row]];
    [_playlistTracks insertObject:t atIndex:[toIndexPath row]];
}

- (BOOL)tableView:(TUITableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info path:(TUIFastIndexPath *)path
{
    PlaylistTrack *t = [[PlaylistTrack alloc] init];
    [[t attributes] setObject:@"new" forKey:@"title"];
    [[t attributes] setObject:@"new" forKey:@"album"];
    [_playlistTracks insertObject:t atIndex:[path row]];
    return YES;
}

- (NSDragOperation)tableView:(TUITableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedPath:(TUIFastIndexPath *)path withGapHeight:(float *)height
{
    *height = 25.0;
    return NSDragOperationCopy;
}




@end
