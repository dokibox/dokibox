//
//  ProfileController.m
//  dokibox
//
//  Created by Miles Wu on 03/11/2013.
//
//

#import "ProfileController.h"

@implementation ProfileController

-(id)init
{
    self = [super init];
    if(self) {
        _profiles = [[NSUserDefaults standardUserDefaults] arrayForKey:@"libraryProfiles"];
        if(_profiles == nil)
            _profiles = [[NSArray alloc] init];
    }
    return self;
}

-(NSUInteger)numberOfProfiles
{
    return [_profiles count];
}

-(NSDictionary*)profileAtIndex:(NSUInteger)index
{
    return [_profiles objectAtIndex:index];
}

-(void)addProfile:(NSString *)name
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:name forKey:@"name"];
    
    //UUID
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid));
    CFRelease(uuid);
    [dict setObject:uuidString forKey:@"uuid"];
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:_profiles];
    [arr addObject:dict];
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:@"libraryProfiles"];
    _profiles = [[NSUserDefaults standardUserDefaults] arrayForKey:@"libraryProfiles"];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
