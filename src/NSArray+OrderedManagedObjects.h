//
//  NSArray+OrderedManagedObjects.h
//  dokibox
//
//  Created by Miles Wu on 05/04/2014.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (OrderedManagedObjects)

-(void)moveObjects:(NSArray *)objectsToMove toRow:(NSUInteger)row;

@end
