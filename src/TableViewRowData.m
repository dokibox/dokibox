//
//  TableViewRowData.m
//  dokibox
//
//  Created by Miles Wu on 25/09/2013.
//
//

#import "TableViewRowData.h"

@implementation TableViewRowData

@synthesize tableViewDelegate = _tableViewDelegate;

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
    if(_tableViewDelegate)
        [_tableViewDelegate insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:NULL];
}

-(void)removeObjectAtIndex:(NSUInteger)index
{
    [_data removeObjectAtIndex:index];
    if(_tableViewDelegate)
        [_tableViewDelegate removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:NULL];
}

-(void)addObject:(id)anObject
{
    [_data addObject:anObject];
    if(_tableViewDelegate)
        [_tableViewDelegate insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:([self count] -1)] withAnimation:NULL];
}

-(void)removeLastObject
{
    [_data removeLastObject];
    if(_tableViewDelegate)
        [_tableViewDelegate removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:[self count]] withAnimation:NULL];
}

-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [self replaceObjectAtIndex:index withObject:anObject];
    if(_tableViewDelegate)
        [_tableViewDelegate reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [_tableViewDelegate numberOfColumns])]];
}

@end
