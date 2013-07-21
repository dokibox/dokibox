//
//  ManagedObjectTrack.m
//  dokibox
//
//  Created by Miles Wu on 30/06/2013.
//
//

#import "ManagedObjectTrack.h"
#import "common.h"

@implementation ManagedObjectTrack

@dynamic filename;
@dynamic name;
@dynamic primitiveAttributes;

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


-(void)resetAttributeCache
{
    [self setPrimitiveAttributes:nil];
}


@end
