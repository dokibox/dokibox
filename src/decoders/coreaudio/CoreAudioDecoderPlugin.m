#import "CoreAudioDecoderPlugin.h"

@implementation CoreAudioDecoderPlugin

-(id<PluginProtocol>)initWithPluginManager:(PluginManager *)pluginManager
{
    [pluginManager registerDecoderClass:[CoreAudioDecoder class] forExtension:@"m4a"];
    return self;
}

@end
