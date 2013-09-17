//
//  LastFMScrobblerPluginPreferenceViewController.m
//  dokibox
//
//  Created by Miles Wu on 15/09/2013.
//
//

#import "LastFMScrobblerPluginPreferenceViewController.h"
#import "LastFMScrobblerPluginAPICall.h"
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
    LastFMScrobblerPluginAPICall *apiCall = [[LastFMScrobblerPluginAPICall alloc] init];
    [apiCall setParameter:@"method" value:@"auth.getToken"];
    NSXMLDocument *doc = [apiCall performRequest];
    
    NSXMLNode *n = [doc rootElement];
    NSString *token = nil;
    while((n = [n nextNode])) {
        if([[n name] isEqualToString:@"token"]) {
            token = [n stringValue];
        }
    }
    
    if(token == nil) {
        NSLog(@"Error. No token found");
        return;
    }
    
    // Open user's browsers to do the authentication
    NSString *url = [NSString stringWithFormat:@"https://www.last.fm/api/auth/?api_key=%@&token=%@", [LastFMScrobblerPluginAPICall apiKey], token];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];

    
    NSString *name = nil, *key = nil;
    for(;;) { // Start doing the check
        apiCall = [[LastFMScrobblerPluginAPICall alloc] init];
        [apiCall setParameter:@"method" value:@"auth.getSession"];
        [apiCall setParameter:@"token" value:token];

        doc = [apiCall performRequest];
        n = [doc rootElement];
        BOOL wait = NO;
        
        while((n = [n nextNode])) {
            if([[n name] isEqualToString:@"error"] && [n kind] == NSXMLElementKind) {
                NSXMLElement *element = (NSXMLElement *)n;
                NSXMLNode *attr = [element attributeForName:@"code"];
                if(attr && [[attr stringValue] isEqualToString:@"14"]) {
                    wait = YES;
                }
            }
            else if([[n name] isEqualToString:@"name"]) {
                name = [n stringValue];
            }
            else if([[n name] isEqualToString:@"key"]) {
                key = [n stringValue];
            }
        }
        
        if(wait == NO) {
            break;
        }
        else { // Token hasn't been authorized yet. Try again in a bit
            NSLog(@"wait");
            sleep(1);
        }
    }
    
    if(name == nil || key == nil) {
        NSLog(@"Error obtaining session key");
        return;
    }
    
    [_lastFMScrobblerPlugin setLastfmUserName:name];
    [_lastFMScrobblerPlugin setLastfmUserKey:key];
}

@end
