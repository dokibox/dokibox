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

typedef void(^NSViewDrawRect)(NSView *, CGRect);

@interface WindowContentView : NSView {
    CGFloat width_divider;
    PlaylistView *_playlistView;
    LibraryView *_libraryView;
    
    TitlebarButtonNS *_searchButton;
}

-(NSRect)playlistViewFrame;
-(NSRect)libraryViewFrame;
-(void)relayout;
- (void)redisplay;

-(NSViewDrawRect)newPlaylistButtonDrawRect;
-(void)newPlaylistButtonPressed:(id)sender;

-(NSViewDrawRect)searchButtonDrawRect;
-(void)searchButtonPressed:(id)sender;
-(void)performFindPanelAction:(id)sender;

@property(readonly) PlaylistView *playlistView;

@end
