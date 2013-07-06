//
//  WindowContentView.h
//  fb2kmac
//
//  Created by Miles Wu on 05/07/2013.
//
//

#import <Cocoa/Cocoa.h>
#import "PlaylistView.h"

@interface WindowContentView : NSView {
    CGFloat width_divider;
    PlaylistView *_playlistView;
}
- (void)redisplay;

@property(readonly) PlaylistView *playlistView;

@end
