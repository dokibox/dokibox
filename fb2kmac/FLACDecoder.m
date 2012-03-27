//
//  FLACDecoder.m
//  fb2kmac
//
//  Created by Miles Wu on 26/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FLACDecoder.h"
#import "MusicController.h"

FLAC__StreamDecoderReadStatus readcallback(FLAC__StreamDecoder *decoder, FLAC__byte buffer[], size_t *bytes, void *client_data) {
    FLACDecoder *flacDecoder = (__bridge FLACDecoder *)client_data;
    MusicController *mc = [flacDecoder musicController];
    
    NSData *data = [mc readInput:(int)*bytes];
    int size = (int)[data length];
    *bytes = size;
    if(size == 0) { //EOF maybe?
        return FLAC__STREAM_DECODER_READ_STATUS_END_OF_STREAM;
    }
    
    memcpy(buffer, [data bytes], size);
    return FLAC__STREAM_DECODER_READ_STATUS_CONTINUE;
}

FLAC__StreamDecoderWriteStatus writecallback(FLAC__StreamDecoder *decoder, FLAC__Frame *frame, FLAC__int32 *buffer[], void *client_data) {
    FLACDecoder *flacDecoder = (__bridge FLACDecoder *)client_data;
    MusicController *mc = [flacDecoder musicController];
    //NSLog(@"writecallback %d", frame->header.blocksize*2*2);
    
    int i;
    for(i=0; i < frame->header.blocksize; i++) {
        FLAC__uint16 l, r;
        l = buffer[0][i];
        r = buffer[1][i];
        [[mc fifoBuffer] write:&l size:sizeof(FLAC__uint16)];
        [[mc fifoBuffer] write:&r size:sizeof(FLAC__uint16)];
    }
    
    return FLAC__STREAM_DECODER_WRITE_STATUS_CONTINUE;
}

void metadatacallback(FLAC__StreamDecoder *decoder, FLAC__StreamMetadata *metadata, void *client_Data) {
    if(metadata->type == FLAC__METADATA_TYPE_STREAMINFO) {
        int total_samples = metadata->data.stream_info.total_samples;
        int sample_rate = metadata->data.stream_info.sample_rate;
        int channels = metadata->data.stream_info.channels;
        int bps = metadata->data.stream_info.bits_per_sample;
        NSLog(@"%d samples, %d Hz, %d channels, %d bps", total_samples, sample_rate, channels, bps);
    }
}

FLAC__bool eofcallback(FLAC__StreamDecoder *decoder, void *client_data) {
    return false;
}

FLAC__StreamDecoderLengthStatus lengthcallback(FLAC__StreamDecoder *decoder, FLAC__uint64 *stream_length, void *client_data) {
    return FLAC__STREAM_DECODER_LENGTH_STATUS_UNSUPPORTED;
}

void errorcallback(FLAC__StreamDecoder *decoder, FLAC__StreamDecoderErrorStatus status, void *client_data) {
    
}

@implementation FLACDecoder

@synthesize musicController;

-(id)init {
    self = [super init];
    
    decoder = FLAC__stream_decoder_new();
    FLAC__StreamDecoderInitStatus retval;
    
    retval = FLAC__stream_decoder_init_stream(
        decoder,
        (FLAC__StreamDecoderReadCallback)readcallback,
        (FLAC__StreamDecoderSeekCallback)NULL,
        (FLAC__StreamDecoderTellCallback)NULL,
        (FLAC__StreamDecoderLengthCallback)lengthcallback,
        (FLAC__StreamDecoderEofCallback)eofcallback,
        (FLAC__StreamDecoderWriteCallback)writecallback,
        (FLAC__StreamDecoderMetadataCallback)metadatacallback,
        (FLAC__StreamDecoderErrorCallback)errorcallback,
        (__bridge void *)self);
    
    NSLog(@"init: %d", retval);
    
    return self;
}

-(void)decodeMetadata {
    FLAC__stream_decoder_process_until_end_of_metadata(decoder);
}

-(void)decodeNextFrame {
    FLAC__stream_decoder_process_single(decoder);
}


@end
