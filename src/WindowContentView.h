//
//  WindowContentView.h
//  dokibox
//
//  Created by Miles Wu on 05/07/2013.
//
//

#import <Cocoa/Cocoa.h>
#import "PlaylistView.h"

typedef void(^NSViewDrawRect)(NSView *, CGRect);

@interface WindowContentView : NSView {
    CGFloat width_divider;
    PlaylistView *_playlistView;
    TUINSView *_twuiNSViewLibrary;
}

-(NSRect)playlistViewFrame;
-(NSRect)libraryViewFrame;
-(void)relayout;
- (void)redisplay;
-(NSViewDrawRect)newPlaylistButtonDrawRect;
-(void)newPlaylistButtonPressed:(id)sender;

@property(readonly) PlaylistView *playlistView;

@end
