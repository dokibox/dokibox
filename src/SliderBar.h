//
//  SliderBar.h
//  dokibox
//
//  Created by Miles Wu on 11/10/2012.
//
//

#import <Cocoa/Cocoa.h>
#import "SliderBarHoverView.h"

@protocol SliderBarDelegate;

@interface SliderBar : NSView {
    float _percentage;
    BOOL _drawHandle;
    BOOL _movable;
    BOOL _dragable;
    
    BOOL _inDrag;

    id<SliderBarDelegate> _delegate;

    BOOL _hoverable;
    float _hoverPercentage;
    SliderBarHoverView *_hoverView;
    NSWindow *_hoverWindow;
}

@property(assign, nonatomic) float percentage;
@property(assign, nonatomic) BOOL drawHandle;
@property(assign, nonatomic) BOOL movable;
@property(assign, nonatomic) BOOL dragable;
@property(assign, nonatomic) BOOL hoverable;
@property id<SliderBarDelegate> delegate;

-(float)convertMouseEventToPercentage:(NSEvent *)event;
-(void)sendNewPercentageToDelegate;

@end

@protocol SliderBarDelegate
-(NSString *)sliderBar:(SliderBar *)sliderBar textForHoverAt:(float)percentage;
-(void)sliderBarDidMove:(NSNotification *)notification;
-(void)sliderBarDidBeginDrag:(NSNotification *)notification;
-(void)sliderBarDidEndDrag:(NSNotification *)notification;
@end