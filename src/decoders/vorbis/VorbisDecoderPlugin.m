//
//  VorbisDecoderPlugin.m
//  dokibox
//
//  Created by Miles Wu on 04/01/2013.
//
//

#import "VorbisDecoderPlugin.h"

PluginManager *__pluginManager;

@implementation VorbisDecoderPlugin

-(id<PluginProtocol>)initWithPluginManager:(PluginManager *)pluginManager
{
    __pluginManager = pluginManager;
    [pluginManager registerDecoderClass:[VorbisDecoder class] forExtension:@"ogg"];
    return self;
}

-(NSString*)name
{
    return @"Ogg/Vorbis Decoder";
}

@end
