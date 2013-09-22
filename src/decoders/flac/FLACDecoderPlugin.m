//
//  FLACDecoderPlugin.m
//  dokibox
//
//  Created by Miles Wu on 04/01/2013.
//
//

#import "FLACDecoderPlugin.h"

PluginManager *__pluginManager;

@implementation FLACDecoderPlugin

-(id<PluginProtocol>)initWithPluginManager:(PluginManager *)pluginManager
{
    __pluginManager = pluginManager;
    [pluginManager registerDecoderClass:[FLACDecoder class] forExtension:@"flac"];
    return self;
}

-(NSString*)name
{
    return @"FLAC Decoder";
}

@end
