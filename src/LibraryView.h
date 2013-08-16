//
//  LibaryView.h
//  dokibox
//
//  Created by Miles Wu on 05/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "TUIKit.h"
#import "RBLTableView.h"

@interface LibraryView : NSView <NSTableViewDataSource, NSTableViewDelegate> {
    RBLTableView *_tableView;
    NSMutableArray *_celldata;
    NSManagedObjectContext *_objectContext;
}

-(BOOL)isRowExpanded:(NSUInteger)row;
-(void)collapseRow:(NSUInteger)row;
-(void)expandRow:(NSUInteger)row;
-(void)expandRow:(NSUInteger)row recursive:(BOOL)recursive;

@end
