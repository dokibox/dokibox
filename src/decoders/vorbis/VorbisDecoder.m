//
//  VorbisDecoder.m
//  dokibox
//
//  Created by Miles Wu on 27/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
    //NSLog(@"vorbis readcallback %d", sizeread);

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

-(id)initWithMusicController:(MusicController *)mc {
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
        NSLog(@"error initalizing vorbis decoder (err %d)", retval);
    }
    return self;
}

-(void)dealloc {
    NSLog(@"Deallocing vorbis decoder");
    ov_clear(&decoder);
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
    int sizetoread = 4096;
    long sizeread;
    int bitstreamno;
    char *audio = malloc(sizetoread);

    sizeread = ov_read(&decoder, audio, sizetoread, 0, 2, 1, &bitstreamno);

    if(sizeread > 0) {
        [[musicController fifoBuffer] write:audio size:(int)sizeread];
    }

    free(audio);

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
        NSLog(@"Seeking failed, error=%d", retval);
    }
}


@end
