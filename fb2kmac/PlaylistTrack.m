//
//  PlaylistTrack.m
//  fb2kmac
//
//  Created by Miles Wu on 20/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaylistTrack.h"

@implementation PlaylistTrack

@synthesize attributes = _attributes;

- (id)init{
    self = [super init];
    _attributes = [NSMutableDictionary dictionary];
    return self;
}

@end
