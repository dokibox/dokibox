//
//  TitlebarView.h
//  fb2kmac
//
//  Created by Miles Wu on 14/08/2012.
//
//

#import "TUIKit.h"
#import <Cocoa/Cocoa.h>
#import "MusicController.h"

typedef void(^NSViewDrawRect)(NSView *, CGRect);

@interface TitlebarViewNS : NSView {
    BOOL _playing;
    MusicController *_musicController;
    
}

-(id)initWithMusicController:(MusicController *)mc;
-(void)initSubviews;
-(NSViewDrawRect)playButtonDrawBlock;
-(NSViewDrawRect)seekButtonDrawBlock;
-(void)playButtonPressed:(id)sender;
-(void)seekButtonPressed:(id)sender;
-(void)updatePlayButtonState:(NSNotification *)notification;
-(void)updatePlayButtonState;

@property MusicController *musicController;


@end
