//
//  LastFMScrobblerPluginPreferenceViewController.m
//  dokibox
//
//  Created by Miles Wu on 15/09/2013.
//
//

#import "LastFMScrobblerPluginPreferenceViewController.h"
#import "LastFMScrobblerPlugin.h"

@interface LastFMScrobblerPluginPreferenceViewController ()

@end

@implementation LastFMScrobblerPluginPreferenceViewController

- (id)initWithLastFMScrobblerPlugin:(LastFMScrobblerPlugin*)lastFMScrobblerPlugin;
{
    self = [super initWithNibName:@"LastFMScrobblerPluginPreferenceViewController" bundle:[NSBundle bundleForClass:[self class]]];
    
    if (self) {
        _lastFMScrobblerPlugin = lastFMScrobblerPlugin;
    }
    
    return self;
}

-(IBAction)loginButtonPressed:(id)sender
{

    
}

@end
