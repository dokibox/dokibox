//
//  TitlebarView.m
//  fb2kmac
//
//  Created by Miles Wu on 14/08/2012.
//
//

#import "TitlebarViewNS.h"
#import "TitlebarButtonNS.h"


@implementation TitlebarViewNS
@synthesize musicController = _musicController;

- (id)initWithMusicController:(MusicController *)mc {
    if(self = [super init]) {
        _musicController = mc;
        if([mc status] == MusicControllerIdle)
            _playing = false;
        
        TitlebarButtonNS *b = [[TitlebarButtonNS alloc] initWithFrame:NSMakeRect(150, 6, 28, 28)];
        [b setButtonType:NSMomentaryLightButton];
        [b setTarget:self];
        [b setAction:@selector(playButtonPressed:)];
        
        [b setDrawIcon: [self playButtonDrawBlock]];
        
        [self addSubview:b];
    }
    return self;
}

- (void)drawRect:(NSRect)rect
{
    CGRect b = [self bounds];
	CGContextRef ctx = TUIGraphicsGetCurrentContext();

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
        gradientStartColor = [TUIColor colorWithWhite:0.71 alpha:1.0];
        gradientEndColor = [TUIColor colorWithWhite:0.90 alpha:1.0];
    }
    else {
        gradientStartColor = [TUIColor colorWithWhite:0.80 alpha:1.0];
        gradientEndColor = [TUIColor colorWithWhite:0.86 alpha:1.0];
    }
    
    NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                       (id)[gradientEndColor CGColor], nil];
    CGFloat locations[] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);
    
    CGContextDrawLinearGradient(ctx, gradient, CGPointMake(b.origin.x, b.origin.y), CGPointMake(b.origin.x, b.origin.y+b.size.height), 0);
    CGContextRestoreGState(ctx);

    CGGradientRelease(gradient);    
    
    [super drawRect:b];
}

-(NSViewDrawRect)playButtonDrawBlock
{
    return ^(NSView *v, CGRect rect) {
        CGContextRef ctx = TUIGraphicsGetCurrentContext();
        CGRect b = v.bounds;
        CGPoint middle = CGPointMake(CGRectGetMidX(b), CGRectGetMidY(b));
        CGContextSaveGState(ctx);

        float size = 9.0;
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
                CGPointMake(middle.x - size*0.5, middle.y - size*sqrt(3.0)*0.5),
                CGPointMake(middle.x - size*0.5, middle.y + size*sqrt(3.0)*0.5),
                CGPointMake(middle.x + size, middle.y)
            };
            CGContextAddLines(ctx, playPoints, 4);
            gradient_height = size*sqrt(3.0)*0.5;
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

-(void)playButtonPressed:(id)sender
{
    _playing = !_playing;
    TitlebarButtonNS *b = sender;
    NSLog(@"button pressed: %@", [_musicController className]);
    //NSLog(@"button pressed: %@", [[[[self window] contentView] rootView] className]);
}

@end
