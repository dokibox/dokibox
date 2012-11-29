//
//  VorbisDecoder.m
//  fb2kmac
//
//  Created by Miles Wu on 27/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VorbisDecoder.h"
#import "MusicController.h"

size_t vorbis_readcallback(void *ptr, size_t size, size_t nmemb, void *datasource) {
    VorbisDecoder *vorbisDecoder = (__bridge VorbisDecoder *)datasource;
    MusicController *mc = [vorbisDecoder musicController];
    
    NSData *data = [mc readInput:(int)size*nmemb];
    int sizeread = (int)[data length];
    if(sizeread == 0) { //EOF maybe?
        return 0;
    }
    
    memcpy(ptr, [data bytes], sizeread);
    //NSLog(@"vorbis readcallback %d", sizeread);

    return sizeread;
}

@implementation VorbisDecoder

@synthesize musicController;

-(id)initWithMusicController:(MusicController *)mc {
    self = [super init];
    int retval;
    
    musicController = mc;
    
    ov_callbacks callbacks;
    callbacks.seek_func = NULL;
    callbacks.close_func = NULL;
    callbacks.tell_func = NULL;
    callbacks.read_func = vorbis_readcallback;
    
    retval = ov_open_callbacks((__bridge void *)self, &decoder, NULL, 0, callbacks);
    if(retval != 0) {
        NSLog(@"error initalizing vorbis decoder (err %d)", retval);
    }
    return self;
}

-(DecoderMetadata)decodeMetadata {
    vorbis_info *vi = ov_info(&decoder, -1);
    if(vi != NULL) {
        _metadata.numberOfChannels = vi->channels;
        _metadata.sampleRate = vi->rate;
        _metadata.totalSamples = ov_pcm_total(&decoder, -1);
    }
    return _metadata;
}

-(DecodeStatus)decodeNextFrame {
    int sizetoread = 4096;
    int sizeread;
    int bitstreamno;
    char *audio = malloc(sizetoread);

    sizeread = ov_read(&decoder, audio, sizetoread, 0, 2, 1, &bitstreamno);
    
    if(sizeread > 0) {
        [[musicController fifoBuffer] write:audio size:sizeread];
    }

    free(audio);
    
    if(sizeread == 0) {
        return DecoderEOF;
    }
    else {
        return DecoderSuccess;
    }
}


@end
