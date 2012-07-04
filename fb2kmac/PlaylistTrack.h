//
//  PlaylistTrack.h
//  fb2kmac
//
//  Created by Miles Wu on 20/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "common.h"


@interface PlaylistTrack : NSObject {
    NSMutableDictionary *_attributes;
}
@property (readonly) NSMutableDictionary *attributes;

@end
