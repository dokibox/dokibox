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
};

@interface MusicController : NSObject {
    PlaylistController  *currentPlaylistController;
    
    MP3Decoder *mp3Decoder;
    id<DecoderProtocol> currentDecoder;
    
    ComponentInstance outputUnit;
    struct hilarity h;
    void *buffer;
}

- (void)play:(id)sender;
- (void *)getBuffer:(size_t *)size;

@end
