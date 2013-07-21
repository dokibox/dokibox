//
//  ManagedObjectTrack.h
//  dokibox
//
//  Created by Miles Wu on 30/06/2013.
//
//

#import <CoreData/CoreData.h>
#import "common.h"

@interface ManagedObjectTrack : NSManagedObject

-(void)resetAttributeCache;

@property (nonatomic) NSString *filename;
@property (nonatomic) NSString *name;
@property (nonatomic) NSMutableDictionary *primitiveAttributes;
@property (readonly, nonatomic) NSMutableDictionary *attributes;

@end
