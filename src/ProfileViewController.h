//
//  ProfileViewController.h
//  dokibox
//
//  Created by Miles Wu on 29/10/2013.
//
//

#import <Cocoa/Cocoa.h>

@class ProfileController;

@interface ProfileViewController : NSViewController {
    ProfileController *_profileController;
    IBOutlet NSTableView *_tableView;
    
    
    IBOutlet NSView *_addSheetView;
    NSPanel *_addSheet;
}

- (id)initWithProfileController:(ProfileController *)pc;

-(IBAction)openButtonPressed:(id)sender;
-(IBAction)addOrRemoveButtonPressed:(id)sender;
-(IBAction)addSheetButtonPressed:(id)sender;

@property() NSString *addName;

@end
