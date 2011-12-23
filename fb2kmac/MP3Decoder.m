//
//  MP3Decoder.m
//  fb2kmac
//
//  Created by Miles Wu on 22/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MP3Decoder.h"

@implementation MP3Decoder

-(id)init {
    self = [super init];
    
    int retval;
    retval = mpg123_init();
    if(retval != MPG123_OK) {
        NSLog(@"Error initializing mpg123");
    }
    mh = mpg123_new(NULL, NULL);
    mpg123_open_feed(mh);
    return self;
}

- (void *)getBuffer:(size_t *)size {
    off_t num;
    /*
    void *audio = malloc(1024);
    int size_loop;
    for(int i=0; i<1024;) {
        char *temp;
        mpg123_decode_frame(mh, &num, &temp, (size_t *)&size_loop);
        memcpy(audio+i, temp, size_loop);
        i+=size_loop;
    }
    *size = 1024;
    return(audio);*/
    void *audio;
    int retval = -1;
    retval = mpg123_decode_frame(mh, &num, (unsigned char **)&audio, size);
    
    long rate; int channels; int enc;
    //mpg123_getformat(mh, &rate, &channels, &enc);
    /*NSLog(@"New format: %li Hz, %i channels, encoding value %i\n", rate, channels, enc);

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
	}*/
    
    
    
    //NSLog(@"retval: %d", retval);
    if(retval != 0) {
        NSLog(@"%s", mpg123_strerror(mh));
        *size = 0;
        return NULL;
    }
    else {
        return(audio);
    }
}


-(void)feedData:(NSData *)data {
    NSLog(@"Feed data (%d)", [data length]);
    mpg123_feed(mh, [data bytes], [data length]);
}

@end
