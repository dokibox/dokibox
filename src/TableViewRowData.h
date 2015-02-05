//
//  TableViewRowData.h
//  dokibox
//
//  Created by Miles Wu on 25/09/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableViewRowData : NSMutableArray {
    NSMutableArray *_data;
    BOOL _inBulkUpdateMode;
}

-(void)startBulkUpdate;
-(void)endBulkUpdate;

@property(weak) NSTableView* tableViewDelegate;
@property(assign) NSTableViewAnimationOptions insertAnimation;
@property(assign) NSTableViewAnimationOptions removeAnimation;

@end
