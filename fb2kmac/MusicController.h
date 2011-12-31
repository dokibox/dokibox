//
//  MusicController.h
//  fb2kmac
//
//  Created by Miles Wu on 22/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "common.h"
#import "MP3Decoder.h"
#import "DecoderProtocol.h"
#include <AudioToolbox/AudioToolbox.h>


struct hilarity {
    void *controller;
    AudioConverterRef converter;
    
    void *buffer_fifo;
    int buffer_fifo_size;
    int buffer_fifo_wpos;
    int buffer_fifo_rpos;
    void *buffer_provider;
    int buffer_provider_size;
    
    dispatch_queue_t decoding_queue;
};

@interface MusicController : NSObject {
    PlaylistController  *currentPlaylistController;
    
    MP3Decoder *mp3Decoder;
    id<DecoderProtocol> currentDecoder;
    
    ComponentInstance outputUnit;
    struct hilarity h;
    BOOL firstDataRecieved;
}

- (void)play:(id)sender;
- (void)getBuffer:(void *)data size:(size_t *)size;

-(int)storedFifo;
-(int)freespaceFifo;
- (void)writeFifo:(void *)data size:(int)size;
- (void)readFifo:(void *)data size:(int)size;

@end
