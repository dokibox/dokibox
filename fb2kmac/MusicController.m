//
//  MusicController.m
//  fb2kmac
//
//  Created by Miles Wu on 22/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MusicController.h"
#import "PlaylistTrack.h"
#import "plugins/PluginManager.h"

#import <AudioUnit/AudioUnit.h>

static OSStatus playProc(AudioConverterRef inAudioConverter,
						 UInt32 *ioNumberDataPackets,
                         AudioBufferList *outOutputData,
                         AudioStreamPacketDescription **outDataPacketDescription,
                         void* inClientData) {
    //NSLog(@"Number of buffers %d", outOutputData->mNumberBuffers);
    MusicController *mc = (__bridge MusicController *)inClientData;
    
    int size = *ioNumberDataPackets * [mc inFormat].mBytesPerPacket;
    //NSLog(@"size: %d", size);
    
    [[mc fifoBuffer] read:(void *)[[mc auBuffer] bytes] size:&size];
    
    [mc setElapsedFrames:[mc elapsedFrames] + size/[mc inFormat].mBytesPerFrame];

    outOutputData->mNumberBuffers = 1;
    outOutputData->mBuffers[0].mDataByteSize = size;
    outOutputData->mBuffers[0].mData = (void *)[[mc auBuffer] bytes];

    if(size == 0) {
        [mc trackEnded];
    }
    
    dispatch_async([mc decoding_queue], ^{
        [mc fillBuffer];
    });
    
    return(noErr);
    
}

static OSStatus renderProc(void *inRefCon, AudioUnitRenderActionFlags *inActionFlags,
                            const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber,
                            UInt32 inNumFrames, AudioBufferList *ioData)
{
    @autoreleasepool {
        MusicController *mc = (__bridge MusicController *)inRefCon;
        AudioStreamPacketDescription* outPacketDescription = NULL;
        
        OSStatus err = AudioConverterFillComplexBuffer([mc converter], playProc, inRefCon, &inNumFrames, ioData, outPacketDescription);
        return(err);
    }
}



@implementation MusicController

@synthesize decoding_queue;
@synthesize fifoBuffer;
@synthesize auBuffer;
@synthesize converter;
@synthesize decoderStatus = _decoderStatus;
@synthesize status = _status;
@synthesize inFormat = _inFormat;
@synthesize elapsedFrames = _elapsedFrames;

+ (BOOL)isSupportedAudioFile:(NSString *)filename
{
    NSString *ext = [[filename pathExtension] lowercaseString];
    if([ext compare:@"flac"] == NSOrderedSame) {
        return YES;
    }
    else if([ext compare:@"mp3"] == NSOrderedSame) {
        return YES;
    }
    else if([ext compare:@"ogg"] == NSOrderedSame) {
        return YES;
    }
    else {
        return NO;
    }
}

