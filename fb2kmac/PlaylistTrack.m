//
//  PlaylistTrack.m
//  fb2kmac
//
//  Created by Miles Wu on 20/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaylistTrack.h"
#import "TaggerProtocol.h"

@implementation PlaylistTrack

@synthesize attributes = _attributes;
@synthesize filename = _filename;

- (id)init {
    self = [super init];
    _attributes = [NSMutableDictionary dictionary];
    return self;
}

- (id)initWithFilename:(NSString *)filename {
    self = [self init];
    
    id<TaggerProtocol> tagger = [[TaglibTagger alloc] initWithFilename:filename];
    _attributes = [tagger tag];
    
    _filename = filename;
    
    return self;
}

@end
