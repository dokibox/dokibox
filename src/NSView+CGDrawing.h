//
//  NSView+CGDrawing.h
//  dokibox
//
//  Created by Miles Wu on 20/07/2013.
//
//

#import <Cocoa/Cocoa.h>

@interface NSView (CGDrawing)

- (void)CGContextRoundedCornerPath:(CGRect)b context:(CGContextRef)ctx radius:(CGFloat)r withHalfPixelRedution:(BOOL)onpixel;
-(void)CGContextVerticalGradient:(CGRect)b context:(CGContextRef)ctx bottomColor:(NSColor *)bottomColor topColor:(NSColor *)topColor;

@end
