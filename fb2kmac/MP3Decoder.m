//
//  MP3Decoder.m
//  fb2kmac
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


-(void)decodeMetadata {
    [self decodeNextFrame];
}

-(void)decodeNextFrame {
    off_t frame;
    unsigned char *audio;
    size_t bytes;
    int retval = mpg123_decode_frame(mh, &frame, &audio, &bytes);
    
    if(retval == MPG123_NEED_MORE) {
        int readsize = 10000;
        NSData *data = [musicController readInput:readsize];
        mpg123_feed(mh, [data bytes], [data length]);
        [self decodeNextFrame];
    }
    
    if(retval == MPG123_NEW_FORMAT) {
        long rate; int channels; int enc;
        mpg123_getformat(mh, &rate, &channels, &enc);
        NSLog(@"New format: %li Hz, %i channels, encoding value %i\n", rate, channels, enc);
        
        switch(enc)
        {
            case MPG123_ENC_SIGNED_16:
                NSLog(@"enc16");
                break;
            case MPG123_ENC_SIGNED_8:
                NSLog(@"enc8");
                break;
            case MPG123_ENC_UNSIGNED_8:
                NSLog(@"encu8");
                break;
            case MPG123_ENC_SIGNED_32:
                NSLog(@"enc32");
                break;
            case MPG123_ENC_FLOAT_32:
                NSLog(@"encf32");
                break;
        }
    }
    
    if(bytes > 0) {
        [[musicController fifoBuffer] write:audio size:bytes];
        
    }
}
@end
