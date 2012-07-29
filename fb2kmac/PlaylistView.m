//
//  PlaylistView.m
//  fb2kmac
//
//  Created by Miles Wu on 01/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlaylistView.h"
#import "MusicController.h"

@implementation PlaylistView

- (id)initWithFrame:(CGRect)frame andPlaylist:(Playlist *)playlist
{
	if((self = [super initWithFrame:frame])) {
		self.backgroundColor = [TUIColor colorWithWhite:0.5 alpha:1.0];

        _playlist = playlist;
        
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
        [_playlist playTrackAtIndex:[indexPath row]];
    }
}

- (NSInteger)tableView:(TUITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return [_playlist numberOfTracks];
}

- (TUITableViewCell *)tableView:(TUITableView *)tableView cellForRowAtIndexPath:(TUIFastIndexPath *)indexPath
{
	PlaylistTrackCell *cell = reusableTableCellOfClass(tableView, PlaylistTrackCell);
    [cell setTrack:[_playlist trackAtIndex:[indexPath row]]];
	
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
            PlaylistTrack *t = [[PlaylistTrack alloc] initWithFilename:s];
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


@end
