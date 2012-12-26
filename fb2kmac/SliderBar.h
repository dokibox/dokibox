//
//  SliderBar.h
//  fb2kmac
//
//  Created by Miles Wu on 11/10/2012.
//
//

#import "TUIKit.h"
#import <Cocoa/Cocoa.h>
#import "SliderBarHoverView.h"

@interface SliderBar : NSView {
    float _percentage;
    BOOL _drawHandle;
    
    float _hoverPercentage;
    SliderBarHoverView *_hoverView;
    NSWindow *_hoverWindow;
    
}

@property(assign, nonatomic) float percentage;
@property(assign, nonatomic) BOOL drawHandle;

-(float)convertMouseEventToPercentage:(NSEvent *)event;

@end
