//
//  LibraryNoTracksView.m
//  dokibox
//
//  Created by Miles Wu on 23/11/2014.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "LibraryNoTracksView.h"

@implementation LibraryNoTracksView

- (id)initWithFrame:(NSRect)frame
{
    if((self = [super initWithFrame:frame])) {
        NSRect b = [self bounds];
        
        // Text that is displayed when there are no tracks in the library
        NSMutableAttributedString *noTracksAttributedString = [[NSMutableAttributedString alloc] initWithString:@"Library contains zero tracks.\n"];
        [noTracksAttributedString addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:14] range:NSMakeRange(0, [noTracksAttributedString length])];
        {
            NSDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setValue:[[NSFontManager sharedFontManager] convertFont:[NSFont systemFontOfSize:10] toHaveTrait:NSItalicFontMask] forKey:NSFontAttributeName];
            [dict setValue:[NSColor colorWithCalibratedWhite:0.35 alpha:1.0] forKey:NSForegroundColorAttributeName];
            NSMutableAttributedString *subStr = [[NSMutableAttributedString alloc] initWithString:@"Have you set up your monitored folders?" attributes:dict];
            [noTracksAttributedString appendAttributedString:subStr];
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setAlignment:NSCenterTextAlignment];
            [noTracksAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [noTracksAttributedString length])];
        }

        // Text field
        float textHeight = 50;
        float textMargin = 5;
        NSTextField *noTracksMessageTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(textMargin, b.size.height-textHeight, b.size.width-textMargin*2, textHeight)];
        [noTracksMessageTextField setAttributedStringValue:noTracksAttributedString];
        [noTracksMessageTextField setEditable:NO];
        [noTracksMessageTextField setBordered:NO];
        [noTracksMessageTextField setBezeled:NO];
        [noTracksMessageTextField setDrawsBackground:NO];
        [noTracksMessageTextField setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
        [self addSubview:noTracksMessageTextField];
        
        // Button that is displayed when there are no tracks in the library to open the preferences
        NSButton *libraryPreferencesButton = [[NSButton alloc] initWithFrame:NSZeroRect];
        [libraryPreferencesButton setBezelStyle:NSTexturedRoundedBezelStyle];
        [libraryPreferencesButton setTitle:@"Preferences"];
        [libraryPreferencesButton setTarget:[[NSApplication sharedApplication] delegate]];
        [libraryPreferencesButton setAction:@selector(openPreferences:)];
        [libraryPreferencesButton sizeToFit];
        [libraryPreferencesButton setFrameOrigin:NSMakePoint(NSMidX(b) - [libraryPreferencesButton frame].size.width/2, 0)];
        [libraryPreferencesButton setAutoresizingMask:NSViewMaxYMargin | NSViewMinXMargin | NSViewMaxXMargin];
        [self addSubview:libraryPreferencesButton];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
