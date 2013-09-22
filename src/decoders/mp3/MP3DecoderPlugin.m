//
//  MP3DecoderPlugin.m
//  dokibox
//
//  Created by Miles Wu on 04/01/2013.
//
//

#import "MP3DecoderPlugin.h"

PluginManager *__pluginManager;

@implementation MP3DecoderPlugin

-(id<PluginProtocol>)initWithPluginManager:(PluginManager *)pluginManager
{
    __pluginManager = pluginManager;
    [pluginManager registerDecoderClass:[MP3Decoder class] forExtension:@"mp3"];
    return self;
}

-(NSString*)name
{
    return @"MP3 Decoder";
}

@end
