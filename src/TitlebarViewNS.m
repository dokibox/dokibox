//
//  TitlebarView.m
//  dokibox
//
//  Created by Miles Wu on 14/08/2012.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "TitlebarViewNS.h"
#import "TitlebarButtonNS.h"
#import "TitlebarSeekButtonNS.h"
#import "PlaylistView.h"
#import "Playlist.h"
#import "WindowContentView.h"
#import "SPMediaKeyTap.h"

@implementation TitlebarViewNS
@synthesize musicController = _musicController;

- (id)initWithMusicController:(MusicController *)mc{
    if(self = [super init]) {
        _musicController = mc;
        [self updatePlayButtonState];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlayButtonState:) name:@"startedPlayback" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlayButtonState:) name:@"stoppedPlayback" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlayButtonState:) name:@"unpausedPlayback" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlayButtonState:) name:@"pausedPlayback" object:nil];

        self.autoresizesSubviews = YES;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedStartedPlaybackNotification:) name:@"startedPlayback" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedStoppedPlaybackNotification:) name:@"stoppedPlayback" object:nil];
        _title = @"";
        _artist = @"";


        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPlaybackProgressNotification:) name:@"playbackProgress" object:nil];

        // Media keys initialization
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
            [SPMediaKeyTap defaultMediaKeyUserBundleIdentifiers], kMediaKeyUsingBundleIdentifiersDefaultsKey,
            nil]];
        _keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
        if([SPMediaKeyTap usesGlobalMediaKeyTap])
            [_keyTap startWatchingMediaKeys]; //Remember to disable this when using gdb breakpoints
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"startedPlayback" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"startedPlayback" object:nil]; duplicated for matching 1:1 add/remove
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stoppedPlayback" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"stoppedPlayback" object:nil]; duplicated for matching 1:1 add/remove
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"unpausedPlayback" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pausedPlayback" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"playbackProgress" object:nil];
}

