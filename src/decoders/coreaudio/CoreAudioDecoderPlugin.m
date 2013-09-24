#import "CoreAudioDecoderPlugin.h"

PluginManager *__pluginManager;

@implementation CoreAudioDecoderPlugin

-(id<PluginProtocol>)initWithPluginManager:(PluginManager *)pluginManager
{
    __pluginManager = pluginManager;
    [pluginManager registerDecoderClass:[CoreAudioDecoder class] forExtension:@"m4a"];
    [pluginManager registerDecoderClass:[CoreAudioDecoder class] forExtension:@"mp3"];
    return self;
}

-(NSString*)name
{
    return @"CoreAudio Decoder";
}

@end
