//
//  LibraryPreferenceViewController.m
//  dokibox
//
//  Created by Miles Wu on 22/06/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "LibraryPreferenceViewController.h"
#import "LibraryMonitoredFolder.h"
#import "NSFont+DokiboxAdditions.h"

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
    CGRect bounds = CGRectMake(0, 0, 64, 64);
    NSImage *libraryImage = [[NSImage alloc] initWithSize:bounds.size];
    [libraryImage lockFocus];

    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];

    CGContextSetRGBFillColor(context, 0.22, 0.22, 0.22, 1);
    CGContextSetLineWidth(context, 0);

    CGContextMoveToPoint(context, 6, 50);
    CGContextAddLineToPoint(context, 6, 57);
    CGContextAddLineToPoint(context, 18, 57);
    CGContextAddLineToPoint(context, 20, 54);
    CGContextAddLineToPoint(context, 58, 54);
    CGContextAddLineToPoint(context, 58, 50);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);

    CGContextSetRGBFillColor(context, 0.33, 0.33, 0.33, 1);
    CGContextMoveToPoint(context, 20, 52);
    CGContextAddLineToPoint(context, 18, 50);
    CGContextAddLineToPoint(context, 6, 50);
    CGContextAddLineToPoint(context, 6, 8);
    CGContextAddLineToPoint(context, 58, 8);
    CGContextAddLineToPoint(context, 58, 52);
    CGContextClosePath(context);

    CGContextMoveToPoint(context, 42.37, 23.83);
    CGContextAddCurveToPoint(context, 42.37, 22.18, 42.16, 20.95, 41.73, 20.14);
    CGContextAddCurveToPoint(context, 41.3, 19.34, 40.57, 18.7, 39.55, 18.23);
    CGContextAddCurveToPoint(context, 38.52, 17.77, 37.36, 17.58, 36.07, 17.69);
    CGContextAddCurveToPoint(context, 34.59, 17.8, 33.41, 18.31, 32.53, 19.21);
    CGContextAddCurveToPoint(context, 31.65, 20.12, 31.2, 21.23, 31.21, 22.55);
    CGContextAddCurveToPoint(context, 31.21, 23.88, 31.73, 24.99, 32.78, 25.88);
    CGContextAddCurveToPoint(context, 33.83, 26.76, 35.18, 27.14, 36.84, 27.01);
    CGContextAddCurveToPoint(context, 37.38, 26.97, 37.86, 26.88, 38.27, 26.76);
    CGContextAddCurveToPoint(context, 38.46, 26.7, 38.71, 26.6, 39, 26.48);
    CGContextAddLineToPoint(context, 39, 40.06);
    CGContextAddLineToPoint(context, 28.19, 37.61);
    CGContextAddLineToPoint(context, 28.17, 20.89);
    CGContextAddCurveToPoint(context, 28.17, 19.27, 27.95, 18.03, 27.51, 17.17);
    CGContextAddCurveToPoint(context, 27.08, 16.3, 26.33, 15.64, 25.27, 15.19);
    CGContextAddCurveToPoint(context, 24.21, 14.74, 23.05, 14.57, 21.8, 14.66);
    CGContextAddCurveToPoint(context, 20.32, 14.78, 19.15, 15.28, 18.29, 16.17);
    CGContextAddCurveToPoint(context, 17.43, 17.06, 17, 18.16, 17, 19.48);
    CGContextAddCurveToPoint(context, 17, 20.88, 17.52, 22.02, 18.55, 22.89);
    CGContextAddCurveToPoint(context, 19.59, 23.77, 20.94, 24.14, 22.61, 24.01);
    CGContextAddCurveToPoint(context, 23.35, 23.95, 24.15, 23.73, 25, 23.36);
    CGContextAddLineToPoint(context, 25, 41);
    CGContextAddLineToPoint(context, 25, 42.1);
    CGContextAddLineToPoint(context, 42.19, 45.95);
    CGContextAddLineToPoint(context, 42.4, 46);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);

    [libraryImage unlockFocus];
    return libraryImage;
}

- (NSString *)toolbarItemLabel
{
    return @"Library";
}

#pragma mark Library folder table methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [_library numberOfMonitoredFolders];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    LibraryMonitoredFolder *folder = [_library monitoredFolderAtIndex:rowIndex];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[folder path]];
    if([folder isOnNetworkMount]) {
        NSDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:[NSFont italicSystemFontOfSize:10] forKey:NSFontAttributeName];
        [dict setValue:[NSNumber numberWithFloat:1.25] forKey:NSBaselineOffsetAttributeName];
        NSMutableAttributedString *warningStr = [[NSMutableAttributedString alloc] initWithString:@"            [network mount: monitoring may not work]" attributes:dict];
        [str appendAttributedString:warningStr];
    }
    return str;
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
                NSString *err;
                if((err = [_library addMonitoredFolderWithPath:path])) {
                    NSAlert *alert = [NSAlert alertWithMessageText:@"Error adding new monitored folder" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", err];
                    [alert beginSheetModalForWindow:[[self view] window] completionHandler:nil];
                }
                [_tableView reloadData];
            }
        }];
    }
    else if([sender selectedSegment] == 1) { //remove
        if([_tableView selectedRow] != -1) {
            NSString *err;
            if((err = [_library removeMonitoredFolderAtIndex:[_tableView selectedRow]])) {
                NSAlert *alert = [NSAlert alertWithMessageText:@"Error removing monitored folder" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", err];
                [alert beginSheetModalForWindow:[[self view] window] completionHandler:nil];
            }
            [_tableView reloadData];
        }
    }
    else if([sender selectedSegment] == 3) { //refresh
        if([_tableView selectedRow] != -1) {
            [_library refreshMonitoredFolderAtIndex:[_tableView selectedRow]];
        }
    }

    [sender setSelectedSegment:-1]; // deselect the segmented control
}

@end
