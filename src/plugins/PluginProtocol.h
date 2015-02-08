//
//  PluginProtocol.h
//  dokibox
//
//  Created by Miles Wu on 04/01/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PluginManager;

@protocol PluginProtocol <NSObject>

-(id<PluginProtocol>)initWithPluginManager:(PluginManager *)pluginManager;

@property(readonly) NSString* name;

@optional
    @property(readonly) NSView* preferencePaneView;

@end
