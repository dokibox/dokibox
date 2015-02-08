//
//  VorbisDecoder.m
//  dokibox
//
//  Created by Miles Wu on 27/03/2012.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "VorbisDecoder.h"
#import "MusicController.h"

size_t vorbis_readcallback(void *ptr, size_t size, size_t nmemb, void *datasource) {
    VorbisDecoder *vorbisDecoder = (__bridge VorbisDecoder *)datasource;
    MusicController *mc = [vorbisDecoder musicController];

    NSData *data = [mc readInput:(unsigned long long)size*nmemb];
    int sizeread = (int)[data length];
    if(sizeread == 0) { //EOF maybe?
        return 0;
    }

    memcpy(ptr, [data bytes], sizeread);
    //DDLogVerbose(@"vorbis readcallback %d", sizeread);

    return sizeread;
}

int vorbis_seekcallback(void *datasource, ogg_int64_t offset, int whence) {
    VorbisDecoder *vorbisDecoder = (__bridge VorbisDecoder *)datasource;
    MusicController *mc = [vorbisDecoder musicController];

    unsigned long long off;
    if(whence == SEEK_SET) {
        off = offset;
    } else if(whence == SEEK_CUR) {
        off = offset + [mc inputPosition];
    }
    else { //SEEK_END
        [mc seekInputToEnd];
        off = offset + [mc inputPosition];
    }
    [mc seekInput:off];

    return 0;
}

long vorbis_tellcallback(void *datasource) {
    VorbisDecoder *vorbisDecoder = (__bridge VorbisDecoder *)datasource;
    MusicController *mc = [vorbisDecoder musicController];
    return [mc inputPosition];
}

@implementation VorbisDecoder

@synthesize musicController;

-(id)initWithMusicController:(MusicController *)mc andExtension:(NSString *)extension {
    self = [super init];
    int retval;

    musicController = mc;

    ov_callbacks callbacks;
    callbacks.seek_func = vorbis_seekcallback;
    callbacks.close_func = NULL;
    callbacks.tell_func = vorbis_tellcallback;
    callbacks.read_func = vorbis_readcallback;

    retval = ov_open_callbacks((__bridge void *)self, &decoder, NULL, 0, callbacks);
    if(retval != 0) {
        DDLogError(@"error initalizing vorbis decoder (err %d)", retval);
    }
    
    // Decode data setup
    [self decodeMetadata];
    _decodeDataSize = _metadata.bitsPerSample/8*_metadata.numberOfChannels*_metadata.sampleRate;
    _decodeData = malloc(_decodeDataSize);
    
    return self;
}

-(void)dealloc {
    ov_clear(&decoder);
    free(_decodeData);
}

-(DecoderMetadata)decodeMetadata {
    vorbis_info *vi = ov_info(&decoder, -1);
    if(vi != NULL) {
        _metadata.numberOfChannels = vi->channels;
        _metadata.sampleRate = (int)vi->rate;
        _metadata.totalSamples = ov_pcm_total(&decoder, -1);
        _metadata.bitsPerSample = 16;
    }
    return _metadata;
}

-(DecodeStatus)decodeNextFrame {
    long sizeread;
    int bitstreamno;

    sizeread = ov_read(&decoder, _decodeData, _decodeDataSize, 0, 2, 1, &bitstreamno);

    if(sizeread > 0) {
        [[musicController fifoBuffer] write:_decodeData size:(int)sizeread];
    }
    
    if(sizeread == 0) {
        return DecoderEOF;
    }
    else {
        return DecoderSuccess;
    }
}

-(void)seekToFrame:(unsigned long long)frame
{
    int retval = ov_pcm_seek_lap(&decoder, frame);
    if(retval) {
        DDLogError(@"Seeking failed, error=%d", retval);
    }
}


@end
