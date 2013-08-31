//
//  LibaryView.h
//  dokibox
//
//  Created by Miles Wu on 05/02/2013.
//
//

#import <Foundation/Foundation.h>
#import "RBLTableView.h"

@class RBLScrollView;
@class LibraryViewSearchView;

@interface LibraryView : NSView <NSTableViewDataSource, NSTableViewDelegate> {
    RBLTableView *_tableView;
    RBLScrollView *_libraryScrollView;
    LibraryViewSearchView *_librarySearchView;
    
    NSMutableArray *_celldata;
    NSManagedObjectContext *_objectContext;
}

-(void)showSearch;
-(void)hideSearch;
-(void)runSearch:(NSString *)text;

-(BOOL)isRowExpanded:(NSUInteger)row;
-(void)collapseRow:(NSUInteger)row;
-(void)expandRow:(NSUInteger)row;
-(void)expandRow:(NSUInteger)row recursive:(BOOL)recursive;

@end
