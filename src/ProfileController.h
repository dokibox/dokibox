//
//  ProfileController.h
//  dokibox
//
//  Created by Miles Wu on 03/11/2013.
//
//

#import <Foundation/Foundation.h>

@interface ProfileController : NSObject {
    NSArray *_profiles;
}

-(NSUInteger)numberOfProfiles;
-(NSDictionary*)profileAtIndex:(NSUInteger)index;

-(void)addProfile:(NSString *)name;

@end
