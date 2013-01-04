//
//  MusicController.h
//  fb2kmac
//
//  Created by Miles Wu on 22/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "common.h"
#import "DecoderProtocol.h"
#import "FIFOBuffer.h"
#include <AudioToolbox/AudioToolbox.h>

typedef enum {
    MusicControllerDecoderIdle,
    MusicControllerDecodingSong,
    MusicControllerSeekingSong,
    MusicControllerDecodedSong
} MusicControllerDecoderStatus;

typedef enum {
    MusicControllerStopped,
    MusicControllerPaused,
    MusicControllerPlaying
} MusicControllerStatus;

@interface MusicController : NSObject {
    id<DecoderProtocol> currentDecoder;
    
    AUGraph _outputGraph;
    AudioUnit _outputUnit;
    AudioUnit _mixerUnit;
    AudioConverterRef converter;
    AudioStreamBasicDescription _inFormat;

    
    MusicControllerDecoderStatus _decoderStatus;
    MusicControllerStatus _status;
    PlaylistTrack *_currentTrack;
    int _elapsedFrames;
    int _totalFrames;
    float _prevElapsedTimeSent;

    
    FIFOBuffer *fifoBuffer;
    NSData *auBuffer;
    
    NSFileHandle *fileHandle;
}

@property(readonly) FIFOBuffer *fifoBuffer;
@property(readonly) dispatch_queue_t decoding_queue;
@property(readonly) NSData *auBuffer;
@property(readonly) AudioConverterRef converter;
@property(assign) MusicControllerDecoderStatus decoderStatus;
@property(assign) MusicControllerStatus status;
@property(readonly) AudioStreamBasicDescription inFormat;
@property(assign,nonatomic) int elapsedFrames;
@property() float volume;


+ (BOOL)isSupportedAudioFile:(NSString *)filename;
- (void)receivedPlayTrackNotification:(NSNotification *)notification;
- (void)receivedSeekTrackNotification:(NSNotification *)notification;
- (NSData *)readInput:(int)bytes;
- (void)seekInput:(unsigned long long)offset;
- (void)seekInputToEnd;
- (unsigned long long)inputPosition;
- (unsigned long long)inputLength;
- (id<DecoderProtocol>)decoderForFile:(NSString *)filename;
- (void)fillBuffer;
- (void)trackEnded;
- (void)pause;
- (void)unpause;
- (void)stop;


-(PlaylistTrack*)getCurrentTrack;


@end
