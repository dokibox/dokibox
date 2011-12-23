//
//  MP3Decoder.h
//  fb2kmac
//
//  Created by Miles Wu on 22/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecoderProtocol.h"
#include <mpg123.h>

@interface MP3Decoder : NSObject<DecoderProtocol> {
    mpg123_handle *mh;
    
     
}
-(void)feedData:(NSData *)data;
- (void *)getBuffer:(size_t *)size;

@end
