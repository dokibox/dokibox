//
//  FLACDecoder.h
//  dokibox
//
//  Created by Miles Wu on 26/03/2012.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecoderProtocol.h"
#import "common.h"
#include <FLAC/stream_decoder.h>

FLAC__StreamDecoderReadStatus flac_readcallback(FLAC__StreamDecoder *decoder, FLAC__byte buffer[], size_t *bytes, void *client_data);
FLAC__StreamDecoderWriteStatus flac_writecallback(FLAC__StreamDecoder *decoder, FLAC__Frame *frame, FLAC__int32 *buffer[], void *client_data);
void flac_metadatacallback(FLAC__StreamDecoder *decoder, FLAC__StreamMetadata *metadata, void *client_Data);
FLAC__bool flac_eofcallback(FLAC__StreamDecoder *decoder, void *client_data);
FLAC__StreamDecoderLengthStatus flac_lengthcallback(FLAC__StreamDecoder *decoder, FLAC__uint64 *stream_length, void *client_data);
FLAC__StreamDecoderSeekStatus flac_seekcallback(FLAC__StreamDecoder *decoder, FLAC__uint64 absolute_byte_offset, void *client_data);
FLAC__StreamDecoderTellStatus flac_tellcallback(FLAC__StreamDecoder *decoder, FLAC__uint64 *absolute_byte_offset, void *client_data);
void flac_errorcallback(FLAC__StreamDecoder *decoder, FLAC__StreamDecoderErrorStatus status, void *client_data);

@interface FLACDecoder : NSObject<DecoderProtocol> {
    MusicController *musicController;
    FLAC__StreamDecoder *decoder;
    DecoderMetadata _metadata;
}

-(void)setMetadata:(FLAC__StreamMetadata *)metadata;
-(DecoderMetadata)metadata;

@property (retain) MusicController *musicController;

@end
