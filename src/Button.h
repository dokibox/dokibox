//
//  Button.h
//  dokibox
//
//  Created by Miles Wu on 07/08/2012.
//
//

#import "TUIKit.h"

@interface Button : TUIButton {
    TUIViewDrawRect	_drawIcon;
}

@property (nonatomic, copy) TUIViewDrawRect drawIcon;

@end
