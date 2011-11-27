//
//  PlaylistController.m
//  fb2kmac
//
//  Created by Miles Wu on 20/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaylistController.h"
#import "PlaylistTrack.h"

@implementation PlaylistController
@synthesize trackArray;

- (id)init{
    self = [super init];
    trackArray = [NSMutableArray array]; //automatic allocation
    //PlaylistTrack *pt = [[PlaylistTrack alloc] init]; //manual allocation
    //[pt setTitle:@"hi"];
    //[trackArray addObject:pt];
    
    NSLog(@"It lives!");
    return self;
}

- (void)awakeFromNib { //runs when the nib file finishes loading
    [playlistTableView registerForDraggedTypes: [NSArray arrayWithObject:NSFilenamesPboardType]];
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
    NSLog(@"Inserting %lu rows, starting at row %i",[arr count],row);
    NSUInteger i = 0;
    for(id s in arr) {
        PlaylistTrack *track = [[PlaylistTrack alloc] init];
        [track setTitle:s];
        [playlistArrayController insertObject:track atArrangedObjectIndex:row+i]; //inserts rather than appends
        i++;
    }
    return YES;
}

- (IBAction)deleteButtonPressed:(id)sender {
    //NSLog(@"Delete button pressed.");
    NSLog(@"Deleting %lu rows.",[[playlistTableView selectedRowIndexes] count]);
    [playlistArrayController removeObjectsAtArrangedObjectIndexes:[playlistTableView selectedRowIndexes]];
}

@end
