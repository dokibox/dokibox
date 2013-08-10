//
//  FIFOBuffer.h
//  dokibox
//
//  Created by Miles Wu on 26/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FIFOBuffer : NSObject {
    void *buffer_fifo;
    int buffer_fifo_size;
    int buffer_fifo_wpos;
    int buffer_fifo_rpos;
}

-(id)initWithSize:(int)size;
-(int)size;
-(int)stored;
-(int)freespace;
-(void)write:(void *)data size:(int)size;
-(void)read:(void *)data size:(int *)size;
-(void)reset;

@end
