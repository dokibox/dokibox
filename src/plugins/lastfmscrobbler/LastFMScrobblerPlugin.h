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
}

@property() NSString *lastfmUserName;
@property() NSString *lastfmUserKey;


@end
