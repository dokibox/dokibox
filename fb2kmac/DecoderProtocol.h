//
//  DecoderProtocol.h
//  fb2kmac
//
//  Created by Miles Wu on 22/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "common.h"

typedef enum {
    DecoderSuccess,
    DecoderEOF
} DecodeStatus;

typedef enum {
    DecoderFormatUnsigned,
    DecoderFormatSigned,
    DecoderFormatFloat
} DecoderFormat;

typedef struct  {
    int sampleRate;
    int bitsPerSample;
    int totalSamples;
    int numberOfChannels;
    DecoderFormat format;
} DecoderMetadata;

@protocol DecoderProtocol <NSObject>

@property (retain) MusicController *musicController;

-(id)initWithMusicController:(MusicController *)mc;
-(DecoderMetadata)decodeMetadata;
-(DecodeStatus)decodeNextFrame;

@end
