//
//  LastFMScrobblerPluginPreferenceViewController.h
//  dokibox
//
//  Created by Miles Wu on 15/09/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LastFMScrobblerPlugin;

@interface LastFMScrobblerPluginPreferenceViewController : NSViewController {
    LastFMScrobblerPlugin *_lastFMScrobblerPlugin;
    
    NSButton* IBOutlet _loginButton;
}

- (id)initWithLastFMScrobblerPlugin:(LastFMScrobblerPlugin*)lastFMScrobblerPlugin;

-(void)updateAccountStatus;
-(IBAction)loginButtonPressed:(id)sender;
-(IBAction)logoButtonPressed:(id)sender;

@property() NSString* statusString;
@property() NSString* loginButtonString;

@end
