//
//  UpdaterPreferenceViewController.m
//  dokibox
//
//  Created by Miles Wu on 17/01/2015.
//
//

#import "UpdaterPreferenceViewController.h"

@interface UpdaterPreferenceViewController ()

@end

@implementation UpdaterPreferenceViewController

- (NSString *)identifier
{
    return @"updater";
}

- (NSImage *)toolbarItemImage
{
    CGRect bounds = CGRectMake(0, 0, 64, 64);
    NSImage *updaterImage = [[NSImage alloc] initWithSize:bounds.size];
    [updaterImage lockFocus];

    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];

    CGContextSetRGBFillColor(context, 0.33, 0.33, 0.33, 1);
    CGContextSetLineWidth(context, 0);

    CGContextMoveToPoint(context, 47.87, 45.81);
    CGContextAddCurveToPoint(context, 47.28, 45.81, 46.7, 45.75, 46.13, 45.65);
    CGContextAddCurveToPoint(context, 45.25, 48.11, 42.94, 49.88, 40.19, 49.88);
    CGContextAddCurveToPoint(context, 39.51, 49.88, 38.88, 49.74, 38.27, 49.54);
    CGContextAddCurveToPoint(context, 36.26, 54.5, 31.42, 58, 25.75, 58);
    CGContextAddCurveToPoint(context, 18.29, 58, 12.25, 51.94, 12.25, 44.46);
    CGContextAddCurveToPoint(context, 12.25, 43.68, 12.33, 42.92, 12.45, 42.18);
    CGContextAddCurveToPoint(context, 8.76, 41.29, 6.02, 37.97, 6, 34);
    CGContextAddLineToPoint(context, 6, 34);
    CGContextAddLineToPoint(context, 6, 8);
    CGContextAddLineToPoint(context, 58, 8);
    CGContextAddLineToPoint(context, 58, 35.66);
    CGContextAddLineToPoint(context, 58, 35.66);
    CGContextAddCurveToPoint(context, 58, 41.27, 53.46, 45.81, 47.87, 45.81);

    CGContextMoveToPoint(context, 42, 16.67);
    CGContextAddLineToPoint(context, 22, 16.67);
    CGContextAddLineToPoint(context, 22, 20.83);
    CGContextAddLineToPoint(context, 32, 20.83);
    CGContextAddLineToPoint(context, 24.5, 32.28);
    CGContextAddLineToPoint(context, 28.9, 31.19);
    CGContextAddLineToPoint(context, 28.9, 40);
    CGContextAddLineToPoint(context, 35.1, 40);
    CGContextAddLineToPoint(context, 35.1, 31.19);
    CGContextAddLineToPoint(context, 39.5, 32.28);
    CGContextAddLineToPoint(context, 32, 20.83);
    CGContextAddLineToPoint(context, 42, 20.83);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);

    [updaterImage unlockFocus];
    return updaterImage;
}

- (NSString *)toolbarItemLabel
{
    return @"Updater";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

@end
