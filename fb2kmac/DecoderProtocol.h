//
//  DecoderProtocol.h
//  fb2kmac
//
//  Created by Miles Wu on 22/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DecoderProtocol <NSObject>
-(void)feedData:(NSData *)data;
- (void)getBuffer:(void *)data size:(size_t *)size;

@end
