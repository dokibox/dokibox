//
//  TitlebarButtonNS.h
//  dokibox
//
//  Created by Miles Wu on 14/08/2012.
//
//

#import <Cocoa/Cocoa.h>

typedef void(^NSViewDrawRect)(NSView *, CGRect);
@interface TitlebarButtonNS : NSButton {
    NSViewDrawRect _drawIcon;
    BOOL _hover;
    BOOL _held;
}

@property (assign) int state;
@property (nonatomic, copy) NSViewDrawRect drawIcon;

@end
