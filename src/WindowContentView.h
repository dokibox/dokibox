//
//  WindowContentView.h
//  dokibox
//
//  Created by Miles Wu on 05/07/2013.
//
//

#import <Cocoa/Cocoa.h>
#import "PlaylistView.h"

@class LibraryView;
@class TitlebarButtonNS;
@class Library;

@interface WindowContentView : NSView {
    CGFloat width_divider;
    PlaylistView *_playlistView;
    LibraryView *_libraryView;
    
    TitlebarButtonNS *_searchButton;
    TitlebarButtonNS *_togglePlaylistButton;
    
    NSTrackingArea *_dividerTrackingArea;
    BOOL _dividerBeingDragged;
}

- (id)initWithFrame:(CGRect)frame andLibrary:(Library *)library;

-(NSRect)playlistViewFrame;
-(NSRect)libraryViewFrame;
- (void)redisplay;

-(NSViewDrawRect)togglePlaylistButtonDrawRect;
-(void)togglePlaylistButtonPressed:(id)sender;

-(NSViewDrawRect)newPlaylistButtonDrawRect;
-(void)newPlaylistButtonPressed:(id)sender;

-(NSViewDrawRect)searchButtonDrawRect;
-(void)searchButtonPressed:(id)sender;
-(void)performFindPanelAction:(id)sender;

@property(readonly) PlaylistView *playlistView;

@end
