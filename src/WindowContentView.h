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
    CGFloat _titlebarSize;
    PlaylistView *_playlistView;
    LibraryView *_libraryView;
    
    TitlebarButtonNS *_searchButton;
    TitlebarButtonNS *_togglePlaylistButton;
    TitlebarButtonNS *_repeatButton;
    TitlebarButtonNS *_shuffleButton;
    
    NSTrackingArea *_dividerTrackingArea;
    BOOL _dividerBeingDragged;
}

- (id)initWithFrame:(CGRect)frame andLibrary:(Library *)library titlebarSize:(CGFloat)titlebarSize;

-(NSRect)playlistViewFrame;
-(NSRect)libraryViewFrame;
- (void)redisplay;

-(NSViewDrawRect)togglePlaylistButtonDrawRect;
-(void)togglePlaylistButtonPressed:(id)sender;

-(NSViewDrawRect)repeatButtonDrawRect;
-(void)repeatButtonPressed:(id)sender;
-(NSViewDrawRect)shuffleButtonDrawRect;
-(void)shuffleButtonPressed:(id)sender;

-(NSViewDrawRect)newPlaylistButtonDrawRect;
-(void)newPlaylistButtonPressed:(id)sender;

-(NSViewDrawRect)searchButtonDrawRect;
-(void)searchButtonPressed:(id)sender;
-(void)performFindPanelAction:(id)sender;

@property(readonly) PlaylistView *playlistView;

@end
