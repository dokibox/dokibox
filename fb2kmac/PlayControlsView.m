//
//  PlayControlsView.m
//  fb2kmac
//
//  Created by Miles Wu on 29/07/2012.
//
//

#import "PlayControlsView.h"

@implementation PlayControlsView

-(id)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        //self.backgroundColor = [TUIColor colorWithWhite:0.3 alpha:1.0];

        CGRect buttonframe = CGRectMake(0, 10, 36, 28);
        Button *b = [[Button alloc] initWithFrame:buttonframe];
        
        [b setTitle:@"h" forState:TUIControlStateNormal];
        [b titleLabel];
        [b addTarget:self action:@selector(buttonpress:) forControlEvents:TUIControlEventTouchUpInside];
        
        [b setDrawIcon: ^(TUIView *v, CGRect rect) {
            CGContextRef ctx = TUIGraphicsGetCurrentContext();
            CGRect b = v.bounds;
            CGPoint middle = CGPointMake(CGRectGetMidX(b), CGRectGetMidY(b));
            float size = 9.0;
            CGPoint playPoints[] =
            {
                CGPointMake(middle.x + size, middle.y),
                CGPointMake(middle.x - size*0.5, middle.y - size*sqrt(3.0)*0.5),
                CGPointMake(middle.x - size*0.5, middle.y + size*sqrt(3.0)*0.5),
                CGPointMake(middle.x + size, middle.y)
            };
            
            CGContextAddLines(ctx, playPoints, 4);
            CGContextSaveGState(ctx);
            CGContextClip(ctx);
            TUIColor *gradientEndColor = [TUIColor colorWithWhite:0.15 alpha:1.0];
            TUIColor *gradientStartColor = [TUIColor colorWithWhite:0.45 alpha:1.0];
            
            NSArray *colors = [NSArray arrayWithObjects: (id)[gradientStartColor CGColor],
                               (id)[gradientEndColor CGColor], nil];
            CGFloat locations[] = { 0.0, 1.0 };
            CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);
            
            CGContextDrawLinearGradient(ctx, gradient, CGPointMake(middle.x, middle.y + size*sqrt(3.0)*0.5), CGPointMake(middle.x, middle.y - size*sqrt(3.0)*0.5), 0);
            CGGradientRelease(gradient);
            CGContextRestoreGState(ctx);
        }];
        
        [self addSubview:b];
    }
    return self;
}

-(void)buttonpress:(id)sender {
    Button *b = sender;
    NSLog(@"%@", [b currentTitle]);
}


@end
