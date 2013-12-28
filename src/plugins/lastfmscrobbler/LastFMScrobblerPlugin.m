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

PluginManager *__pluginManager;

@implementation LastFMScrobblerPlugin

@synthesize lastfmUserName = _lastfmUserName;
@synthesize lastfmUserKey = _lastfmUserKey;

-(id<PluginProtocol>)initWithPluginManager:(PluginManager *)pluginManager
{
    self = [super init];
    __pluginManager = pluginManager;
    
    if(self) {
        _lastfmUserName = [[NSUserDefaults standardUserDefaults] stringForKey:@"LastFMScrobblerPluginUserName"];
        _lastfmUserKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"LastFMScrobblerPluginUserKey"];
   
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNewTrackPlayingNotification:) name:@"pluginNewTrackPlaying" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePlaybackProgressNotification:) name:@"pluginPlaybackProgress" object:nil];
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
    _secondsOfPlayback = 0.0;
    _currentPlaybackPosition = 0.0;
    _startOfPlaybackDate = [NSDate date];
    _scrobbled = NO;
    
    NSDictionary *attributes = [notification object];
    _trackAttributes = attributes;
   
    if([self lastfmUserKey] == nil) // if no user setup, dont do API call
        return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // no blocking of UI
        LastFMScrobblerPluginAPICall *apiCall = [[LastFMScrobblerPluginAPICall alloc] init];
        [apiCall setParameter:@"method" value:@"track.updateNowPlaying"];
        [apiCall setParameter:@"sk" value:[self lastfmUserKey]];
        
        if([attributes objectForKey:@"TITLE"] == nil && [attributes objectForKey:@"ARTIST"] == nil)
            return; //not enough tags
        
        if([attributes objectForKey:@"TITLE"])
            [apiCall setParameter:@"track" value:[attributes objectForKey:@"TITLE"]];
        if([attributes objectForKey:@"ARTIST"])
            [apiCall setParameter:@"artist" value:[attributes objectForKey:@"ARTIST"]];
        if([attributes objectForKey:@"ALBUM"])
            [apiCall setParameter:@"album" value:[attributes objectForKey:@"ALBUM"]];
        if([attributes objectForKey:@"length"])
            [apiCall setParameter:@"duration" value:[NSString stringWithFormat:@"%d", [[attributes objectForKey:@"length"] intValue]]];
        
        [apiCall performPOST]; // we don't really care about the result
    });
}

-(void)receivePlaybackProgressNotification:(NSNotification*)notification
{
    NSDictionary *dict = [notification object];
    float total = [[dict objectForKey:@"timeTotal"] floatValue];
    float cur = [[dict objectForKey:@"timeElapsed"] floatValue];
    
    _secondsOfPlayback += cur - _currentPlaybackPosition;
    _currentPlaybackPosition = cur;
    
    if(_scrobbled == NO && total > 30 && (_secondsOfPlayback > 4*60 || _secondsOfPlayback > total/2.0)) {
        // scrobble time
        
        if([self lastfmUserKey] == nil) // if no user setup, dont do API call
            return;
        
        _scrobbled = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            // no blocking of UI
            LastFMScrobblerPluginAPICall *apiCall = [[LastFMScrobblerPluginAPICall alloc] init];
            [apiCall setParameter:@"method" value:@"track.scrobble"];
            [apiCall setParameter:@"sk" value:[self lastfmUserKey]];
            
            if([_trackAttributes objectForKey:@"TITLE"] == nil && [_trackAttributes objectForKey:@"ARTIST"] == nil)
                return; //not enough tags
            
            if([_trackAttributes objectForKey:@"TITLE"])
                [apiCall setParameter:@"track" value:[_trackAttributes objectForKey:@"TITLE"]];
            if([_trackAttributes objectForKey:@"ARTIST"])
                [apiCall setParameter:@"artist" value:[_trackAttributes objectForKey:@"ARTIST"]];
            if([_trackAttributes objectForKey:@"ALBUM"])
                [apiCall setParameter:@"album" value:[_trackAttributes objectForKey:@"ALBUM"]];
            if([_trackAttributes objectForKey:@"length"])
                [apiCall setParameter:@"duration" value:[NSString stringWithFormat:@"%d", [[_trackAttributes objectForKey:@"length"] intValue]]];
            
            [apiCall setParameter:@"timestamp" value:[NSString stringWithFormat:@"%d", (int)[_startOfPlaybackDate timeIntervalSince1970]]];
            
            [apiCall performPOST]; // we might want to retry later if there's a problem
        });
    }
}


@end
