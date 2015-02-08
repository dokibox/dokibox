//
//  ProfileController.m
//  dokibox
//
//  Created by Miles Wu on 03/11/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "ProfileController.h"

@implementation ProfileController

+(ProfileController *)sharedInstance
{
    static dispatch_once_t pred;
    static ProfileController *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[ProfileController alloc] init];
    });
    return shared;
}

-(id)init
{
    self = [super init];
    if(self) {
        _profiles = [[NSUserDefaults standardUserDefaults] arrayForKey:@"libraryProfiles"];
        if(_profiles == nil)
            _profiles = [[NSArray alloc] init];
        
        if([_profiles count] == 0) {
            [self addProfile:@"Default"];
        }
        
        NSInteger default_index = [[NSUserDefaults standardUserDefaults] integerForKey:@"defaultLibraryProfile"];
        if(default_index >= [_profiles count] || default_index < 0) {
            default_index = 0;
            DDLogError(@"Invalid defaultLibraryProfile index");
        }
        [self setCurrentProfileToIndex:default_index];
    }
    return self;
}

-(void)setCurrentProfileToIndex:(NSUInteger)index
{
    _currentProfile = [_profiles objectAtIndex:index];
}

-(void)setDefaultProfileToIndex:(NSUInteger)index
{
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"defaultLibraryProfile"];
}

-(NSDictionary *)currentProfile
{
    return _currentProfile;
}

-(NSUInteger)currentProfileIndex
{
    return [_profiles indexOfObject:[self currentProfile]];
}

-(NSString *)currentUUID
{
    return [[self currentProfile] objectForKey:@"uuid"];
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
    _profiles = [[NSArray alloc] initWithArray:arr];
    [self synchronize];
}

-(void)removeProfileAtIndex:(NSUInteger)index
{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:_profiles];
    [arr removeObjectAtIndex:index];
    _profiles = [[NSArray alloc] initWithArray:arr];
    [self synchronize];
}

-(void)synchronize
{
    [[NSUserDefaults standardUserDefaults] setObject:_profiles forKey:@"libraryProfiles"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
