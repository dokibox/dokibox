//
//  LibraryPreferenceViewController.m
//  dokibox
//
//  Created by Miles Wu on 22/06/2013.
//
//

#import "LibraryPreferenceViewController.h"
#import "LibraryFolder.h"

@implementation LibraryPreferenceViewController

- (id)initWithLibrary:(Library *)library
{
    self = [self initWithNibName:@"LibraryPreferenceViewController" bundle:nil];
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

#pragma mark Library folder table methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [_library numberOfFolders];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    LibraryFolder *folder = [_library folderAtIndex:rowIndex];
    return [folder path];
}

- (IBAction)addRemoveButtonAction:(id)sender
{
    if([sender selectedSegment] == 0) { //add
        NSOpenPanel *openPanel = [NSOpenPanel openPanel];
        [openPanel setCanChooseFiles:NO];
        [openPanel setCanChooseDirectories:YES];
        [openPanel beginSheetModalForWindow:[[self view] window] completionHandler:^(NSInteger result) {
            if(result == NSFileHandlingPanelOKButton) {
                NSString *path = [[openPanel directoryURL] path];
                [_library addFolderWithPath:path];
                [_tableView reloadData];
            }
        }];
    }
    else if([sender selectedSegment] == 1) { //remove
        if([_tableView selectedRow] != -1) {
            //[_profileController removeProfileAtIndex:[_tableView selectedRow]];
            [_tableView reloadData];
        }
    }
    
    [sender setSelectedSegment:-1]; // deselect the segmented control
}

@end
