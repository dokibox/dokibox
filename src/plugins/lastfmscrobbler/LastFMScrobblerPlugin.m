//
//  LastFMScrobblerPlugin.m
//  dokibox
//
//  Created by Miles Wu on 14/09/2013.
//
//

#import "LastFMScrobblerPlugin.h"
#import "PluginManager.h"
#import "LastFMScrobblerPluginPreferenceViewController.h"

@implementation LastFMScrobblerPlugin

@synthesize lastfmUserName = _lastfmUserName;
@synthesize lastfmUserKey = _lastfmUserKey;

-(id<PluginProtocol>)initWithPluginManager:(PluginManager *)pluginManager
{
    self = [super init];
    
    if(self) {
        _lastfmUserName = [[NSUserDefaults standardUserDefaults] stringForKey:@"LastFMScrobblerPluginUserName"];
        _lastfmUserKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"LastFMScrobblerPluginUserKey"];
    }
    
    return self;
}

-(NSString*)name
{
    return @"last.fm Scrobbler";
}

-(NSView*)preferencePaneView
{
    if(_viewController == nil)
        _viewController = [[LastFMScrobblerPluginPreferenceViewController alloc] initWithLastFMScrobblerPlugin:self];
    return [_viewController view];
}

-(NSString *)lastfmUserName
{
    return _lastfmUserName;
}

-(void)setLastfmUserName:(NSString *)lastfmUserName
{
    _lastfmUserName = lastfmUserName;
    [[NSUserDefaults standardUserDefaults] setObject:_lastfmUserName forKey:@"LastFMScrobblerPluginUserName"];
}

-(NSString *)lastfmUserKey
{
    return _lastfmUserKey;
}

-(void)setLastfmUserKey:(NSString *)lastfmUserKey
{
    _lastfmUserKey = lastfmUserKey;
    [[NSUserDefaults standardUserDefaults] setObject:_lastfmUserKey forKey:@"LastFMScrobblerPluginUserKey"];
}


@end
