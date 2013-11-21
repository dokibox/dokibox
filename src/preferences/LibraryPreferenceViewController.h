//
//  LibraryPreferenceViewController.h
//  dokibox
//
//  Created by Miles Wu on 22/06/2013.
//
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"
#import "Library.h"

@interface LibraryPreferenceViewController : NSViewController {
    Library *_library;
    IBOutlet NSTableView *_tableView;
}

- (id)initWithLibrary:(Library *)library;

- (IBAction)addRemoveButtonAction:(id)sender;

@end
