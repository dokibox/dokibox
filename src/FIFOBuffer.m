//
//  FIFOBuffer.m
//  dokibox
//
//  Created by Miles Wu on 26/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FIFOBuffer.h"

@implementation FIFOBuffer

-(id)initWithSize:(int)size {
    self = [super init];

    buffer_fifo_size = size;
    buffer_fifo_wpos = 0;
    buffer_fifo_rpos = 0;
    buffer_fifo = malloc(buffer_fifo_size);

    return self;
}

-(int)stored {
    int stored;
    if(buffer_fifo_wpos >= buffer_fifo_rpos)
        stored = buffer_fifo_wpos - buffer_fifo_rpos;
    else
        stored = buffer_fifo_size - buffer_fifo_rpos + buffer_fifo_wpos;
    return(stored);
}

-(int)freespace {
    return(buffer_fifo_size - [self stored] - 1); //This must be 1 less or how would you tell a full buffer from an empty one when (wpos==rpos).
}

- (void)write:(void *)data size:(int)size {
    // check enough space
    if(size > [self freespace]) {
        NSLog(@"size we tried to write: %d", size);
        NSLog(@"free space: %d", [self freespace]);
        assert(size <= [self freespace]);
    }

    if(size + buffer_fifo_wpos > buffer_fifo_size) {
        //split write up into two halves
        memcpy(buffer_fifo + buffer_fifo_wpos, data, buffer_fifo_size - buffer_fifo_wpos);
        size -= buffer_fifo_size - buffer_fifo_wpos;
        data += buffer_fifo_size - buffer_fifo_wpos;
        buffer_fifo_wpos = 0;
    }
    memcpy(buffer_fifo + buffer_fifo_wpos, data, size);
    buffer_fifo_wpos += size;
}

- (void)read:(void *)data size:(int *)size {
    if([self stored] < *size) {
        *size = [self stored];
    }
    int tempsize = *size;

    if(tempsize + buffer_fifo_rpos > buffer_fifo_size) {
        //split read up into two halves
        memcpy(data, buffer_fifo + buffer_fifo_rpos, buffer_fifo_size - buffer_fifo_rpos);
        tempsize -= buffer_fifo_size - buffer_fifo_rpos;
        data += buffer_fifo_size - buffer_fifo_rpos;
        buffer_fifo_rpos = 0;
    }
    memcpy(data, buffer_fifo + buffer_fifo_rpos, tempsize);
    buffer_fifo_rpos += tempsize;
}

-(void)reset {
    buffer_fifo_wpos = 0;
    buffer_fifo_rpos = 0;
}

@end
