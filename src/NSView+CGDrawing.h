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

#define TRACK_TABLEVIEW_HEADER_BOTTOM_COLOR .71372549
#define TRACK_TABLEVIEW_HEADER_TOP_COLOR .658823529