- (id)init {
    self = [super init];
    _decoderStatus = MusicControllerDecoderIdle;
    _status = MusicControllerStopped;

    int err;
    UInt32 size;
    Boolean outWritable;
    
    AudioStreamBasicDescription outFormat;
    AURenderCallbackStruct renderCallback;
    
    // Create Graph
    err = NewAUGraph(&_outputGraph);
    if(err) {
        NSLog(@"NewAUGraph failed");
    }
    
    // Node descriptions
    AudioComponentDescription mixerDesc;
	mixerDesc.componentType = kAudioUnitType_Mixer;
    mixerDesc.componentSubType = kAudioUnitSubType_MultiChannelMixer;
	mixerDesc.componentFlags = 0;
	mixerDesc.componentFlagsMask = 0;
	mixerDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    AudioComponentDescription outputDesc;
    outputDesc.componentType = kAudioUnitType_Output;
    outputDesc.componentSubType = kAudioUnitSubType_DefaultOutput;
    outputDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    outputDesc.componentFlags = 0;
    outputDesc.componentFlagsMask = 0;
    
    // Add nodes
    AUNode outputNode, mixerNode;
    err = AUGraphAddNode(_outputGraph, &outputDesc, &outputNode);
    if(err) {
        NSLog(@"AUGraphAddNode failed (output)");
    }


    err = AUGraphAddNode(_outputGraph, &mixerDesc, &mixerNode);
    if(err) {
        NSLog(@"AUGraphAddNode failed (mixer)");
    }
    
    // Connect nodes together
    err = AUGraphConnectNodeInput(_outputGraph, mixerNode, 0, outputNode, 0);
    if(err) {
        NSLog(@"AUGraphConnectNodeInput failed (mixer->output)");
    }
    
    // Open and fetch the units
    err = AUGraphOpen(_outputGraph);
    if(err) {
        NSLog(@"AUGraphOpen failed");
    }
    
    err = AUGraphNodeInfo(_outputGraph, outputNode, NULL, &_outputUnit);
    if(err) {
        NSLog(@"AUGraphNodeInfo failed (output)");
    }
    
    err = AUGraphNodeInfo(_outputGraph, mixerNode, NULL, &_mixerUnit);
    if(err) {
        NSLog(@"AUGraphNodeInfo failed (mixer)");
    }
    
    // Setup mixer
    UInt32 numbuses = 1;
    err = AudioUnitSetProperty(_mixerUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numbuses, sizeof(numbuses));
    if(err) {
        NSLog(@"AudioUnitSetProperty(kAudioUnitProperty_ElementCount:mixerUnit input) failed");
    }
    
    err = AudioUnitSetParameter(_mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, 0, 1.0, 0);
    if(err) {
        NSLog(@"AudioUnitSetProperty(kMultiChannelMixerParam_Volume:mixerUnit input) failed");
    }
    err = AudioUnitSetParameter(_mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, 1.0, 0);
    if(err) {
        NSLog(@"AudioUnitSetProperty(kMultiChannelMixerParam_Volume:mixerUnit output) failed");
    }
    
    // Setup audio format chain
	err = AudioUnitGetProperty(_mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &outFormat, &size);
    if(err) {
		NSLog(@"AudioUnitGetProperty(kAudioUnitProperty_StreamFormat:mixerUnit input) failed");
	}
    
    outFormat.mSampleRate = 48000;
    
    err = AudioUnitSetProperty(_mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &outFormat, sizeof(AudioStreamBasicDescription));
    if(err) {
		NSLog(@"AudioUnitSetProperty(kAudioUnitProperty_StreamFormat:mixerUnit input) failed");
	}
    
    err = AudioUnitGetProperty(_mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &outFormat, &size); //Ensures we have correct format, just in case it didnt set properly
    if(err) {
		NSLog(@"AudioUnitGetProperty(kAudioUnitProperty_StreamFormat:mixerUnit input) failed");
	}
    
    err = AudioUnitSetProperty(_mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &outFormat, sizeof(AudioStreamBasicDescription));
    if(err) {
		NSLog(@"AudioUnitSetProperty(kAudioUnitProperty_StreamFormat:mixerUnit input) failed");
	}
    

    
    NSLog(@"%f\n", outFormat.mSampleRate);
    NSLog(@"%d\n", outFormat.mFramesPerPacket);
    
    // Set up converter
    _inFormat.mSampleRate = 44100;
    _inFormat.mChannelsPerFrame = 2;
    _inFormat.mFormatID = kAudioFormatLinearPCM;
    _inFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked;
    _inFormat.mFormatFlags |= kLinearPCMFormatFlagIsSignedInteger;
    int bps = 2;
    _inFormat.mBitsPerChannel = bps << 3;
	_inFormat.mBytesPerPacket = bps*_inFormat.mChannelsPerFrame;
	_inFormat.mFramesPerPacket = 1;
	_inFormat.mBytesPerFrame = bps*_inFormat.mChannelsPerFrame;
    
    err = AudioConverterNew(&_inFormat, &outFormat, &converter);
    if(err) {
        NSLog(@"AudioConverterNew failed");
    }
    
    // Set input callbacks to mixer
    memset(&renderCallback, 0, sizeof(AURenderCallbackStruct));
    renderCallback.inputProc = renderProc;
    renderCallback.inputProcRefCon = (__bridge void *)self;
    
    fifoBuffer = [[FIFOBuffer alloc] initWithSize:200000];
    int auBufferSize = 4096*2;
    void *auBufferContents = malloc(auBufferSize);
    auBuffer = [NSData dataWithBytesNoCopy:auBufferContents length:auBufferSize freeWhenDone:YES];
    
    err = AUGraphSetNodeInputCallback(_outputGraph, mixerNode, 0, &renderCallback);
    
    err = AUGraphInitialize(_outputGraph);
    if(err) {
        NSLog(@"AUGraphInitialize failed");
    }

    decoding_queue = dispatch_queue_create("fb2k.decoding",NULL);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPlayTrackNotification:) name:@"playTrack" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSeekTrackNotification:) name:@"seekTrack" object:nil];

    return self;
}

- (id<DecoderProtocol>)decoderForFile:(NSString *)filename
{
    NSString *ext = [[filename pathExtension] lowercaseString];
    
    PluginManager *pluginManager = [PluginManager sharedInstance];
    Class decoderClass = [pluginManager decoderClassForExtension:ext];
    
    return [((id<DecoderProtocol>)[decoderClass alloc]) initWithMusicController:self];
}

- (void)pause
{
    if([self status] == MusicControllerPlaying) {
        [self setStatus:MusicControllerPaused];
        AUGraphStop(_outputGraph);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pausedPlayback" object:_currentTrack];
    }
}

- (void)unpause
{
    if([self status] == MusicControllerPaused) {
        [self setStatus:MusicControllerPlaying];
        AUGraphStart(_outputGraph);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"unpausedPlayback" object:_currentTrack];
    }
}

