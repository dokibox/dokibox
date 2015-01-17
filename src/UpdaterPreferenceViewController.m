//
//  UpdaterPreferenceViewController.m
//  dokibox
//
//  Created by Miles Wu on 17/01/2015.
//
//

#import "UpdaterPreferenceViewController.h"

@interface UpdaterPreferenceViewController ()

@end

@implementation UpdaterPreferenceViewController

- (NSString *)identifier
{
    return @"updater";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameAdvanced];
}

- (NSString *)toolbarItemLabel
{
    return @"Updater";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

@end
