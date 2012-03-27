//
//  FLACDecoder.h
//  fb2kmac
//
//  Created by Miles Wu on 26/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecoderProtocol.h"
#import "common.h"
#include <FLAC/stream_decoder.h>

FLAC__StreamDecoderReadStatus readcallback(FLAC__StreamDecoder *decoder, FLAC__byte buffer[], size_t *bytes, void *client_data);
FLAC__StreamDecoderWriteStatus writecallback(FLAC__StreamDecoder *decoder, FLAC__Frame *frame, FLAC__int32 *buffer[], void *client_data);
void metadatacallback(FLAC__StreamDecoder *decoder, FLAC__StreamMetadata *metadata, void *client_Data);
FLAC__bool eofcallback(FLAC__StreamDecoder *decoder, void *client_data);
FLAC__StreamDecoderLengthStatus lengthcallback(FLAC__StreamDecoder *decoder, FLAC__uint64 *stream_length, void *client_data);
void errorcallback(FLAC__StreamDecoder *decoder, FLAC__StreamDecoderErrorStatus status, void *client_data);

@interface FLACDecoder : NSObject<DecoderProtocol> {
    MusicController *musicController;
    FLAC__StreamDecoder *decoder;
}

@property (retain) MusicController *musicController;

-(void)decodeMetadata;
-(void)decodeNextFrame;


@end
