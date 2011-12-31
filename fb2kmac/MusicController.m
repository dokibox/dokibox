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
        
    if(h->buffer_provider_size != 2048) {
        h->buffer_provider_size = 2048;
        h->buffer_provider = realloc(h->buffer_provider, h->buffer_provider_size);
    }
    
    [mc readFifo:h->buffer_provider size:h->buffer_provider_size];

    outOutputData->mBuffers[0].mDataByteSize = h->buffer_provider_size;
    outOutputData->mBuffers[0].mData = h->buffer_provider;
    //NSLog(@"Wanted: %d", *ioNumberDataPackets*2*2);
    //NSLog(@"Gave: %d", size);
    
    dispatch_async(h->decoding_queue, ^{
        size_t size = [mc freespaceFifo];
        if(size != 0) {
            //NSLog(@"Need size: %d", size);
            void * data = malloc(size);
            [mc getBuffer:data size:&size];
            if(size != 0) {
                //NSLog(@"Got size: %d", size);q
                [mc writeFifo: data size:size];
            }
            free(data);
        }
    });
    
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
    h.buffer_fifo_size = 20000;
    h.buffer_fifo_wpos = 0;
    h.buffer_fifo_rpos = 0;
    h.buffer_fifo = malloc(h.buffer_fifo_size);
    
    h.buffer_provider_size = 1;
    h.buffer_provider = malloc(h.buffer_provider_size);
    h.decoding_queue = dispatch_queue_create("fb2k.decoding",NULL);

    return self;
}

-(int)storedFifo {
    int stored;
    if(h.buffer_fifo_wpos >= h.buffer_fifo_rpos)
        stored = h.buffer_fifo_wpos - h.buffer_fifo_rpos;
    else
        stored = h.buffer_fifo_size - h.buffer_fifo_rpos + h.buffer_fifo_wpos;
    return(stored);
}

-(int)freespaceFifo {
    return(h.buffer_fifo_size - [self storedFifo] - 1); //This must be 1 less or how would you tell a full buffer from an empty one when (wpos==rpos).
}

- (void)writeFifo:(void *)data size:(int)size {
    // check enough space
    assert(size <= [self freespaceFifo]);
    
    if(size + h.buffer_fifo_wpos > h.buffer_fifo_size) {
        //split write up into two halves
        memcpy(h.buffer_fifo + h.buffer_fifo_wpos, data, h.buffer_fifo_size - h.buffer_fifo_wpos);
        size -= h.buffer_fifo_size - h.buffer_fifo_wpos;
        data += h.buffer_fifo_size - h.buffer_fifo_wpos;
        h.buffer_fifo_wpos = 0;
    }
    memcpy(h.buffer_fifo + h.buffer_fifo_wpos, data, size);
    h.buffer_fifo_wpos += size;
}

- (void)readFifo:(void *)data size:(int)size {
    if([self storedFifo] < size) {
        NSLog(@"not enough to read from");
        return;
    }
    if(size + h.buffer_fifo_rpos > h.buffer_fifo_size) {
        //split read up into two halves
        memcpy(data, h.buffer_fifo + h.buffer_fifo_rpos, h.buffer_fifo_size - h.buffer_fifo_rpos);
        size -= h.buffer_fifo_size - h.buffer_fifo_rpos;
        data += h.buffer_fifo_size - h.buffer_fifo_rpos;
        h.buffer_fifo_rpos = 0;
    }
    memcpy(data, h.buffer_fifo + h.buffer_fifo_rpos, size);
    h.buffer_fifo_rpos += size;
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
    firstDataRecieved = FALSE;

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(dataReceived:) name:NSFileHandleReadCompletionNotification object:fh];
    [fh readInBackgroundAndNotify];
    
    currentDecoder = mp3Decoder;
};

- (void)dataReceived:(NSNotification *)notification {
    NSData *d = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if([d length]) {
        [currentDecoder feedData:d];
        
        if(firstDataRecieved == FALSE) {
            size_t size = [self freespaceFifo];
            void * data = malloc(size);
            [self getBuffer:data size:&size];
            if(size != 0) {
                //NSLog(@"First data was: %d", size);
                firstDataRecieved = TRUE;
                [self writeFifo: data size:size];
                AudioOutputUnitStart(outputUnit);
            }
            free(data);
        }
        
        [[notification object] readInBackgroundAndNotify];
    }
}

- (void)getBuffer:(void *)data size:(size_t *)size {
    //NSLog(@"Attempting to get %d", *size);
    [currentDecoder getBuffer:data size:size];
}

@end
