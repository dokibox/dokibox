//
//  FFmpegDecoderPlugin.m
//  dokibox
//
//  Created by Miles Wu on 28/06/2015.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "FFmpegDecoderPlugin.h"

PluginManager *__pluginManager;

@implementation FFmpegDecoderPlugin

-(id<PluginProtocol>)initWithPluginManager:(PluginManager *)pluginManager
{
    __pluginManager = pluginManager;
    [pluginManager registerDecoderClass:[FFmpegDecoder class] forExtension:@"wv"];
    [pluginManager registerDecoderClass:[FFmpegDecoder class] forExtension:@"mp3"];
    return self;
}

-(NSString*)name
{
    return @"FFmpeg Decoder";
}

@end
