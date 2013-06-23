//
//  LibraryPreferenceViewController.m
//  fb2kmac
//
//  Created by Miles Wu on 22/06/2013.
//
//

#import "LibraryPreferenceViewController.h"

@implementation LibraryPreferenceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSString *)identifier
{
    return @"library";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameAdvanced];
}

- (NSString *)toolbarItemLabel
{
    return @"Library";
}

@end