-(void)initSubviews {
    // Right side buttons
    CGFloat rightedge = [self bounds].size.width - 35;
    CGFloat gap = 30.0;

    CGFloat size = 28.0;
    CGFloat height = 15.0;
    TitlebarButtonNS *b = [[TitlebarButtonNS alloc] initWithFrame:NSMakeRect(rightedge-gap, height, size, size)];
    [b setAutoresizingMask:NSViewMinXMargin];
    [b setButtonType:NSMomentaryLightButton];
    [b setTarget:self];
    [b setAction:@selector(playButtonPressed:)];
    [b setDrawIcon: [self playButtonDrawBlock]];

    TitlebarSeekButtonNS *c = [[TitlebarSeekButtonNS alloc] initWithFrame:NSMakeRect(rightedge, height, size, size)];
    [c setAutoresizingMask:NSViewMinXMargin];
    [c setButtonType:NSMomentaryLightButton];
    [c setTarget:self];
    [c setType:FFSeekButton];
    [c setAction:@selector(nextButtonPressed:)];
    [c setHeldAction:@selector(seekButtonHeld:)];
    [c setDrawIcon: [self seekButtonDrawBlock:[c getType]]];

    TitlebarSeekButtonNS *d = [[TitlebarSeekButtonNS alloc] initWithFrame:NSMakeRect(rightedge-2*gap, height, size, size)];
    [d setAutoresizingMask:NSViewMinXMargin];
    [d setButtonType:NSMomentaryLightButton];
    [d setTarget:self];
    [d setType:RWSeekButton];
    [d setAction:@selector(prevButtonPressed:)];
    [d setHeldAction:@selector(seekButtonHeld:)];
    [d setDrawIcon: [self seekButtonDrawBlock:[d getType]]];

    [self addSubview:b];
    [self addSubview:c];
    [self addSubview:d];


    // Create Progress Bar
    CGFloat sliderbarMargin = 150.0;
    CGRect progressBarRect = [self bounds];
    progressBarRect.origin.x += sliderbarMargin;
    progressBarRect.size.width -= 2.0*sliderbarMargin;
    progressBarRect.origin.y = 5.0;
    progressBarRect.size.height = 7.0;

    _progressBar = [[SliderBar alloc] initWithFrame:progressBarRect];
    [_progressBar setAutoresizingMask:NSViewWidthSizable];
    [_progressBar setDelegate:self];
    [_progressBar setDragable:YES];
    [self addSubview:_progressBar];
    
    // Create Progress text
    NSRect progressElapsedFrame = NSMakeRect(progressBarRect.origin.x-40-5, progressBarRect.origin.y-5, 40, progressBarRect.size.height+7);
    _progressElapsedTextField = [[NSTextField alloc] initWithFrame:progressElapsedFrame];
    [_progressElapsedTextField setEditable:NO];
    [_progressElapsedTextField setBordered:NO];
    [_progressElapsedTextField setBezeled:NO];
    [_progressElapsedTextField setDrawsBackground:NO];
    [_progressElapsedTextField setFont:[NSFont labelFontOfSize:9]];
    [_progressElapsedTextField setAlignment:NSRightTextAlignment];
    [_progressElapsedTextField setStringValue:@"00:00"];
    [self addSubview:_progressElapsedTextField];
    
    NSRect progressTotalFrame = NSMakeRect(progressBarRect.origin.x+progressBarRect.size.width+5, progressBarRect.origin.y-5, 40, progressBarRect.size.height+7);
    _progressTotalTextField = [[NSTextField alloc] initWithFrame:progressTotalFrame];
    [_progressTotalTextField setEditable:NO];
    [_progressTotalTextField setBordered:NO];
    [_progressTotalTextField setBezeled:NO];
    [_progressTotalTextField setDrawsBackground:NO];
    [_progressTotalTextField setFont:[NSFont labelFontOfSize:9]];
    [_progressTotalTextField setStringValue:@"00:00"];
    [_progressTotalTextField setAutoresizingMask:NSViewMinXMargin];
    [self addSubview:_progressTotalTextField];

    // Create Volume Bar
    CGRect volumeBarRect = NSMakeRect(rightedge-2*gap, 5.0, 90.0, 7.0);
    _volumeBar = [[SliderBar alloc] initWithFrame:volumeBarRect];
    [_volumeBar setAutoresizingMask:NSViewMinXMargin];
    [_volumeBar setPercentage:[_musicController volume]];
    [_volumeBar setDrawHandle:YES];
    [_volumeBar setMovable:YES];
    [_volumeBar setDragable:YES];
    [_volumeBar setDelegate:self];
    [self addSubview:_volumeBar];
    
    // Create Title bar text
    float titleBarInset = sliderbarMargin;
    NSRect titleBarTextFrame = NSMakeRect([self bounds].origin.x+titleBarInset, [self bounds].size.height-20-4, [self bounds].size.width-2*titleBarInset, 20);
    _titleBarTextField = [[NSTextField alloc] initWithFrame:titleBarTextFrame];
    [_titleBarTextField setAutoresizingMask:NSViewWidthSizable];
    [_titleBarTextField setEditable:NO];
    [_titleBarTextField setBordered:NO];
    [_titleBarTextField setBezeled:NO];
    [_titleBarTextField setDrawsBackground:NO];
    [self updateTitleBarText];
    [self addSubview:_titleBarTextField];
}

-(void)updatePlayButtonState:(NSNotification *)notification
{
    [self updatePlayButtonState];
}

-(void)updatePlayButtonState
{
    if([_musicController status] == MusicControllerStopped) {
        [_progressBar setMovable:NO];
        [_progressBar setHoverable:NO];
    }
    else {
        [_progressBar setMovable:YES];
        [_progressBar setHoverable:YES];
    }

    [self setNeedsDisplay:YES];
}

