//
//  TitlebarView.m
//  dokibox
//
//  Created by Miles Wu on 14/08/2012.
//
//

#import "TitlebarViewNS.h"
#import "TitlebarButtonNS.h"
#import "TitlebarSeekButtonNS.h"
#import "PlaylistView.h"
#import "Playlist.h"
#import "WindowContentView.h"

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
        _title = @"";
        _artist = @"";


        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPlaybackProgressNotification:) name:@"playbackProgress" object:nil];

    }
    return self;
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
    [c setDrawIcon: [self seekButtonDrawBlock:[c getType]]];

    TitlebarSeekButtonNS *d = [[TitlebarSeekButtonNS alloc] initWithFrame:NSMakeRect(rightedge-2*gap, height, size, size)];
    [d setAutoresizingMask:NSViewMinXMargin];
    [d setButtonType:NSMomentaryLightButton];
    [d setTarget:self];
    [d setType:RWSeekButton];
    [d setAction:@selector(prevButtonPressed:)];
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
    [self addSubview:_progressBar];


    // Create Volume Bar
    CGRect volumeBarRect = NSMakeRect(rightedge-2*gap, 5.0, 90.0, 7.0);
    _volumeBar = [[SliderBar alloc] initWithFrame:volumeBarRect];
    [_volumeBar setAutoresizingMask:NSViewMinXMargin];
    [_volumeBar setPercentage:[_musicController volume]];
    [_volumeBar setDrawHandle:YES];
    [_volumeBar setMovable:YES];
    [_volumeBar setDelegate:self];
    [self addSubview:_volumeBar];
}

-(void)updatePlayButtonState:(NSNotification *)notification
{
    [self updatePlayButtonState];
}

-(void)updatePlayButtonState
{
    if([_musicController status] == MusicControllerPlaying)
        _playing = true;
    else
        _playing = false;

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

- (void)drawRect:(NSRect)rect
{
    CGRect b = [self bounds];
	CGContextRef ctx = TUIGraphicsGetCurrentContext();

    // Draw titlebar itself
    int isActive = [[self window] isMainWindow] && [[NSApplication sharedApplication] isActive];

    float r = 4;
    CGContextMoveToPoint(ctx, NSMinX(b), NSMinY(b));
    CGContextAddLineToPoint(ctx, NSMinX(b), NSMaxY(b)-r);
    CGContextAddArcToPoint(ctx, NSMinX(b), NSMaxY(b), NSMinX(b)+r, NSMaxY(b), r);
    CGContextAddLineToPoint(ctx, NSMaxX(b)-r, NSMaxY(b));
    CGContextAddArcToPoint(ctx, NSMaxX(b), NSMaxY(b), NSMaxX(b), NSMaxY(b)-r, r);
    CGContextAddLineToPoint(ctx, NSMaxX(b), NSMinY(b));
    CGContextAddLineToPoint(ctx, NSMinX(b), NSMinY(b));
    CGContextSaveGState(ctx);
    CGContextClip(ctx);

    TUIColor *gradientStartColor, *gradientEndColor;
    if(isActive) {
        gradientStartColor = [TUIColor colorWithWhite:0.62 alpha:1.0];
        gradientEndColor = [TUIColor colorWithWhite:0.90 alpha:1.0];
    }
    else {
        gradientStartColor = [TUIColor colorWithWhite:0.80 alpha:1.0];
        gradientEndColor = [TUIColor colorWithWhite:0.80 alpha:1.0];
    }

    NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                       (id)[gradientEndColor CGColor], nil];
    CGFloat locations[] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);

    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(b.origin.x, b.origin.y), CGPointMake(b.origin.x, b.origin.y+b.size.height), 0);
    CGContextRestoreGState(ctx);

    CGGradientRelease(gradient);

    // Draw our text
    CGFloat topmargin = 20.0;
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    [attr setObject:[NSFont fontWithName:@"Lucida Grande" size:12] forKey:NSFontAttributeName];

    NSAttributedString *title = [[NSAttributedString alloc] initWithString:_title attributes:attr];
    NSAttributedString *spacing = [[NSAttributedString alloc] initWithString:@" - " attributes:attr];

    NSMutableDictionary *boldattr = [NSMutableDictionary dictionaryWithDictionary:attr];
    [boldattr setObject:[NSFont fontWithName:@"Lucida Grande Bold" size:12] forKey:NSFontAttributeName];
    NSAttributedString *artist = [[NSAttributedString alloc] initWithString:_artist attributes:boldattr];

    NSMutableAttributedString *titlebarText = [[NSMutableAttributedString alloc] init];
    [titlebarText appendAttributedString:artist];
    [titlebarText appendAttributedString:spacing];
    [titlebarText appendAttributedString:title];

    NSSize textSize = [titlebarText size];

    NSPoint textPoint = NSMakePoint(b.origin.x + b.size.width/2.0 - textSize.width/2.0, b.origin.y + b.size.height - topmargin);
    [titlebarText drawAtPoint:textPoint];

    // Progress bar stuff
    float timeElapsed = 0;
    float timeTotal = 0;
    if(_progressDict) {
        timeElapsed = [(NSNumber *)[_progressDict objectForKey:@"timeElapsed"] floatValue];
        timeTotal = [(NSNumber *)[_progressDict objectForKey:@"timeTotal"] floatValue];
    }

    NSString *timeElapsedString = [[NSString alloc] initWithFormat:@"%02d:%02d", (int)(timeElapsed/60.0), (int)timeElapsed%60];
    NSString *timeTotalString = [[NSString alloc] initWithFormat:@"%02d:%02d", (int)(timeTotal/60.0), (int)timeTotal%60];

    NSMutableDictionary *progressBarTextAttr = [NSMutableDictionary dictionary];
    [progressBarTextAttr setObject:[NSFont fontWithName:@"Lucida Grande" size:9] forKey:NSFontAttributeName];
    NSAttributedString *timeElapsedAttrString = [[NSAttributedString alloc] initWithString:timeElapsedString attributes:progressBarTextAttr];
    NSAttributedString *timeTotalAttrString = [[NSAttributedString alloc] initWithString:timeTotalString attributes:progressBarTextAttr];

    NSPoint timeElapsedStringPoint = [_progressBar frame].origin;
    NSSize timeElapsedStringSize = [timeElapsedAttrString size];
    timeElapsedStringPoint.y -= 2;
    timeElapsedStringPoint.x -= timeElapsedStringSize.width + 5;
    [timeElapsedAttrString drawAtPoint:timeElapsedStringPoint];

    NSPoint timeTotalStringPoint = [_progressBar frame].origin;
    timeTotalStringPoint.y -= 2;
    timeTotalStringPoint.x += [_progressBar frame].size.width + 5;
    [timeTotalAttrString drawAtPoint:timeTotalStringPoint];
}

