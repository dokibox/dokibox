//
//  PluginPreferenceViewController.m
//  dokibox
//
//  Created by Miles Wu on 14/09/2013.
//
//

#import "PluginPreferenceViewController.h"
#import "PluginManager.h"

@implementation PluginPreferenceViewController

- (id)init
{
    self = [self initWithNibName:@"PluginPreferenceViewController" bundle:nil];
    if(self) {
        _pluginManager = [PluginManager sharedInstance];
    }
    return self;
}

- (NSString *)identifier
{
    return @"plugins";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameAdvanced];
}

- (NSString *)toolbarItemLabel
{
    return @"Plugins";
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[_pluginManager plugins] count];
}

-(id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [[[_pluginManager plugins] objectAtIndex:row] name];
}




@end
