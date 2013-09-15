//
//  LastFMScrobblerPlugin.m
//  dokibox
//
//  Created by Miles Wu on 14/09/2013.
//
//

#import "LastFMScrobblerPlugin.h"
#import "PluginManager.h"

@implementation LastFMScrobblerPlugin

-(id<PluginProtocol>)initWithPluginManager:(PluginManager *)pluginManager
{
    return self;
}

-(NSString*)name
{
    return @"last.fm Scrobbler";
}

@end
