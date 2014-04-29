//
//  LicenseController.h
//  dokibox
//
//  Created by Miles Wu on 05/01/2014.
//
//

#import <Cocoa/Cocoa.h>

@interface LicenseController : NSViewController

- (void)openRegistrationPanel;
- (void)checkLicense;

-(IBAction)laterButtonPressed:(id)sender;
-(IBAction)purchaseButtonPressed:(id)sender;
-(IBAction)registerButtonPressed:(id)sender;

@property() NSString* name;
@property() NSString* key;

@end
