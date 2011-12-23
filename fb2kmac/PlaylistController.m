//
//  PlaylistController.m
//  fb2kmac
//
//  Created by Miles Wu on 20/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaylistController.h"
#import "PlaylistTrack.h"
#import "MusicController.h"

@implementation PlaylistController
@synthesize trackArray;

- (id)init{
    self = [super init];
    trackArray = [NSMutableArray array];
    PlaylistTrack *pt = [[PlaylistTrack alloc] init];
    [pt setTitle:@"hi"];
    [trackArray addObject:pt];
    currentPlayingTrackIndex = -1;
    
    return self;
}

- (void)awakeFromNib {
    [playlistTableView registerForDraggedTypes: [NSArray arrayWithObject:NSFilenamesPboardType]];
    [playlistTableView setTarget:self];
    [playlistTableView setDoubleAction:@selector(trackDoubleClicked:)];
    NSLog(@"awake from nib in Playlist controller");
}

/* This is for a source drag
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {
    NSLog(@"draggg");
    return YES;
}*/

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op {    
    if(op == NSTableViewDropOn)
        return NSDragOperationNone;
    else
        return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id)info row:(int)row dropOperation:(NSTableViewDropOperation)op {
    NSPasteboard *pb = [info draggingPasteboard];
    NSArray *arr = [pb propertyListForType:NSFilenamesPboardType];
    for(id s in arr) {
        PlaylistTrack *track = [[PlaylistTrack alloc] init];
        [track setTitle:s];
        [playlistArrayController addObject:track];
    }
    return YES;
}

- (void)trackDoubleClicked:(id)sender {
    NSTableView *tv = sender;
    if([tv clickedRow] == -1)
        return;
    currentPlayingTrackIndex = (int) [tv clickedRow];
    [musicController play:self];
}

- (PlaylistTrack *)getCurrentTrack {
    return([trackArray objectAtIndex:currentPlayingTrackIndex]);
}
    
@end
