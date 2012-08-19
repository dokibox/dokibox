//
//  MusicController.m
//  fb2kmac
//
//  Created by Miles Wu on 22/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MusicController.h"
#import "PlaylistTrack.h"

#import <AudioUnit/AudioUnit.h>

static OSStatus playProc(AudioConverterRef inAudioConverter,
						 UInt32 *ioNumberDataPackets,
                         AudioBufferList *outOutputData,
                         AudioStreamPacketDescription **outDataPacketDescription,
                         void* inClientData) {
    //NSLog(@"Number of buffers %d", outOutputData->mNumberBuffers);
    MusicController *mc = (__bridge MusicController *)inClientData;
    
    int size = [[mc auBuffer] length];
    [[mc fifoBuffer] read:[[mc auBuffer] bytes] size:&size];

    outOutputData->mBuffers[0].mDataByteSize = size;
    outOutputData->mBuffers[0].mData = [[mc auBuffer] bytes];
    //NSLog(@"Wanted: %d", *ioNumberDataPackets*2*2);
    
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
    
    AudioStreamBasicDescription inFormat;
    AudioStreamBasicDescription outFormat;
    AURenderCallbackStruct renderCallback;
    
    ComponentDescription desc;
    Component comp;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_DefaultOutput;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    
    comp = FindNextComponent(NULL, &desc); 
    if (comp == NULL) {
        NSLog(@"Could not find output device");
    }

    err = OpenAComponent(comp, &outputUnit);
    if(err) {
		NSLog(@"OpenAComponent failed");
	}
    
    err = AudioUnitInitialize(outputUnit);
    if(err) {
		NSLog(@"AudioUnitInitialize failed");
	}
    
    AudioUnitGetPropertyInfo(outputUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &size, &outWritable);
	err = AudioUnitGetProperty(outputUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &outFormat, &size);
    if(err) {
		NSLog(@"AudioUnitGetProperty(kAudioUnitProperty_StreamFormat) failed");
	}
	
	err = AudioUnitSetProperty(outputUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &outFormat, size);
    if(err) {
		NSLog(@"AudioUnitSetProperty(kAudioUnitProperty_StreamFormat) failed");
	}
    
    inFormat.mSampleRate = 44100;
    inFormat.mChannelsPerFrame = 2;
    inFormat.mFormatID = kAudioFormatLinearPCM;
    inFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked;
    inFormat.mFormatFlags |= kLinearPCMFormatFlagIsSignedInteger;
    int bps = 2;
    inFormat.mBitsPerChannel = bps << 3;
	inFormat.mBytesPerPacket = bps*inFormat.mChannelsPerFrame;
	inFormat.mFramesPerPacket = 1;
	inFormat.mBytesPerFrame = bps*inFormat.mChannelsPerFrame;
    err = AudioConverterNew(&inFormat, &outFormat, &converter);
    
    memset(&renderCallback, 0, sizeof(AURenderCallbackStruct));
    renderCallback.inputProc = renderProc;
    renderCallback.inputProcRefCon = (__bridge void *)self;
    
    fifoBuffer = [[FIFOBuffer alloc] initWithSize:100000];
    int auBufferSize = 2048;
    void *auBufferContents = malloc(auBufferSize);
    auBuffer = [NSData dataWithBytesNoCopy:auBufferContents length:auBufferSize freeWhenDone:YES];
    
    err = AudioUnitSetProperty (outputUnit, 
                                kAudioUnitProperty_SetRenderCallback, 
                                kAudioUnitScope_Input, 
                                0,
                                &renderCallback, 
                                sizeof(AURenderCallbackStruct));
    
    decoding_queue = dispatch_queue_create("fb2k.decoding",NULL);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPlayTrackNotification:) name:@"playTrack" object:nil];

    return self;
}

- (id<DecoderProtocol>)decoderForFile:(NSString *)filename
{
    NSString *ext = [[filename pathExtension] lowercaseString];
    if([ext compare:@"flac"] == NSOrderedSame) {
        return [[FLACDecoder alloc] initWithMusicController:self];
    }
    else if([ext compare:@"mp3"] == NSOrderedSame) {
        return [[MP3Decoder alloc] initWithMusicController:self];
    }
    else if([ext compare:@"ogg"] == NSOrderedSame) {
        return [[VorbisDecoder alloc] initWithMusicController:self];
    }
    else {
        return nil;
    }
}

- (void)pause
{
    if([self status] == MusicControllerPlaying) {
        [self setStatus:MusicControllerPaused];
        AudioOutputUnitStop(outputUnit);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pausedPlayback" object:_currentTrack];
    }
}

- (void)unpause
{
    if([self status] == MusicControllerPaused) {
        [self setStatus:MusicControllerPlaying];
        AudioOutputUnitStart(outputUnit);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"unpausedPlayback" object:_currentTrack];
    }
}

- (void)receivedPlayTrackNotification:(NSNotification *)notification
{
    if([self decoderStatus] != MusicControllerDecoderIdle) { //still playing something at the moment
        AudioOutputUnitStop(outputUnit);
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
    [currentDecoder decodeMetadata];
    [self fillBuffer];
    AudioOutputUnitStart(outputUnit);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startedPlayback" object:_currentTrack];
};

-(void)fillBuffer {
    size_t size = [fifoBuffer freespace];
    while(size > 30000 && [self decoderStatus] == MusicControllerDecodingSong) {
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

- (void)trackEnded {
    AudioOutputUnitStop(outputUnit);
    [self setStatus:MusicControllerStopped];
    [self setDecoderStatus:MusicControllerDecoderIdle];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"trackEnded" object:_currentTrack];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stoppedPlayback" object:nil];
    _currentTrack = nil;
}


@end
