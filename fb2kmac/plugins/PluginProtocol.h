//
//  PluginProtocol.h
//  fb2kmac
//
//  Created by Miles Wu on 04/01/2013.
//
//

#import <Foundation/Foundation.h>

@class PluginManager;

@protocol PluginProtocol <NSObject>

-(id<PluginProtocol>)initWithPluginManager:(PluginManager *)pluginManager;

@end
