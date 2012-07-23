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
    MusicController *mc = (__bridge MusicController *)inClientData;
        
    [[mc fifoBuffer] read:[[mc auBuffer] bytes] size:[[mc auBuffer] length]];

    outOutputData->mBuffers[0].mDataByteSize = [[mc auBuffer] length];
    outOutputData->mBuffers[0].mData = [[mc auBuffer] bytes];
    //NSLog(@"Wanted: %d", *ioNumberDataPackets*2*2);
    //NSLog(@"Gave: %d", size);
    
    dispatch_async([mc decoding_queue], ^{
        size_t size = [[mc fifoBuffer] freespace];
        while(size > 30000) {
            [mc decodeNextFrame];
            size = [[mc fifoBuffer] freespace];
        }
    });
    
    return(noErr);
    
}

static OSStatus renderProc(void *inRefCon, AudioUnitRenderActionFlags *inActionFlags,
                            const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber,
                            UInt32 inNumFrames, AudioBufferList *ioData)
{
    MusicController *mc = (__bridge MusicController *)inRefCon;
    AudioStreamPacketDescription* outPacketDescription = NULL;

    OSStatus err = AudioConverterFillComplexBuffer([mc converter], playProc, inRefCon, &inNumFrames, ioData, outPacketDescription);
    return(err);
}



@implementation MusicController

@synthesize decoding_queue;
@synthesize fifoBuffer;
@synthesize auBuffer;
@synthesize converter;

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

    return self;
}

- (void)play:(id)sender {
    currentPlaylistController = sender;
    PlaylistTrack *pt = [currentPlaylistController getCurrentTrack];
    
    //NSLog(@"Playing %@", [pt title]);
    NSString *fp = @"/test.ogg";
    
    fileHandle = [NSFileHandle fileHandleForReadingAtPath:fp];
    if(fileHandle == nil) {
        NSLog(@"File does not exist at %@", fp);
        return;
    }
    
    currentDecoder = [[VorbisDecoder alloc] initWithMusicController:self];
    [currentDecoder decodeMetadata];
    size_t size = [fifoBuffer freespace];
    while(size > 30000) {
        [self decodeNextFrame];
        size = [fifoBuffer freespace];
    }
    AudioOutputUnitStart(outputUnit);
};

- (NSData *)readInput:(int)bytes {
    return [fileHandle readDataOfLength:(NSUInteger)bytes];
}

-(void)decodeNextFrame {
    [currentDecoder decodeNextFrame];
}


@end
