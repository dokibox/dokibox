//
//  ProfileViewController.m
//  dokibox
//
//  Created by Miles Wu on 29/10/2013.
//
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(IBAction)openButtonPushed:(id)sender
{
    [[NSApplication sharedApplication] stopModalWithCode:0];
}

@end
