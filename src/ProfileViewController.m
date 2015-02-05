//
//  ProfileViewController.m
//  dokibox
//
//  Created by Miles Wu on 29/10/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileController.h"

@implementation ProfileViewController

@synthesize addName;

- (id)init
{
    self = [self initWithNibName:@"ProfileViewController" bundle:nil];
    if (self) {
        _profileController = [ProfileController sharedInstance];
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[_profileController currentProfileIndex]] byExtendingSelection:NO];
    [self updateOpenButtonEnabled];
}

-(IBAction)openButtonPressed:(id)sender
{
    [_profileController setCurrentProfileToIndex:[_tableView selectedRow]];
    if([_defaultCheck state] == 1)
        [_profileController setDefaultProfileToIndex:[_tableView selectedRow]];
    [[NSApplication sharedApplication] stopModalWithCode:0];
}

-(IBAction)addOrRemoveButtonPressed:(id)sender
{
    if([sender selectedSegment] == 0) { //add
        _addSheet = [[NSPanel alloc] initWithContentRect:NSMakeRect(0,0,315,96) styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO];
        [_addSheet setContentView:_addSheetView];
        NSWindow *w = [[self view] window];
        [NSApp beginSheet:_addSheet modalForWindow:w modalDelegate:nil didEndSelector:nil contextInfo:nil];
    }
    else if([sender selectedSegment] == 1) { //remove
        if([_tableView selectedRow] != -1) {
            [_profileController removeProfileAtIndex:[_tableView selectedRow]];
            [_tableView reloadData];
            [self updateOpenButtonEnabled];
        }
    }
    
    [sender setSelectedSegment:-1]; // deselect the segmented control
}

-(IBAction)addSheetButtonPressed:(id)sender
{
    if([sender tag] == 0) { // Add
        [_profileController addProfile:[self addName]];
        [_tableView reloadData];
        [self updateOpenButtonEnabled];
    }
    else { // Cancel
    }
    
    [NSApp endSheet:_addSheet];
    [_addSheet orderOut:self];
}

-(void)updateOpenButtonEnabled
{
    if([_tableView numberOfRows] > 0 && [_tableView selectedRow] != -1)
        [_openButton setEnabled:YES];
    else
        [_openButton setEnabled:NO];
}


#pragma mark Profile table view data source methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [_profileController numberOfProfiles];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return [[_profileController profileAtIndex:rowIndex] objectForKey:@"name"];
}


@end