-(void)receivedStartedPlaybackNotification:(NSNotification *)notification
{
    PlaylistTrack *t = [notification object];
    _title = [[t attributes] objectForKey:@"TITLE"];
    _title = _title == nil ? @"" : _title;
    _artist = [[t attributes] objectForKey:@"ARTIST"];
    _artist = _artist == nil ? @"" : _artist;
    [self setNeedsDisplay:YES];

}

-(NSViewDrawRect)playButtonDrawBlock
{
    return ^(NSView *v, CGRect rect) {
        CGContextRef ctx = TUIGraphicsGetCurrentContext();
        CGRect b = v.bounds;
        CGPoint middle = CGPointMake(CGRectGetMidX(b), CGRectGetMidY(b));
        CGContextSaveGState(ctx);

        float size = 8.0;
        float gradient_height;

        if(_playing) {
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
        TUIColor *gradientEndColor = [TUIColor colorWithWhite:0.15 alpha:1.0];
        TUIColor *gradientStartColor = [TUIColor colorWithWhite:0.45 alpha:1.0];

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
        CGContextRef ctx = TUIGraphicsGetCurrentContext();
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

        TUIColor *gradientEndColor = [TUIColor colorWithWhite:0.15 alpha:1.0];
        TUIColor *gradientStartColor = [TUIColor colorWithWhite:0.45 alpha:1.0];

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
{
    if(_playing) {
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
    WindowContentView *wv = (WindowContentView *)[[self window] contentView];
    Playlist *p = [[wv playlistView] currentPlaylist];
    NSUInteger trackIndex = [p getTrackIndex:[_musicController getCurrentTrack]];
    [_musicController stop];
    NSLog(@"%lu",trackIndex);
    if(trackIndex != NSNotFound && trackIndex != 0) {
        NSLog(@"Next song.");
        [p playTrackAtIndex:--trackIndex];
    }
}

-(void)nextButtonPressed:(id)sender {
    WindowContentView *wv = (WindowContentView *)[[self window] contentView];
    Playlist *p = [[wv playlistView] currentPlaylist];
    NSUInteger trackIndex = [p getTrackIndex:[_musicController getCurrentTrack]];
    [_musicController stop];
    NSLog(@"%lu",trackIndex);
    if(trackIndex != NSNotFound && trackIndex != [p numberOfTracks]-1) {
        NSLog(@"Next song.");
        [p playTrackAtIndex:++trackIndex];
    }
}

-(void)receivedPlaybackProgressNotification:(NSNotification *)notification
{
    _progressDict = (NSDictionary *)[notification object];

    float timeElapsed = [(NSNumber *)[_progressDict objectForKey:@"timeElapsed"] floatValue];
    float timeTotal = [(NSNumber *)[_progressDict objectForKey:@"timeTotal"] floatValue];
    [_progressBar setPercentage:timeElapsed/timeTotal];
    [self setNeedsDisplay:YES];
}

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
    else if([notification object] == _progressBar) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"seekTrack" object:percentage];
    }
}


@end
