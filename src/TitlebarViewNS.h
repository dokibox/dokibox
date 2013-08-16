//
//  TitlebarView.h
//  dokibox
//
//  Created by Miles Wu on 14/08/2012.
//
//

#import <Cocoa/Cocoa.h>
#import "MusicController.h"
#import "PlaylistTrack.h"
#import "SliderBar.h"

typedef void(^NSViewDrawRect)(NSView *, CGRect);
@class SPMediaKeyTap;

@interface TitlebarViewNS : NSView <SliderBarDelegate> {
    BOOL _playing;
    MusicController *_musicController;

    NSString *_title;
    NSString *_artist;

    SliderBar *_progressBar;
    NSDictionary *_progressDict;

    SliderBar *_volumeBar;
    
    SPMediaKeyTap *_keyTap;
}

-(id)initWithMusicController:(MusicController *)mc;
-(void)initSubviews;
-(NSViewDrawRect)playButtonDrawBlock;
-(NSViewDrawRect)seekButtonDrawBlock;
-(void)playButtonPressed:(id)sender;
-(void)seekButtonPressed:(id)sender;
-(void)updatePlayButtonState:(NSNotification *)notification;
-(void)updatePlayButtonState;

-(void)receivedStartedPlaybackNotification:(NSNotification *)notification;
-(void)receivedPlaybackProgressNotification:(NSNotification *)notification;

@property MusicController *musicController;


@end
