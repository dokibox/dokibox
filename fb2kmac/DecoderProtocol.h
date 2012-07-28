//
//  DecoderProtocol.h
//  fb2kmac
//
//  Created by Miles Wu on 22/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "common.h"

typedef enum {
    DecoderSuccess,
    DecoderEOF
} DecodeStatus;

@protocol DecoderProtocol <NSObject>

@property (retain) MusicController *musicController;

-(id)initWithMusicController:(MusicController *)mc;
-(void)decodeMetadata;
-(DecodeStatus)decodeNextFrame;

@end
