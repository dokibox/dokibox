//
//  MP3Decoder.m
//  dokibox
//
//  Created by Miles Wu on 22/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MP3Decoder.h"
#import "MusicController.h"

@implementation MP3Decoder
@synthesize musicController;

-(id)initWithMusicController:(MusicController *)mc {
    self = [super init];

    musicController = mc;

    int retval;
    retval = mpg123_init();
    if(retval != MPG123_OK) {
        NSLog(@"Error initializing mpg123");
    }
    mh = mpg123_new(NULL, NULL);
    mpg123_open_feed(mh);
    return self;
}


-(DecoderMetadata)decodeMetadata {
    [self decodeNextFrame];
    _metadata.totalSamples = (int)mpg123_length(mh);
    return _metadata;
}

-(DecodeStatus)decodeNextFrame {
    off_t frame;
    unsigned char *audio;
    size_t bytes;
    int retval = mpg123_decode_frame(mh, &frame, &audio, &bytes);

    if(retval == MPG123_NEED_MORE) {
        int readsize = 10000;
        NSData *data = [musicController readInput:readsize];
        if([data length] != 0) {
            mpg123_feed(mh, [data bytes], [data length]);
            retval = [self decodeNextFrame];
        }
        else {
            return DecoderEOF;
        }
    }

    if(retval == MPG123_NEW_FORMAT) {
        long rate; int channels; int enc;
        mpg123_getformat(mh, &rate, &channels, &enc);

        _metadata.sampleRate = (int)rate;
        _metadata.numberOfChannels = channels;

        switch(enc)
        {
            case MPG123_ENC_SIGNED_16:
                _metadata.bitsPerSample = 16;
                _metadata.format = DecoderFormatSigned;
                break;
            case MPG123_ENC_SIGNED_8:
                _metadata.bitsPerSample = 8;
                _metadata.format = DecoderFormatSigned;
                break;
            case MPG123_ENC_UNSIGNED_8:
                _metadata.bitsPerSample = 8;
                _metadata.format = DecoderFormatUnsigned;
                break;
            case MPG123_ENC_SIGNED_32:
                _metadata.bitsPerSample = 32;
                _metadata.format = DecoderFormatSigned;
                break;
            case MPG123_ENC_FLOAT_32:
                _metadata.bitsPerSample = 32;
                _metadata.format = DecoderFormatFloat;
                break;
        }
    }

    if(bytes > 0) {
        [[musicController fifoBuffer] write:audio size:bytes];
    }
    return DecoderSuccess;
}

-(void)seekToFrame:(unsigned long long)frame {
    off_t ioinput_offset;
    int retval = mpg123_feedseek(mh, frame, SEEK_SET, &ioinput_offset);
    if(retval < 0) {
        NSLog(@"Seek failed with error=%d", retval);
        return;
    }
    [musicController seekInput:ioinput_offset];
}

@end
