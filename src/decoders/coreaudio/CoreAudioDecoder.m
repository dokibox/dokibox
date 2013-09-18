#import "CoreAudioDecoder.h"
#import "MusicController.h"

static OSStatus streamReadRequest(void* mc, SInt64 position, UInt32 requestCount, void* buffer, UInt32* actualCount) {
    MusicController *musicController = (__bridge MusicController*) mc;
    [musicController seekInput:position];
    NSData *data = [musicController readInput:requestCount];
    int size = (int)[data length];
    *actualCount = size;

    if(size == 0) {
        return noErr;
    }
    
    memcpy(buffer, [data bytes], size);
    return noErr;
}

static SInt64 streamGetSizeRequest(void* mc) {
    MusicController *musicController = (__bridge MusicController*) mc;
    SInt64 streamSize = [musicController inputLength];
    return streamSize;
}

@implementation CoreAudioDecoder

@synthesize musicController;

-(id)initWithMusicController:(MusicController *)mc {
    self = [super init];
    musicController = mc;
    
    OSStatus retval = AudioFileOpenWithCallbacks((__bridge void*)musicController, streamReadRequest, NULL, streamGetSizeRequest, NULL, 0, &_inAudioFileID);
    if(retval != noErr){
        NSLog(@"Failed to open stream: %d", retval);
        return self;
    } else {
        NSLog(@"Stream opened.");
    }
    
    retval = ExtAudioFileWrapAudioFileID(_inAudioFileID, NO, &_inFileRef);
    if (retval != noErr){
        NSLog(@"Failed to wrap stream: %d", retval);
        return self;
    } else {
        NSLog(@"Stream wrapped.");
    }
    
    UInt32 inFormatSize = sizeof(_inFormat);
    retval = ExtAudioFileGetProperty(_inFileRef, kExtAudioFileProperty_FileDataFormat, &inFormatSize, &_inFormat);
    if (retval != noErr){
        NSLog(@"Problem getting stream information");
    }
    
    NSLog(@"ALAC: %@", _inFormat.mFormatID == kAudioFormatAppleLossless ? @"YES" : @"NO");
    
    // output format ASBD (should respect bitdepth and sampling rate and probably other stuff from the input too)

    _clientFormat.mFormatID = kAudioFormatLinearPCM;
    _clientFormat.mSampleRate = _inFormat.mSampleRate;
    _clientFormat.mChannelsPerFrame = _inFormat.mChannelsPerFrame;
    _clientFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked | kLinearPCMFormatFlagIsSignedInteger;
    _clientFormat.mBitsPerChannel = 16;
    _clientFormat.mBytesPerPacket = 2*_clientFormat.mChannelsPerFrame;
    _clientFormat.mFramesPerPacket = 1;
    _clientFormat.mBytesPerFrame = 2*_clientFormat.mChannelsPerFrame;
    
    retval = ExtAudioFileSetProperty(_inFileRef, kExtAudioFileProperty_ClientDataFormat, sizeof(_clientFormat), &_clientFormat);
    if(retval != noErr) {
        NSLog(@"Problem setting output format: %i", retval);
    }
    
    return self;
}

-(DecoderMetadata)decodeMetadata {
    _metadata.sampleRate = _inFormat.mSampleRate;
    _metadata.bitsPerSample = _inFormat.mBitsPerChannel;
    _metadata.totalSamples = [musicController inputLength]/_inFormat.mBytesPerFrame; // idk about the math here.
    _metadata.numberOfChannels = _inFormat.mChannelsPerFrame;
    _metadata.format = DecoderFormatSigned;
    return _metadata;
}

-(DecodeStatus)decodeNextFrame {
    UInt32 bufferByteSize = 44100 * 4 * 2; // idk how big a frame is. at some point get this from the stream itself
    char srcBuffer[bufferByteSize];
    UInt32 numberOfFrames = 1; // random numbers that exist.
    
    AudioBufferList outBufList;
    outBufList.mNumberBuffers = 1;
    outBufList.mBuffers[0].mNumberChannels = _clientFormat.mChannelsPerFrame;
    outBufList.mBuffers[0].mDataByteSize = bufferByteSize;
    outBufList.mBuffers[0].mData = srcBuffer;

    OSStatus retval = ExtAudioFileRead(_inFileRef, &numberOfFrames, &outBufList);
    
    if (retval != noErr) {
        NSLog(@"error %d", retval);
        return DecoderEOF;
    }
    
    if (numberOfFrames == 0) { // EOF
        ExtAudioFileDispose(_inFileRef);
        AudioFileClose(_inAudioFileID);
        return DecoderEOF;
    }
    
    [[musicController fifoBuffer] write:outBufList.mBuffers[0].mData size:outBufList.mBuffers[0].mDataByteSize];
    
    return DecoderSuccess;
}

-(void)seekToFrame:(unsigned long long)frame {
//    OSStatus retval = ExtAudioFileSeek(_inFileRef);
//    [musicController seekInput:ioinput_offset];
    NSLog(@"nope. no seeking.");
}
@end
