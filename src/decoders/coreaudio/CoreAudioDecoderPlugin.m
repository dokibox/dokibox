#import "CoreAudioDecoderPlugin.h"

PluginManager *__pluginManager;

@implementation CoreAudioDecoderPlugin

-(id<PluginProtocol>)initWithPluginManager:(PluginManager *)pluginManager
{
    __pluginManager = pluginManager;
    [pluginManager registerDecoderClass:[CoreAudioDecoder class] forExtension:@"m4a"];
    return self;
}

-(NSString*)name
{
    return @"CoreAudio Decoder";
}

@end
