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
#import "FLACDecoder.h"
#import "VorbisDecoder.h"
#import "DecoderProtocol.h"
#import "FIFOBuffer.h"
#include <AudioToolbox/AudioToolbox.h>

@interface MusicController : NSObject {
    PlaylistController  *currentPlaylistController;
    
    id<DecoderProtocol> currentDecoder;
    
    ComponentInstance outputUnit;
    AudioConverterRef converter;

    
    FIFOBuffer *fifoBuffer;
    NSData *auBuffer;
    
    NSFileHandle *fileHandle;
}
@property(readonly) FIFOBuffer *fifoBuffer;
@property(readonly) dispatch_queue_t decoding_queue;
@property(readonly) NSData *auBuffer;
@property(readonly) AudioConverterRef converter;

- (void)play:(id)sender;
- (NSData *)readInput:(int)bytes;
-(void)decodeNextFrame;



@end
