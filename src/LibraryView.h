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
@class TableViewRowData;
@class Library;

@interface LibraryView : NSView <NSTableViewDataSource, NSTableViewDelegate> {
    RBLTableView *_tableView;
    RBLScrollView *_libraryScrollView;
    LibraryViewSearchView *_librarySearchView;
    BOOL _searchVisible;
    
    TableViewRowData *_rowData;
    
    Library *_library;
    NSManagedObjectContext *_objectContext;
    NSMutableSet *_searchMatchedObjects;
    
    dispatch_queue_t _searchQueue;
    int _searchQueueDepth;
}

- (id)initWithFrame:(CGRect)frame andLibrary:(Library *)library;

-(void)runSearch:(NSString *)text;

- (void)addButtonPressed:(id)sender;

-(BOOL)isRowExpanded:(NSUInteger)row;
-(BOOL)isRowExpanded:(NSUInteger)row inCellData:(NSMutableArray*)celldata;
-(void)collapseRow:(NSUInteger)row;
-(void)expandRow:(NSUInteger)row;
-(void)expandRow:(NSUInteger)row recursive:(BOOL)recursive onCellData:(NSMutableArray*)celldata andMatchedObjects:(NSMutableSet*)matchedObjects;
-(void)expandRow:(NSUInteger)row recursive:(BOOL)recursive;

@property() BOOL searchVisible;

@end
