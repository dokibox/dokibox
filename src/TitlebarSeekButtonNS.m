//
//  TitlebarSeekButtonNS.m
//  dokibox
//
//  Created by Someone on 9/12/12.
//
//

#import "TitlebarSeekButtonNS.h"

@implementation TitlebarSeekButtonNS

@synthesize heldAction;

// use TitlebarButtonNS constructor
- (void)mouseDown:(NSEvent *)event
{
    _held = YES;
    delayTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(startSeek) userInfo:nil repeats:NO];
    [self setNeedsDisplay:YES];
}

-(void)startSeek {
    _didSeek = YES;
    seekTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(continueHold:) userInfo:nil repeats:YES];
}

-(void)continueHold:(NSTimer *)timer {
    if([[self target] respondsToSelector:[self heldAction]]) {
        [self sendAction:[self heldAction] to:[self target]];
    }
}

- (void)mouseEntered:(NSEvent *)event
{
    _hover = YES;
    if (_held) {
        delayTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(startSeek) userInfo:nil repeats:NO];
    }
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)event
{
    _hover = NO;
    [delayTimer invalidate];
    delayTimer = nil;
    if (_didSeek) {
        [seekTimer invalidate];
        seekTimer = nil;
    }
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event
{
    _held = NO;
    [delayTimer invalidate];
    delayTimer = nil;
    if (_didSeek) {
        [seekTimer invalidate];
        seekTimer = nil;
        _didSeek = NO;
    } else { // perform cb
        if(CGRectContainsPoint([self bounds], [self convertPoint:[event locationInWindow] fromView:nil])) {
            [self sendAction:[self action] to:[self target]];
        }
    }
    [self setNeedsDisplay:YES];
}

-(void)setType:(SeekButtonDirection)type {
    _buttonType = type;
    
    // Set tag (which we use to store the direction)
    if(type == FFSeekButton){
        [self setTag:1];
    }
    else if(type == RWSeekButton) {
        [self setTag:-1];
    }
}

-(SeekButtonDirection)getType {
    return _buttonType;
}

@end
