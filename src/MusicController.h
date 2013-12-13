//
//  MusicController.h
//  dokibox
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
    AUNode _mixerNode, _outputNode;
    AudioConverterRef converter;
    AudioStreamBasicDescription _inFormat;
    float _volume;


    MusicControllerDecoderStatus _decoderStatus;
    MusicControllerStatus _status;
    PlaylistTrack *_currentTrack;
    unsigned long long _elapsedFrames;
    unsigned long long _totalFrames;
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
@property(assign,nonatomic) unsigned long long elapsedFrames;
@property() float volume;


+ (BOOL)isSupportedAudioFile:(NSString *)filename;
- (void)receivedPlayTrackNotification:(NSNotification *)notification;

- (void)createOrReconfigureAudioGraph:(DecoderMetadata)decoderMetadata;
- (void)createAudioGraph;
- (void)configureAudioGraph:(DecoderMetadata)decoderMetadata;

- (void)receivedSeekTrackNotification:(NSNotification *)notification;
- (NSData *)readInput:(unsigned long long)bytes;
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
