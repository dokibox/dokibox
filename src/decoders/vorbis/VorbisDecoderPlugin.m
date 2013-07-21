//
//  VorbisDecoderPlugin.m
//  dokibox
//
//  Created by Miles Wu on 04/01/2013.
//
//

#import "VorbisDecoderPlugin.h"

@implementation VorbisDecoderPlugin

-(id<PluginProtocol>)initWithPluginManager:(PluginManager *)pluginManager
{
    [pluginManager registerDecoderClass:[VorbisDecoder class] forExtension:@"ogg"];
    return self;
}

@end
