//
//  NSArray+OrderedManagedObjects.m
//  dokibox
//
//  Created by Miles Wu on 05/04/2014.
//
//

#import "NSArray+OrderedManagedObjects.h"
#import "OrderedManagedObject.h"

@implementation NSArray (OrderedManagedObjects)

-(void)moveObjects:(NSArray *)objectsToMove toRow:(NSUInteger)row {
    // Validity checks
    for(NSObject<OrderedManagedObject> *obj in objectsToMove) {
        if([self containsObject:obj] == false) {
            DDLogError(@"Object Move: one of the objects requested to be moved is not present in the array");
            return;
        }
        if([[obj class] conformsToProtocol:@protocol(OrderedManagedObject)] == false) {
            DDLogError(@"This function only operates on OrderedManagedObjects");
            return;
        }
    }
    for(NSObject<OrderedManagedObject> *obj in self) {
        if([[obj class] conformsToProtocol:@protocol(OrderedManagedObject)] == false) {
            DDLogError(@"This function only operates on OrderedManagedObjects");
            return;
        }
    }
    
    // Calculate insertion point (compensate for the objects moving)
    NSInteger insertStartRow = row;
    for(id<OrderedManagedObject> obj in objectsToMove) {
        if([[obj index] intValue] < row) insertStartRow--;
    }
    if(insertStartRow < 0) {
        DDLogError(@"Negative insertion row calculated during object move");
        insertStartRow = 0;
    }
    
    // Renumber existing objects around hole
    NSUInteger i = 0;
    for(id<OrderedManagedObject> obj in self) {
        if([objectsToMove containsObject:obj]) { // This skips over the objects we are trying to move
            continue;
        }
        
        if(i == insertStartRow) i += [objectsToMove count]; // This leaves the gap for the moved objects
        
        [obj setIndex:[NSNumber numberWithInteger:i]];
        i++;
    }
    
    // Renumber the objects playlists
    for(id<OrderedManagedObject> obj in objectsToMove) {
        [obj setIndex:[NSNumber numberWithInteger:insertStartRow]];
        insertStartRow++;
    }
}

@end