-(void)receivedStartedPlaybackNotification:(NSNotification *)notification
{
    PlaylistTrack *t = [notification object];
    _title = [t displayName];
    _artist = [t displayArtistName];
    [self updateTitleBarText];
}

-(void)receivedStoppedPlaybackNotification:(NSNotification *)notification
{
    _title = nil;
    _artist = nil;
    [self updateTitleBarText];
}


-(void)updateTitleBarText
{
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    [attr setObject:[NSFont titleBarFontOfSize:12] forKey:NSFontAttributeName];
    NSMutableDictionary *boldattr = [NSMutableDictionary dictionaryWithDictionary:attr];
    [boldattr setObject:[NSFont boldSystemFontOfSize:12] forKey:NSFontAttributeName];
    NSMutableAttributedString *titlebarText = [[NSMutableAttributedString alloc] init];
    
    if([_musicController status] == MusicControllerPlaying || [_musicController status] == MusicControllerPaused) {
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:_title attributes:attr];
        NSAttributedString *spacing = [[NSAttributedString alloc] initWithString:@" - " attributes:attr];
        
        NSAttributedString *artist = [[NSAttributedString alloc] initWithString:_artist attributes:boldattr];
        
        [titlebarText appendAttributedString:artist];
        [titlebarText appendAttributedString:spacing];
        [titlebarText appendAttributedString:title];
    }
    else {
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"dokibox" attributes:attr];
        [titlebarText appendAttributedString:title];
    }
    
    [titlebarText setAlignment:NSCenterTextAlignment range:NSMakeRange(0, [titlebarText length])];
    
    [_titleBarTextField setAttributedStringValue:titlebarText];
}

-(NSViewDrawRect)playButtonDrawBlock
{
    return ^(NSView *v, CGRect rect) {
        CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
        CGRect b = v.bounds;
        CGPoint middle = CGPointMake(CGRectGetMidX(b), CGRectGetMidY(b));
        CGContextSaveGState(ctx);

        float size = 8.0;
        float gradient_height;

        if([_musicController status] == MusicControllerPlaying) {
            float height = size*sqrt(3.0), width = 5, seperation = 3;
            CGPoint middle = CGPointMake(CGRectGetMidX(b), CGRectGetMidY(b));
            CGRect rects[] = {
                CGRectMake(middle.x - seperation/2.0 - width, middle.y - height/2.0, width, height),
                CGRectMake(middle.x + seperation/2.0, middle.y - height/2.0, width, height)
            };
            CGContextClipToRects(ctx, rects, 2);
            gradient_height = height/2.0;
        } else {
            CGPoint playPoints[] =
            {
                CGPointMake(middle.x + size, middle.y),
                CGPointMake(middle.x - size*0.5, middle.y + size*sqrt(3.0)*0.5),
                CGPointMake(middle.x - size*0.5, middle.y - size*sqrt(3.0)*0.5),
                CGPointMake(middle.x + size, middle.y)
            };
            CGAffineTransform trans = CGAffineTransformMakeTranslation(-1,0);
            for (int i=0; i<4; i++) {
                playPoints[i] = CGPointApplyAffineTransform(playPoints[i],trans);
            }
            CGContextAddLines(ctx, playPoints, 4);
            gradient_height = size*sqrt(3)*0.5;
            CGContextClip(ctx);
        }
        NSColor *gradientEndColor = [NSColor colorWithDeviceWhite:0.15 alpha:1.0];
        NSColor *gradientStartColor = [NSColor colorWithDeviceWhite:0.45 alpha:1.0];

        NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                           (id)[gradientEndColor CGColor], nil];
        CGFloat locations[] = { 0.0, 1.0 };
        CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(middle.x, middle.y + gradient_height), CGPointMake(middle.x, middle.y - gradient_height), 0);
        CGGradientRelease(gradient);
        CGContextRestoreGState(ctx);
    };
}

