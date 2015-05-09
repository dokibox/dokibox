//
//  ManagedObjectTrack.m
//  dokibox
//
//  Created by Miles Wu on 30/06/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "ManagedObjectTrack.h"
#import "common.h"

@implementation ManagedObjectTrack

@dynamic filename;
@dynamic name;
@dynamic primitiveAttributes;
@dynamic needsUpdate;

+(void)markAllTracksForUpdateIn:(NSManagedObjectContext *)context
{
    NSError *error;
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"track"];
    NSArray *results = [context executeFetchRequest:fr error:&error];
    if(error) {
        DDLogError(@"Failed to execute fetch request in markAllTracksForUpdateIn:");
        return;
    }
    
    // Set needsUpdate = yes on all tracks
    for(ManagedObjectTrack *t in results) {
        [t setNeedsUpdate:[NSNumber numberWithBool:YES]];
    }
    
    // Save
    [context save:&error];
    if(error) {
        DDLogError(@"Failed to save in markAllTracksForUpdateIn:");
    }
}

+(void)updateAllTracksMarkedForUpdateIn:(NSManagedObjectContext *)objectContext
{
    [self updateAllTracksMarkedForUpdateFrom:objectContext inQueue:NULL andContext:objectContext];
}

+(void)updateAllTracksMarkedForUpdateFrom:(NSManagedObjectContext *)objectContext inQueue:(dispatch_queue_t)queue andContext:(NSManagedObjectContext *)contextInQueue
{
    NSError *error;
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"track"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"needsUpdate == YES"];
    [fr setPredicate:predicate];
    NSArray *results = [objectContext executeFetchRequest:fr error:&error];
    DDLogVerbose(@"%ld tracks need an update", [results count]);

    for(ManagedObjectTrack *t in results) {
        // Run block either on specified thread or on current thread
        void (^block)() = ^{
            ManagedObjectTrack *t2 = (ManagedObjectTrack *)[contextInQueue objectWithID:[t objectID]];
            BOOL retval = [t2 updateFromFile];
            if(retval == YES) {
                NSError *error2;
                [contextInQueue save:&error2];
                if(error2) {
                    DDLogError(@"Error saving in updateAllTracksMarkedForUpdate");
                }
            }
        };

        if(queue) {
            dispatch_sync(queue, block);
        }
        else {
            block();
        }
    }
}

-(BOOL)updateFromFile
{
    // This should be overriden in subclasses. Remember to call super tho! as it resets the needsUpdate flag
    [self setNeedsUpdate:[NSNumber numberWithBool:NO]];
    return YES;
}


-(NSMutableDictionary *)attributes
{
    [self willAccessValueForKey:@"attributes"];
    NSMutableDictionary *dict = [self primitiveAttributes];
    [self didAccessValueForKey:@"attributes"];
    if(dict == nil) {
        id<TaggerProtocol> tagger = [[TaglibTagger alloc] initWithFilename:[self filename]];
        if(!tagger) {
            DDLogWarn(@"Tagger wasn't initialized properly");
            return nil;
        }
        dict = [tagger tag];
        [self setPrimitiveAttributes:dict];
    }
    return dict;
}

-(NSImage*)cover
{
    id<TaggerProtocol> tagger = [[TaglibTagger alloc] initWithFilename:[self filename]];
    return [tagger cover];
}


-(void)resetAttributeCache
{
    [self setPrimitiveAttributes:nil];
}


@end
