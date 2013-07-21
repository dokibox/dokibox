//
//  PluginManager.h
//  dokibox
//
//  Created by Miles Wu on 31/12/2012.
//
//

#import <Foundation/Foundation.h>
#import "PluginProtocol.h"
#import "../decoders/DecoderProtocol.h"

@interface PluginManager : NSObject {
    NSMutableArray *_plugins;
    NSMutableDictionary *_decoderPlugins;
}

+(PluginManager *)sharedInstance;

-(void)loadAll;
-(void)loadFromPath:(NSString*)path;

-(void)registerDecoderClass:(Class)decoderClass forExtension:(NSString*)extension;
-(Class)decoderClassForExtension:(NSString*)extension;

@property(readonly) NSMutableArray *plugins;

@end
