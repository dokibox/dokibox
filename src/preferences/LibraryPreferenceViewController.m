//
//  LibraryPreferenceViewController.m
//  dokibox
//
//  Created by Miles Wu on 22/06/2013.
//
//

#import "LibraryPreferenceViewController.h"

@implementation LibraryPreferenceViewController

- (id)initWithLibrary:(Library *)library
{
    self = [super init];
    if (self) {
        _library = library;
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

- (IBAction)locationBrowseButtonAction:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel beginSheetModalForWindow:[[self view] window] completionHandler:^(NSInteger result) {
        if(result == NSFileHandlingPanelOKButton) {
            NSString *path = [[openPanel directoryURL] path];
            [[NSUserDefaults standardUserDefaults] setValue:path forKey:@"libraryLocation"];
            [_library reset];
            [_library startFSMonitor];
        }
    }];
}

@end
