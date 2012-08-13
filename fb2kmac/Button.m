//
//  Button.m
//  fb2kmac
//
//  Created by Miles Wu on 07/08/2012.
//
//

#import "Button.h"

@implementation Button

@synthesize drawIcon = _drawIcon;

-(void)drawRect:(CGRect)r
{
    CGContextRef ctx = TUIGraphicsGetCurrentContext();
    CGRect b = self.bounds;
    
    BOOL key = [self.nsView isWindowKey];
	BOOL down = self.state == TUIControlStateHighlighted;
    
    
    self.layer.cornerRadius = 3.0;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0;
    if(key) {
        if(!down) {
            TUIColor *gradientEndColor = [TUIColor colorWithWhite:0.95 alpha:1.0];
            TUIColor *gradientStartColor = [TUIColor colorWithWhite:0.8 alpha:1.0];
            TUIColor *borderColor = [TUIColor colorWithWhite:0.55 alpha:1.0];
            
            NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                               (id)[gradientEndColor CGColor], nil];
            CGFloat locations[] = { 0.0, 1.0 };
            CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);
            
            CGContextDrawLinearGradient(ctx, gradient, CGPointMake(b.origin.x, b.origin.y), CGPointMake(b.origin.x, b.origin.y+b.size.height), 0);
            CGGradientRelease(gradient);
            
            self.layer.borderColor = [borderColor CGColor];
        }
        else {
            self.backgroundColor = [TUIColor colorWithWhite:0.75 alpha:1.0];
            self.layer.borderWidth = 0.0;
        }
    }
    else {
        TUIColor *borderColor = [TUIColor colorWithWhite:0.75 alpha:1.0];
        self.layer.borderColor = [borderColor CGColor];
        self.backgroundColor = [TUIColor colorWithWhite:0.9 alpha:1.0];
    }
    

    
    _drawIcon(self, r);
    

    
    

    
    
    //CGContextAddRect(ctx, b);
    //CGContextStrokePath(ctx);
	
    // light gray background
    
    /*const void *colorRefs[3] = {inColor1, inColor2, inColor3};
    CFArrayRef colorArray = CFArrayCreate(kCFAllocatorDefault, colorRefs, 3, &kCFTypeArrayCallBacks);
    
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, 
    CGContextDrawLinearGradient(ctx, gradient, start, end, )*/
    
                                                        
                                                        
                                                        
    /*if(_buttonFlags.firstDraw) {
		[self _update];
		_buttonFlags.firstDraw = 0;
	}
	
	CGRect bounds = self.bounds;
    

	CGFloat alpha = (self.buttonType == TUIButtonTypeCustom ? 1.0 : down?0.7:1.0);
	if(_buttonFlags.dimsInBackground)
		alpha = key?alpha:0.5;
	
	if(self.backgroundColor != nil) {
		[self.backgroundColor setFill];
		CGContextFillRect(TUIGraphicsGetCurrentContext(), self.bounds);
	}
	
	TUIImage *backgroundImage = self.currentBackgroundImage;
	TUIImage *image = self.currentImage;
	
	[backgroundImage drawInRect:[self backgroundRectForBounds:bounds] blendMode:kCGBlendModeNormal alpha:1.0];
	
	if(image) {
		CGRect imageRect;
		if(image.leftCapWidth || image.topCapHeight) {
			// stretchable
			imageRect = self.bounds;
		} else {
			// normal centered + insets
			imageRect.origin = CGPointZero;
			imageRect.size = [image size];
			CGRect b = self.bounds;
			b.origin.x += _imageEdgeInsets.left;
			b.origin.y += _imageEdgeInsets.bottom;
			b.size.width -= _imageEdgeInsets.left + _imageEdgeInsets.right;
			b.size.height -= _imageEdgeInsets.bottom + _imageEdgeInsets.top;
			imageRect = ButtonRectRoundOrigin(ButtonRectCenteredInRect(imageRect, b));
		}
		[image drawInRect:imageRect blendMode:kCGBlendModeNormal alpha:alpha];
	}
	
	CGContextRef ctx = TUIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
	CGContextTranslateCTM(ctx, _titleEdgeInsets.left, _titleEdgeInsets.bottom);
	if(!key)
		CGContextSetAlpha(ctx, 0.5);
	CGRect titleFrame = self.bounds;
	titleFrame.size.width -= (_titleEdgeInsets.left + _titleEdgeInsets.right);
	_titleView.frame = titleFrame;
	[_titleView drawRect:_titleView.bounds];
	CGContextRestoreGState(ctx);*/
}

@end
