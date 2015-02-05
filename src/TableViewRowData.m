//
//  TableViewRowData.m
//  dokibox
//
//  Created by Miles Wu on 25/09/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "TableViewRowData.h"

@implementation TableViewRowData

@synthesize tableViewDelegate = _tableViewDelegate;
@synthesize insertAnimation = _insertAnimation;
@synthesize removeAnimation = _removeAnimation;

-(id)init
{
    self = [super init];
    if(self) {
        _data = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSUInteger)count
{
    return [_data count];
}

-(id)objectAtIndex:(NSUInteger)index
{
    return [_data objectAtIndex:index];
}

-(void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    [_data insertObject:anObject atIndex:index];
    if(_tableViewDelegate && _inBulkUpdateMode == NO)
        [_tableViewDelegate insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:_insertAnimation];
}

-(void)removeObjectAtIndex:(NSUInteger)index
{
    [_data removeObjectAtIndex:index];
    if(_tableViewDelegate && _inBulkUpdateMode == NO)
        [_tableViewDelegate removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:_removeAnimation];
}

-(void)addObject:(id)anObject
{
    [_data addObject:anObject];
    if(_tableViewDelegate && _inBulkUpdateMode == NO)
        [_tableViewDelegate insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:([self count] -1)] withAnimation:_insertAnimation];
}

-(void)removeLastObject
{
    [_data removeLastObject];
    if(_tableViewDelegate && _inBulkUpdateMode == NO)
        [_tableViewDelegate removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:[self count]] withAnimation:_removeAnimation];
}

-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [self replaceObjectAtIndex:index withObject:anObject];
    if(_tableViewDelegate && _inBulkUpdateMode == NO)
        [_tableViewDelegate reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [_tableViewDelegate numberOfColumns])]];
}

-(void)startBulkUpdate
{
    _inBulkUpdateMode = YES;
}

-(void)endBulkUpdate
{
    _inBulkUpdateMode = NO;
    if(_tableViewDelegate)
        [_tableViewDelegate reloadData];
}

@end
