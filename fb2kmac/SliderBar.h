//
//  SliderBar.h
//  fb2kmac
//
//  Created by Miles Wu on 11/10/2012.
//
//

#import "TUIKit.h"
#import <Cocoa/Cocoa.h>

@interface SliderBar : NSView {
    float _percentage;
}

@property(assign, nonatomic) float percentage;

@end