-(NSViewDrawRect)seekButtonDrawBlock:(SeekButtonDirection)buttonType
{
    float h = 3;
    float l = h*sqrt(3);
    float w = 4;
    float gradient_height = h+w*sqrt(2)*0.5;
    CGAffineTransform trans;
    CGAffineTransform trans2;
    if(buttonType == RWSeekButton) {
        trans = CGAffineTransformMakeTranslation(-3.5,0);
        trans2 = CGAffineTransformMakeTranslation(10,0);
    } else {
        trans = CGAffineTransformMakeTranslation(-6,0);
        trans2 = CGAffineTransformMakeTranslation(10,0);
    }
    return ^(NSView *v, CGRect rect) {
        CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
        CGRect c = v.bounds;
        CGPoint middle = CGPointMake(CGRectGetMidX(c), CGRectGetMidY(c));
        CGContextSaveGState(ctx);

        CGPoint seekPoints[] =
        {
            CGPointMake(middle.x, middle.y),
            CGPointMake(middle.x-l, middle.x-h),
            CGPointMake(middle.x-l+w*sqrt(2)*0.5, middle.y-h-w*sqrt(2)*0.5),
            CGPointMake(middle.x+2*w, middle.y),
            CGPointMake(middle.x-l+w*sqrt(2)*0.5, middle.y+h+w*sqrt(2)*0.5),
            CGPointMake(middle.x-l, middle.y+h),
            CGPointMake(middle.x, middle.y)
        };
        CGPoint seekPoints2[7];
        CGAffineTransform mirror;

        if(buttonType == RWSeekButton){
            mirror = CGAffineTransformTranslate(CGAffineTransformMakeScale(-1, 1),-2*middle.x,0);
        } else {
            mirror = CGAffineTransformMakeTranslation(0,0);
        }

        for (int i=0; i<7; i++) {
            seekPoints[i] = CGPointApplyAffineTransform(seekPoints[i],mirror);
            seekPoints[i] = CGPointApplyAffineTransform(seekPoints[i],trans);
            seekPoints2[i] = CGPointApplyAffineTransform(seekPoints[i],trans2);
        }

        CGContextAddLines(ctx, seekPoints, 7);
        CGContextAddLines(ctx, seekPoints2, 7);

        CGContextClip(ctx);

        NSColor *gradientEndColor = [NSColor colorWithDeviceWhite:0.15 alpha:1.0];
        NSColor *gradientStartColor = [NSColor colorWithDeviceWhite:0.45 alpha:1.0];

        NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                           (id)[gradientEndColor CGColor], nil];
        CGFloat locations[] = { 0.0, 1.0 };
        CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

        CGContextDrawLinearGradient(ctx, gradient, CGPointMake(middle.x, middle.y + gradient_height), CGPointMake(middle.x, middle.y - gradient_height), 0);
        CGGradientRelease(gradient);
        CGContextRestoreGState(ctx);
    };
}

-(void)playButtonPressed:(id)sender
// sender can be a SPMediaKeyTap too
{
    if([_musicController status] == MusicControllerPlaying) {
        [_musicController pause];
    }
    else {
        if([_musicController status] == MusicControllerPaused) {
            [_musicController unpause];
        }
        else {
            WindowContentView *wv = (WindowContentView *)[[self window] contentView];
            Playlist *p = [[wv playlistView] currentPlaylist];
            if([p numberOfTracks] > 0) {
                [p playTrackAtIndex:0];
            }
        }
    }
}

-(void)prevButtonPressed:(id)sender {
    // sender can be a SPMediaKeyTap too
    PlaylistTrack *t = [_musicController getCurrentTrack];
    if(t == nil) return; // no current track playing

    // If track is not in first 2.0 seconds, go back to beginning of track
    if([_musicController elapsedSeconds] > 2.0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"seekTrack" object:[NSNumber numberWithFloat:0.0]];
    }
    else { // Otherwise, go to previous track
        Playlist *p = [t playlist];
        if(p == nil) { // orphaned track. stop.
            [_musicController stop];
            return;
        }
        
        [_musicController stop];
        [p playPrevTrackBefore:t];
    }
}

