//
//  TitlebarButtonNS.h
//  fb2kmac
//
//  Created by Miles Wu on 14/08/2012.
//
//

#import "TUIKit.h"
#import <Cocoa/Cocoa.h>

typedef void(^NSViewDrawRect)(NSView *, CGRect);
@interface TitlebarButtonNS : NSButton {
    NSViewDrawRect _drawIcon;
    BOOL _hover;
    BOOL _held;
}

@property (nonatomic, copy) NSViewDrawRect drawIcon;

@end
