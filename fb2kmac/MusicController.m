//
//  MusicController.m
//  fb2kmac
//
//  Created by Miles Wu on 22/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MusicController.h"
#import "PlaylistTrack.h"
#import "PlaylistController.h"

#import <AudioUnit/AudioUnit.h>

static OSStatus playProc(AudioConverterRef inAudioConverter,
						 UInt32 *ioNumberDataPackets,
                         AudioBufferList *outOutputData,
                         AudioStreamPacketDescription **outDataPacketDescription,
                         void* inClientData) {
    
    //NSLog(@"Number of buffers %d", outOutputData->mNumberBuffers);
    struct hilarity *h = (struct hilarity *)inClientData;
    MusicController *mc = (__bridge MusicController *)h->controller;
    
    size_t size = 0;
    void * data = [mc getBuffer:&size];
    //NSLog(@"Size: %d", size);
    
    if(size == 0)
        return -1;
    
    outOutputData->mBuffers[0].mDataByteSize = size;
    outOutputData->mBuffers[0].mData = data;
    //NSLog(@"Wanted: %d", *ioNumberDataPackets*2*2);
    //NSLog(@"Gave: %d", size);
    
    return(noErr);
    
}

static OSStatus MyFileRenderProc(void *inRefCon, AudioUnitRenderActionFlags *inActionFlags,
                            const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber,
                            UInt32 inNumFrames, AudioBufferList *ioData)
{
    struct hilarity *h = (struct hilarity *)inRefCon;
    AudioStreamPacketDescription* outPacketDescription = NULL;

    OSStatus err = AudioConverterFillComplexBuffer(h->converter, playProc, inRefCon, &inNumFrames, ioData, outPacketDescription);
    return(err);
}



@implementation MusicController

- (id)init {
    self = [super init];
    mp3Decoder = [[MP3Decoder alloc] init];

    int err;
    UInt32 size;
    Boolean outWritable;
    
    AudioConverterRef converter;
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
    renderCallback.inputProc = MyFileRenderProc;
    h.controller = (__bridge void *)self;
    h.converter = converter;
    renderCallback.inputProcRefCon = &h;
    
    err = AudioUnitSetProperty (outputUnit, 
                                kAudioUnitProperty_SetRenderCallback, 
                                kAudioUnitScope_Input, 
                                0,
                                &renderCallback, 
                                sizeof(AURenderCallbackStruct));
        
    return self;
}

- (void)play:(id)sender {
    currentPlaylistController = sender;
    PlaylistTrack *pt = [currentPlaylistController getCurrentTrack];
    
    NSLog(@"Playing %@", [pt title]);
    NSString *fp = @"/test.mp3";
    
    NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:fp];
    if(fh == nil) {
        NSLog(@"File does not exist at %@", fp);
        return;
    }
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(dataReceived:) name:NSFileHandleReadCompletionNotification object:fh];
    [fh readInBackgroundAndNotify];
    
    currentDecoder = mp3Decoder;
    AudioOutputUnitStart(outputUnit);
};

- (void)dataReceived:(NSNotification *)notification {
    NSData *d = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if([d length]) {
        [currentDecoder feedData:d];
        [[notification object] readInBackgroundAndNotify];
    }
}

- (void *)getBuffer:(size_t *)size {
    return ([currentDecoder getBuffer:size]);
}

@end
