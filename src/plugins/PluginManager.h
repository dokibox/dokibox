//
//  PluginManager.h
//  dokibox
//
//  Created by Miles Wu on 31/12/2012.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginProtocol.h"
#import "../decoders/DecoderProtocol.h"

#define PLUGINLOGERROR 1
#define PLUGINLOGINFO 2
#define PLUGINLOGWARN 3
#define PLUGINLOGVERBOSE 4

@interface PluginManager : NSObject {
    NSMutableArray *_plugins;
    NSMutableDictionary *_decoderPlugins;
}

+(PluginManager *)sharedInstance;

-(void)loadAll;
-(void)loadFromPath:(NSString*)path;

-(void)registerDecoderClass:(Class)decoderClass forExtension:(NSString*)extension;
-(Class)decoderClassForExtension:(NSString*)extension;

-(void)logFromPlugin:(id)plugin level:(int)level withFormat:(NSString*)format, ...;

@property(readonly) NSMutableArray *plugins;

@end
