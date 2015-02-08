//
//  DecoderProtocol.h
//  dokibox
//
//  Created by Miles Wu on 22/11/2011.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
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
    unsigned long long totalSamples;
    int numberOfChannels;
    DecoderFormat format;
} DecoderMetadata;

@protocol DecoderProtocol <NSObject>

@property (retain) MusicController *musicController;

-(id)initWithMusicController:(MusicController *)mc andExtension:(NSString *)extension;
-(DecoderMetadata)decodeMetadata;
-(DecodeStatus)decodeNextFrame;
-(void)seekToFrame:(unsigned long long)frame;

@end
