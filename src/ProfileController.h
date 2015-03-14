//
//  ProfileController.h
//  dokibox
//
//  Created by Miles Wu on 03/11/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfileController : NSObject {
    NSArray *_profiles;
    NSDictionary *_currentProfile;
}
+(ProfileController *)sharedInstance;

-(void)setCurrentProfileToIndex:(NSUInteger)index;
-(void)setDefaultProfileToIndex:(NSUInteger)index;
-(NSDictionary *)currentProfile;
-(NSUInteger)currentProfileIndex;
-(NSString *)currentUUID;

-(NSUInteger)numberOfProfiles;
-(NSDictionary*)profileAtIndex:(NSUInteger)index;

-(void)addProfile:(NSString *)name;
-(void)removeProfileAtIndex:(NSUInteger)index;
-(void)setCurrentlySelectedPlaylistForCurrentProfile:(NSURL*)coreDataURL;
-(void)synchronize;

@property NSURL* currentlySelectedPlaylistForCurrentProfile;

@end
