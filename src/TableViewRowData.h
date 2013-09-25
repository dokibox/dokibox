//
//  TableViewRowData.h
//  dokibox
//
//  Created by Miles Wu on 25/09/2013.
//
//

#import <Foundation/Foundation.h>

@interface TableViewRowData : NSMutableArray {
    NSMutableArray *_data;
}

@property(weak) NSTableView* tableViewDelegate;

@end
