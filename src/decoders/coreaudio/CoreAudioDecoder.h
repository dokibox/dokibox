#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "DecoderProtocol.h"
#import "common.h"

static OSStatus streamReadRequest(void* musicController, SInt64 position, UInt32 requestCount, void* buffer, UInt32* actualCount);
static SInt64 streamGetSizeRequest(void* musicController);

@interface CoreAudioDecoder : NSObject<DecoderProtocol> {
    MusicController *musicController;
    DecoderMetadata _metadata;
    AudioFileID _inAudioFileID;
    ExtAudioFileRef _inFileRef;
    AudioStreamBasicDescription _inFormat;
    AudioStreamBasicDescription _clientFormat;
}

@property (retain) MusicController *musicController;

@end
