//
//  VorbisDecoder.h
//  fb2kmac
//
//  Created by Miles Wu on 27/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecoderProtocol.h"
#import "common.h"
#include <vorbis/codec.h>
#include <vorbis/vorbisfile.h>

size_t vorbis_readcallback(void *ptr, size_t size, size_t nmemb, void *datasource);

@interface VorbisDecoder : NSObject<DecoderProtocol> {
    MusicController *musicController;

    OggVorbis_File decoder; 
}

@property (retain) MusicController *musicController;

-(id)initWithMusicController:(MusicController *)mc;
-(void)decodeMetadata;
-(void)decodeNextFrame;

@end
