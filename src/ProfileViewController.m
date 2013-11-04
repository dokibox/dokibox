//
//  ProfileViewController.m
//  dokibox
//
//  Created by Miles Wu on 29/10/2013.
//
//

#import "ProfileViewController.h"
#import "ProfileController.h"

@implementation ProfileViewController

@synthesize addName;

- (id)initWithProfileController:(ProfileController *)pc
{
    self = [self initWithNibName:@"ProfileViewController" bundle:nil];
    if (self) {
        _profileController = pc;
    }
    
    return self;
}
-(IBAction)openButtonPressed:(id)sender
{
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
    }
    
    [sender setSelectedSegment:-1]; // deselect the segmented control
}

-(IBAction)addSheetButtonPressed:(id)sender
{
    [_profileController addProfile:[self addName]];
    
    [NSApp endSheet:_addSheet];
    [_addSheet orderOut:self];
    [_tableView reloadData];
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
