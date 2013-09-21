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
#import "LastFMScrobblerPluginAPICall.h"

@implementation LastFMScrobblerPlugin

@synthesize lastfmUserName = _lastfmUserName;
@synthesize lastfmUserKey = _lastfmUserKey;

-(id<PluginProtocol>)initWithPluginManager:(PluginManager *)pluginManager
{
    self = [super init];
    
    if(self) {
        _lastfmUserName = [[NSUserDefaults standardUserDefaults] stringForKey:@"LastFMScrobblerPluginUserName"];
        _lastfmUserKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"LastFMScrobblerPluginUserKey"];
   
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNewTrackPlayingNotification:) name:@"pluginNewTrackPlaying" object:nil];
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

-(void)receiveNewTrackPlayingNotification:(NSNotification*)notification
{
    NSDictionary *attributes = [notification object];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // no blocking of UI
        LastFMScrobblerPluginAPICall *apiCall = [[LastFMScrobblerPluginAPICall alloc] init];
        [apiCall setParameter:@"method" value:@"track.updateNowPlaying"];
        [apiCall setParameter:@"sk" value:[self lastfmUserKey]];
        
        if([attributes objectForKey:@"TITLE"])
            [apiCall setParameter:@"track" value:[attributes objectForKey:@"TITLE"]];
        if([attributes objectForKey:@"ARTIST"])
            [apiCall setParameter:@"artist" value:[attributes objectForKey:@"ARTIST"]];
        if([attributes objectForKey:@"ALBUM"])
            [apiCall setParameter:@"album" value:[attributes objectForKey:@"ALBUM"]];
        
        [apiCall performPOST]; // we don't really care about the result
    });
}



@end