- (void)receivedPlayTrackNotification:(NSNotification *)notification
{
    if([self decoderStatus] != MusicControllerDecoderIdle) { //still playing something at the moment
        AUGraphStop(_outputGraph);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"trackEnded" object:nil];
    }
    
    _currentTrack = [notification object];
    NSString *fp = [_currentTrack filename];
    NSLog(@"%@", fp);

    fileHandle = [NSFileHandle fileHandleForReadingAtPath:fp];
    if(fileHandle == nil) {
        NSLog(@"File does not exist at %@", fp);
        return;
    }
    
    [self setDecoderStatus:MusicControllerDecodingSong];
    [self setStatus:MusicControllerPlaying];
    
    currentDecoder = [self decoderForFile:fp];
    DecoderMetadata metadata = [currentDecoder decodeMetadata];
    _totalFrames = metadata.totalSamples;
    NSLog(@"total frames: %d", metadata.totalSamples);
    
    _prevElapsedTimeSent = 0;
    [self setElapsedFrames:0];
    [fifoBuffer reset];
    [self fillBuffer];
        
    AUGraphStart(_outputGraph);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startedPlayback" object:_currentTrack];
    CAShow(_outputGraph);

};

- (void)receivedSeekTrackNotification:(NSNotification *)notification
{
    if([self status] == MusicControllerStopped) return;
    
    float seekto = [(NSNumber *)[notification object] floatValue];
    
    int sampleno = seekto * _totalFrames;
    NSLog(@"Seeking to %f percent", seekto);
    
    [self setDecoderStatus:MusicControllerSeekingSong];
    AUGraphStop(_outputGraph);
    [currentDecoder seekToFrame:sampleno];
    [fifoBuffer reset];
    [self setDecoderStatus:MusicControllerDecodingSong];
    [self fillBuffer];
    [self setElapsedFrames:sampleno];
    
    if([self status] == MusicControllerPlaying)
        AUGraphStart(_outputGraph);
}

-(void)fillBuffer {
    size_t size = [fifoBuffer freespace];
    while(size > 4096*4*2 && [self decoderStatus] == MusicControllerDecodingSong) {
        DecodeStatus status = [currentDecoder decodeNextFrame];
        if(status == DecoderEOF) {
            [self setDecoderStatus:MusicControllerDecodedSong];
        }
        size = [fifoBuffer freespace];
    }
}

- (NSData *)readInput:(int)bytes {
    return [fileHandle readDataOfLength:(NSUInteger)bytes];
}

- (void)seekInput:(unsigned long long)offset {
    [fileHandle seekToFileOffset:offset];
}

- (void)seekInputToEnd {
    [fileHandle seekToEndOfFile];
}

- (unsigned long long)inputPosition {
    return [fileHandle offsetInFile];
}

- (unsigned long long)inputLength {
    unsigned long long curpos = [self inputPosition];
    [self seekInputToEnd];
    unsigned long long length = [self inputPosition];
    [self seekInput:curpos];
    return length;
}

- (void)trackEnded {
    AUGraphStop(_outputGraph);
    [self setStatus:MusicControllerStopped];
    [self setDecoderStatus:MusicControllerDecoderIdle];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"trackEnded" object:_currentTrack];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stoppedPlayback" object:nil];
    _currentTrack = nil;
}

- (PlaylistTrack*)getCurrentTrack { // all instance variables are private
    return _currentTrack;
}

- (void)stop {
    AUGraphStop(_outputGraph);
    [self setStatus:MusicControllerStopped];
    [self setDecoderStatus:MusicControllerDecoderIdle];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stoppedPlayback" object:nil];
    [fifoBuffer reset];
    _currentTrack = nil;
}

- (void)setElapsedFrames:(int)elapsedFrames {
    _elapsedFrames = elapsedFrames;
    
    float sec = (float)elapsedFrames / (float)_inFormat.mSampleRate;
    if(fabs(sec - _prevElapsedTimeSent) > 0.1) {
        _prevElapsedTimeSent = sec;
        
        NSNumber *timeElapsed = [NSNumber numberWithFloat:sec];
        NSNumber *timeTotal = [NSNumber numberWithFloat:(float)_totalFrames / (float) _inFormat.mSampleRate];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:timeElapsed forKey:@"timeElapsed"];
        [dict setObject:timeTotal forKey:@"timeTotal"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"playbackProgress" object:dict];
    }
}

- (float)volume {
    AudioUnitParameterValue volvalue;
    int err = AudioUnitGetParameter(_mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, &volvalue);
    if(err) {
        NSLog(@"AudioUnitGetProperty(kMultiChannelMixerParam_Volume:mixerUnit output) failed");
    }
    return volvalue;
}

- (void)setVolume:(float)volume {
    int err = AudioUnitSetParameter(_mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, volume, 0);
    if(err) {
        NSLog(@"AudioUnitSetProperty(kMultiChannelMixerParam_Volume:mixerUnit output) failed");
    }
}

@end
