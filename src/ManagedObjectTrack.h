//
//  ManagedObjectTrack.h
//  dokibox
//
//  Created by Miles Wu on 30/06/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "common.h"

@interface ManagedObjectTrack : NSManagedObject

+(void)markAllTracksForUpdateIn:(NSManagedObjectContext *)context;
+(void)updateAllTracksMarkedForUpdateIn:(NSManagedObjectContext *)context;

-(BOOL)updateFromFile;
-(void)resetAttributeCache;

@property (nonatomic) NSString *filename;
@property (nonatomic) NSString *name;
@property NSNumber *needsUpdate;
@property (nonatomic) NSMutableDictionary *primitiveAttributes;
@property (readonly, nonatomic) NSMutableDictionary *attributes;
@property (readonly) NSImage* cover;

@end
