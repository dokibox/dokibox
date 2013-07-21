//
//  FLACDecoderPlugin.m
//  dokibox
//
//  Created by Miles Wu on 04/01/2013.
//
//

#import "FLACDecoderPlugin.h"

@implementation FLACDecoderPlugin

-(id<PluginProtocol>)initWithPluginManager:(PluginManager *)pluginManager
{
    [pluginManager registerDecoderClass:[FLACDecoder class] forExtension:@"flac"];
    return self;
}

@end
