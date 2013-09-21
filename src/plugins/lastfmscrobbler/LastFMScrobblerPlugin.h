//
//  LastFMScrobblerPlugin.h
//  dokibox
//
//  Created by Miles Wu on 14/09/2013.
//
//

#import <Foundation/Foundation.h>
#import "PluginProtocol.h"

@class LastFMScrobblerPluginPreferenceViewController;

@interface LastFMScrobblerPlugin : NSObject<PluginProtocol> {
    LastFMScrobblerPluginPreferenceViewController *_viewController;
    
    float _secondsOfPlayback; //this differs from track position as it takes into account skipping
    float _currentPlaybackPosition;
    NSDate *_startOfPlaybackDate;
    NSDictionary *_trackAttributes;
    BOOL _scrobbled;
}

-(void)receiveNewTrackPlayingNotification:(NSNotification*)notification;
-(void)receivePlaybackProgressNotification:(NSNotification*)notification;

@property() NSString *lastfmUserName;
@property() NSString *lastfmUserKey;


@end
