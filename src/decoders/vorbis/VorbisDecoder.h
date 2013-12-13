//
//  VorbisDecoder.h
//  dokibox
//
//  Created by Miles Wu on 27/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define OV_EXCLUDE_STATIC_CALLBACKS

#import <Foundation/Foundation.h>
#import "DecoderProtocol.h"
#import "common.h"
#include <vorbis/codec.h>
#include <vorbis/vorbisfile.h>

size_t vorbis_readcallback(void *ptr, size_t size, size_t nmemb, void *datasource);
int vorbis_seekcallback(void *datasource, ogg_int64_t offset, int whence);
long vorbis_tellcallback(void *datasource);

@interface VorbisDecoder : NSObject<DecoderProtocol> {
    MusicController *musicController;

    OggVorbis_File decoder;
    DecoderMetadata _metadata;
}

@property (retain) MusicController *musicController;

@end
