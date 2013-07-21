//
//  TitlebarSeekButtonNS.h
//  dokibox
//
//  Created by Someone on 9/12/12.
//
//

#import "TitlebarButtonNS.h"

typedef enum { RWSeekButton, FFSeekButton } SeekButtonDirection;

@interface TitlebarSeekButtonNS : TitlebarButtonNS {
    NSTimer* delayTimer;
    NSTimer* seekTimer;
    SeekButtonDirection _buttonType;
    BOOL _didSeek;
}

-(void)setType:(SeekButtonDirection)type;
-(SeekButtonDirection)getType;

@end
