//
//  TitlebarSeekButtonNS.m
//  dokibox
//
//  Created by Someone on 9/12/12.
//
//

#import "TitlebarSeekButtonNS.h"

@implementation TitlebarSeekButtonNS
// use TitlebarButtonNS constructor
- (void)mouseDown:(NSEvent *)event
{
    _held = YES;
    NSLog(@"Mousedown.");
    delayTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(startSeek) userInfo:nil repeats:NO];
    [self setNeedsDisplay:YES];
}

-(void)startSeek {
    _didSeek = YES;
    NSLog(@"Seek Started.");
    //if([self type]==FFSeekButton){
    //  seekTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(continueSeekForward) userInfo:nil repeats:YES];
    //} else {
    //  seekTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(continueSeekBackward) userInfo:nil repeats:YES];
    //}
    // Should do seeking as a selector within TitlebarViewNS? Seems odd
    // to have the skip that way and not the seek. Then again I don't
    // know how to set two different actions to one button. (or if it's possible)
}

-(void)continueSeekForward {
    NSLog(@"doing nothing.");
    //seek + increment?
}

-(void)continueSeekBackward {
    NSLog(@"still nothing.");
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
    NSLog(@"Mouseup.");
}

-(void)setType:(SeekButtonDirection)type {
    _buttonType = type;
}

-(SeekButtonDirection)getType {
    return _buttonType;
}

@end