-(void)nextButtonPressed:(id)sender {
    // sender can be a SPMediaKeyTap too
    PlaylistTrack *t = [_musicController getCurrentTrack];
    if(t == nil) return; // no current track playing
    
    Playlist *p = [t playlist];
    if(p == nil) { // orphaned track. stop.
        [_musicController stop];
        return;
    }
    
    [_musicController stop];
    [p playNextTrackAfter:t];
}

-(void)seekButtonHeld:(NSButton *)sender {
    PlaylistTrack *t = [_musicController getCurrentTrack];
    if(t == nil) return; // no current track playing
    [[NSNotificationCenter defaultCenter] postNotificationName:@"seekTrackByJump" object:[NSNumber numberWithInteger:[sender tag]]]; // tag is direction
}


-(void)receivedPlaybackProgressNotification:(NSNotification *)notification
{
    _progressDict = (NSDictionary *)[notification object];

    float timeElapsed = [(NSNumber *)[_progressDict objectForKey:@"timeElapsed"] floatValue];
    float timeTotal = [(NSNumber *)[_progressDict objectForKey:@"timeTotal"] floatValue];
    [_progressBar setPercentage:timeElapsed/timeTotal];
    
    NSString *timeElapsedString = [[NSString alloc] initWithFormat:@"%02d:%02d", (int)(timeElapsed/60.0), (int)timeElapsed%60];
    NSString *timeTotalString = [[NSString alloc] initWithFormat:@"%02d:%02d", (int)(timeTotal/60.0), (int)timeTotal%60];
    
    if([[_progressTotalTextField stringValue] isEqual:timeTotalString] == NO)
        [_progressTotalTextField setStringValue:timeTotalString];
    if([[_progressElapsedTextField stringValue] isEqual:timeElapsedString] == NO)
        [_progressElapsedTextField setStringValue:timeElapsedString];
}

#pragma mark SliderBar delegate methods

-(NSString *)sliderBar:(SliderBar *)sliderBar textForHoverAt:(float)percentage
{
    float timeTotal = 0;
    if(_progressDict) {
        timeTotal = [(NSNumber *)[_progressDict objectForKey:@"timeTotal"] floatValue];
    }
    float time = timeTotal * percentage;
    NSString *str = [[NSString alloc] initWithFormat:@"%02d:%02d", (int)(time/60.0), (int)time%60];

    return str;
}

-(void)sliderBarDidMove:(NSNotification *)notification
{
    NSNumber *percentage = [[notification userInfo] objectForKey:@"percentage"];
    if([notification object] == _volumeBar) {
        [_musicController setVolume:[percentage floatValue]];
    }
}

-(void)sliderBarDidBeginDrag:(NSNotification *)notification
{
    if([notification object] == _progressBar) {
        [_musicController pause];
    }
}

-(void)sliderBarDidEndDrag:(NSNotification *)notification
{
    if([notification object] == _progressBar) {
        [_musicController unpause];
        
        float p = [_progressBar percentage];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"seekTrack" object:[NSNumber numberWithFloat:p]];
    }
}

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event
{
    NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");

    int keyCode = (([event data1] & 0xFFFF0000) >> 16);
    int keyFlags = ([event data1] & 0x0000FFFF);
    BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
    int keyRepeat = (keyFlags & 0x1);

    if (keyIsPressed && !keyRepeat) {
        switch (keyCode) {
            case NX_KEYTYPE_PLAY:
                [self playButtonPressed:keyTap];
                break;

            case NX_KEYTYPE_FAST:
                [self nextButtonPressed:keyTap];
                break;

            case NX_KEYTYPE_REWIND:
                [self prevButtonPressed:keyTap];
                break;

            default:
                DDLogError(@"Unknown media key (keycode %d", keyCode);
                break;
        }
    }
}


@end
