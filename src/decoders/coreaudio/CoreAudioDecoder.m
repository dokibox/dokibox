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
    }
    
    retval = ExtAudioFileWrapAudioFileID(_inAudioFileID, NO, &_inFileRef);
    if (retval != noErr){
        NSLog(@"Failed to wrap stream: %d", retval);
        return self;
    }
    
    UInt32 inFormatSize = sizeof(_inFormat);
    retval = ExtAudioFileGetProperty(_inFileRef, kExtAudioFileProperty_FileDataFormat, &inFormatSize, &_inFormat);
    if (retval != noErr){
        NSLog(@"Problem getting stream information");
    }
    
    if (_inFormat.mFormatID == kAudioFormatAppleLossless) {
        switch(_inFormat.mFormatFlags) {
            case kAppleLosslessFormatFlag_16BitSourceData:
                _inFormat.mBitsPerChannel = 16;
                break;
            case kAppleLosslessFormatFlag_20BitSourceData:
                _inFormat.mBitsPerChannel = 20;
                break;
            case kAppleLosslessFormatFlag_24BitSourceData:
                _inFormat.mBitsPerChannel = 24;
                break;
            case kAppleLosslessFormatFlag_32BitSourceData:
                _inFormat.mBitsPerChannel = 32;
                break;
            default:
                _inFormat.mBitsPerChannel = 16;
                break;
        }
    } else {
        _inFormat.mBitsPerChannel = 16;
    }

    _clientFormat.mFormatID = kAudioFormatLinearPCM;
    _clientFormat.mSampleRate = _inFormat.mSampleRate;
    _clientFormat.mChannelsPerFrame = _inFormat.mChannelsPerFrame;
    _clientFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked | kLinearPCMFormatFlagIsSignedInteger;
    _clientFormat.mBitsPerChannel = _inFormat.mBitsPerChannel;
    _clientFormat.mBytesPerPacket = _inFormat.mBitsPerChannel/8*_clientFormat.mChannelsPerFrame;
    _clientFormat.mFramesPerPacket = 1;
    _clientFormat.mBytesPerFrame = _inFormat.mBitsPerChannel/8*_clientFormat.mChannelsPerFrame;
    
    retval = ExtAudioFileSetProperty(_inFileRef, kExtAudioFileProperty_ClientDataFormat, sizeof(_clientFormat), &_clientFormat);
    if(retval != noErr) {
        NSLog(@"Problem setting output format: %i", retval);
    }
    
    return self;
}

-(DecoderMetadata)decodeMetadata {
    _metadata.sampleRate = _inFormat.mSampleRate;
    _metadata.bitsPerSample = _inFormat.mBitsPerChannel;
    SInt64 length;
    UInt32 lengthSize;
    OSStatus retval = ExtAudioFileGetProperty(_inFileRef, kExtAudioFileProperty_FileLengthFrames, &lengthSize, &length);
    if (retval != noErr) {
        // cry like a baby
    }
    _metadata.totalSamples = (int)length;
    _metadata.numberOfChannels = _inFormat.mChannelsPerFrame;
    _metadata.format = DecoderFormatSigned;
    return _metadata;
}

-(void)dealloc {
    NSLog(@"Deallocing CoreAudio decoder");
    ExtAudioFileDispose(_inFileRef);
    AudioFileClose(_inAudioFileID);
}

-(DecodeStatus)decodeNextFrame {
    UInt32 numberOfFrames = 1;
    UInt32 bufferByteSize = _clientFormat.mBytesPerFrame*numberOfFrames;
    char srcBuffer[bufferByteSize];
    
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
        return DecoderEOF;
    }
    
    [[musicController fifoBuffer] write:outBufList.mBuffers[0].mData size:outBufList.mBuffers[0].mDataByteSize];
    
    return DecoderSuccess;
}

-(void)seekToFrame:(unsigned long long)frame {
    OSStatus retval __unused = ExtAudioFileSeek(_inFileRef, frame);
}
@end
