//
//  FLACDecoder.m
//  dokibox
//
//  Created by Miles Wu on 26/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FLACDecoder.h"
#import "MusicController.h"

FLAC__StreamDecoderReadStatus flac_readcallback(FLAC__StreamDecoder *decoder, FLAC__byte buffer[], size_t *bytes, void *client_data) {
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

FLAC__StreamDecoderWriteStatus flac_writecallback(FLAC__StreamDecoder *decoder, FLAC__Frame *frame, FLAC__int32 *buffer[], void *client_data) {
    FLACDecoder *flacDecoder = (__bridge FLACDecoder *)client_data;
    MusicController *mc = [flacDecoder musicController];
    //NSLog(@"writecallback %d", frame->header.blocksize*2*2);

    int i;
    //NSLog(@"how many frames in flac frame: %d", frame->header.blocksize);
    for(i=0; i < frame->header.blocksize; i++) {
        //FLAC__in
        FLAC__int32 l, r;
        l = buffer[0][i];
        r = buffer[1][i];
        int bps = [flacDecoder metadata].bitsPerSample/8;
        
        [[mc fifoBuffer] write:&l size:bps];
        [[mc fifoBuffer] write:&r size:bps];
    }

    return FLAC__STREAM_DECODER_WRITE_STATUS_CONTINUE;
}

void flac_metadatacallback(FLAC__StreamDecoder *decoder, FLAC__StreamMetadata *metadata, void *client_data) {
    FLACDecoder *flacDecoder = (__bridge FLACDecoder *)client_data;

    if(metadata->type == FLAC__METADATA_TYPE_STREAMINFO) {
        [flacDecoder setMetadata:metadata];
    }
}

FLAC__bool flac_eofcallback(FLAC__StreamDecoder *decoder, void *client_data) {
    return false;
}

FLAC__StreamDecoderLengthStatus flac_lengthcallback(FLAC__StreamDecoder *decoder, FLAC__uint64 *stream_length, void *client_data) {
    FLACDecoder *flacDecoder = (__bridge FLACDecoder *)client_data;
    MusicController *mc = [flacDecoder musicController];
    *stream_length = [mc inputLength];
    return FLAC__STREAM_DECODER_LENGTH_STATUS_OK;
}

FLAC__StreamDecoderSeekStatus flac_seekcallback(FLAC__StreamDecoder *decoder, FLAC__uint64 absolute_byte_offset, void *client_data) {
    FLACDecoder *flacDecoder = (__bridge FLACDecoder *)client_data;
    MusicController *mc = [flacDecoder musicController];
    [mc seekInput:absolute_byte_offset];
    return FLAC__STREAM_DECODER_SEEK_STATUS_OK;
}

FLAC__StreamDecoderTellStatus flac_tellcallback(FLAC__StreamDecoder *decoder, FLAC__uint64 *absolute_byte_offset, void *client_data) {
    FLACDecoder *flacDecoder = (__bridge FLACDecoder *)client_data;
    MusicController *mc = [flacDecoder musicController];
    *absolute_byte_offset = [mc inputPosition];
    return FLAC__STREAM_DECODER_TELL_STATUS_OK;
}


void flac_errorcallback(FLAC__StreamDecoder *decoder, FLAC__StreamDecoderErrorStatus status, void *client_data) {

}

@implementation FLACDecoder

@synthesize musicController;

-(id)initWithMusicController:(MusicController *)mc {
    self = [super init];

    musicController = mc;

    decoder = FLAC__stream_decoder_new();
    FLAC__StreamDecoderInitStatus retval;

    retval = FLAC__stream_decoder_init_stream(
        decoder,
        (FLAC__StreamDecoderReadCallback)flac_readcallback,
        (FLAC__StreamDecoderSeekCallback)flac_seekcallback,
        (FLAC__StreamDecoderTellCallback)flac_tellcallback,
        (FLAC__StreamDecoderLengthCallback)flac_lengthcallback,
        (FLAC__StreamDecoderEofCallback)flac_eofcallback,
        (FLAC__StreamDecoderWriteCallback)flac_writecallback,
        (FLAC__StreamDecoderMetadataCallback)flac_metadatacallback,
        (FLAC__StreamDecoderErrorCallback)flac_errorcallback,
        (__bridge void *)self);

    NSLog(@"init: %d", retval);

    return self;
}

-(void)dealloc {
    NSLog(@"Deallocing flac decoder");
    FLAC__stream_decoder_finish(decoder);
    FLAC__stream_decoder_delete(decoder);
}

-(DecoderMetadata)decodeMetadata {
    FLAC__stream_decoder_process_until_end_of_metadata(decoder);
    return _metadata;
}

-(DecoderMetadata)metadata
{
    return _metadata;
}

-(void)setMetadata:(FLAC__StreamMetadata *)metadata
{
    unsigned long long total_samples = metadata->data.stream_info.total_samples;
    int sample_rate = metadata->data.stream_info.sample_rate;
    int channels = metadata->data.stream_info.channels;
    int bps = metadata->data.stream_info.bits_per_sample;

    _metadata.totalSamples = total_samples;
    _metadata.sampleRate = sample_rate;
    _metadata.numberOfChannels = channels;
    _metadata.bitsPerSample = bps;
}

-(DecodeStatus)decodeNextFrame {
    FLAC__bool retval = FLAC__stream_decoder_process_single(decoder);
    if(retval != true) {
        NSLog(@"hi");
    }
    return DecoderSuccess;
}

-(void)seekToFrame:(unsigned long long)frame {
    FLAC__bool retval = FLAC__stream_decoder_seek_absolute(decoder, frame);
    if(retval != true) {
        NSLog(@"Seek failed");
    }
}


@end
