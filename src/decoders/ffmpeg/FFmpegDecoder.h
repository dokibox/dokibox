//
//  FFmpegDecoder.h
//  dokibox
//
//  Created by Miles Wu on 28/06/2015.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecoderProtocol.h"
#import "common.h"
#import "libavcodec/avcodec.h"

typedef struct AVIOContext AVIOContext;
typedef struct AVFormatContext AVFormatContext;

@interface FFmpegDecoder : NSObject<DecoderProtocol> {
    MusicController *_musicController;
    DecoderMetadata _metadata;

    AVIOContext *_avioContext;
    AVFormatContext *_avFormatContext;
    AVCodecContext *_avCodecContext;
    int _streamIndex;
    AVPacket _avPacket;
    AVFrame *_avFrame;
    BOOL _needsInterleaving;

    BOOL _firstFrameDecodeInProgress;
    void *_firstFrameDecodedData;
    int _firstFrameDecodedDataSize;
}

@property (retain) MusicController *musicController;

@end
