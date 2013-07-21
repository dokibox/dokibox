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
}

- (id)initWithLibrary:(Library *)library;

- (IBAction)locationBrowseButtonAction:(id)sender;

@end
