//
//  NSManagedObjectContext+Helpers.h
//  dokibox
//
//  Created by Miles Wu on 24/10/2013.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Helpers)

-(BOOL)belongsToSameStoreAs:(NSManagedObject *)context;
-(NSManagedObjectContext*)newContext;

@end
