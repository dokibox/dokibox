//
//  PluginPreferenceViewController.m
//  dokibox
//
//  Created by Miles Wu on 14/09/2013.
//
//

#import "PluginPreferenceViewController.h"
#import "PluginManager.h"

@implementation PluginPreferenceViewController

- (id)init
{
    self = [self initWithNibName:@"PluginPreferenceViewController" bundle:nil];
    if(self) {
        _pluginManager = [PluginManager sharedInstance];
    }
    return self;
}

- (NSString *)identifier
{
    return @"plugins";
}

- (NSImage *)toolbarItemImage
{
    CGRect bounds = CGRectMake(0, 0, 64, 64);
    NSImage *pluginImage = [[NSImage alloc] initWithSize:bounds.size];
    [pluginImage lockFocus];

    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];

    CGContextSetRGBFillColor(context, 0.33, 0.33, 0.33, 1);
    CGContextSetLineWidth(context, 0);

    CGContextMoveToPoint(context, 50, 49);
    CGContextAddLineToPoint(context, 50, 55);
    CGContextAddLineToPoint(context, 38, 55);
    CGContextAddLineToPoint(context, 38, 49);
    CGContextAddLineToPoint(context, 26, 49);
    CGContextAddLineToPoint(context, 26, 55);
    CGContextAddLineToPoint(context, 14, 55);
    CGContextAddLineToPoint(context, 14, 49);
    CGContextAddLineToPoint(context, 6, 49);
    CGContextAddLineToPoint(context, 6, 8);
    CGContextAddLineToPoint(context, 58, 8);
    CGContextAddLineToPoint(context, 58, 49);
    CGContextClosePath(context);

    CGContextMoveToPoint(context, 44.75, 26.12);
    CGContextAddCurveToPoint(context, 44.75, 25.88, 44.55, 25.58, 44.28, 25.53);
    CGContextAddLineToPoint(context, 41.21, 25.06);
    CGContextAddCurveToPoint(context, 41.03, 24.53, 40.83, 24.03, 40.56, 23.55);
    CGContextAddCurveToPoint(context, 41.13, 22.74, 41.73, 22.01, 42.34, 21.26);
    CGContextAddCurveToPoint(context, 42.44, 21.15, 42.51, 21, 42.51, 20.85);
    CGContextAddCurveToPoint(context, 42.51, 20.7, 42.46, 20.58, 42.36, 20.47);
    CGContextAddCurveToPoint(context, 41.96, 19.93, 39.72, 17.49, 39.15, 17.49);
    CGContextAddCurveToPoint(context, 39, 17.49, 38.85, 17.56, 38.72, 17.64);
    CGContextAddLineToPoint(context, 36.43, 19.44);
    CGContextAddCurveToPoint(context, 35.95, 19.19, 35.44, 18.97, 34.92, 18.81);
    CGContextAddCurveToPoint(context, 34.8, 17.79, 34.7, 16.71, 34.44, 15.72);
    CGContextAddCurveToPoint(context, 34.37, 15.45, 34.14, 15.25, 33.84, 15.25);
    CGContextAddLineToPoint(context, 30.16, 15.25);
    CGContextAddCurveToPoint(context, 29.86, 15.25, 29.59, 15.47, 29.56, 15.75);
    CGContextAddLineToPoint(context, 29.1, 18.81);
    CGContextAddCurveToPoint(context, 28.58, 18.97, 28.08, 19.17, 27.6, 19.42);
    CGContextAddLineToPoint(context, 25.26, 17.64);
    CGContextAddCurveToPoint(context, 25.15, 17.54, 25, 17.49, 24.85, 17.49);
    CGContextAddCurveToPoint(context, 24.7, 17.49, 24.55, 17.56, 24.43, 17.68);
    CGContextAddCurveToPoint(context, 23.55, 18.47, 22.39, 19.5, 21.69, 20.47);
    CGContextAddCurveToPoint(context, 21.61, 20.58, 21.58, 20.71, 21.58, 20.85);
    CGContextAddCurveToPoint(context, 21.58, 21, 21.63, 21.11, 21.71, 21.23);
    CGContextAddCurveToPoint(context, 22.27, 21.99, 22.89, 22.72, 23.45, 23.5);
    CGContextAddCurveToPoint(context, 23.17, 24.03, 22.94, 24.58, 22.77, 25.15);
    CGContextAddLineToPoint(context, 19.74, 25.59);
    CGContextAddCurveToPoint(context, 19.45, 25.64, 19.25, 25.91, 19.25, 26.19);
    CGContextAddLineToPoint(context, 19.25, 29.88);
    CGContextAddCurveToPoint(context, 19.25, 30.12, 19.45, 30.42, 19.7, 30.47);
    CGContextAddLineToPoint(context, 22.79, 30.94);
    CGContextAddCurveToPoint(context, 22.95, 31.47, 23.17, 31.97, 23.44, 32.46);
    CGContextAddCurveToPoint(context, 22.87, 33.26, 22.27, 34.01, 21.66, 34.76);
    CGContextAddCurveToPoint(context, 21.56, 34.87, 21.49, 35, 21.49, 35.15);
    CGContextAddCurveToPoint(context, 21.49, 35.3, 21.56, 35.42, 21.64, 35.53);
    CGContextAddCurveToPoint(context, 22.04, 36.08, 24.28, 38.51, 24.85, 38.51);
    CGContextAddCurveToPoint(context, 25, 38.51, 25.15, 38.44, 25.28, 38.34);
    CGContextAddLineToPoint(context, 27.57, 36.56);
    CGContextAddCurveToPoint(context, 28.05, 36.81, 28.56, 37.03, 29.08, 37.19);
    CGContextAddCurveToPoint(context, 29.2, 38.21, 29.29, 39.29, 29.56, 40.28);
    CGContextAddCurveToPoint(context, 29.63, 40.55, 29.86, 40.75, 30.16, 40.75);
    CGContextAddLineToPoint(context, 33.84, 40.75);
    CGContextAddCurveToPoint(context, 34.14, 40.75, 34.41, 40.53, 34.44, 40.25);
    CGContextAddLineToPoint(context, 34.9, 37.19);
    CGContextAddCurveToPoint(context, 35.42, 37.03, 35.92, 36.83, 36.4, 36.58);
    CGContextAddLineToPoint(context, 38.75, 38.36);
    CGContextAddCurveToPoint(context, 38.85, 38.46, 39, 38.51, 39.15, 38.51);
    CGContextAddCurveToPoint(context, 39.3, 38.51, 39.45, 38.44, 39.57, 38.34);
    CGContextAddCurveToPoint(context, 40.45, 37.53, 41.61, 36.5, 42.31, 35.52);
    CGContextAddCurveToPoint(context, 42.39, 35.42, 42.42, 35.29, 42.42, 35.15);
    CGContextAddCurveToPoint(context, 42.42, 35, 42.37, 34.89, 42.29, 34.77);
    CGContextAddCurveToPoint(context, 41.73, 34.01, 41.11, 33.28, 40.55, 32.5);
    CGContextAddCurveToPoint(context, 40.83, 31.97, 41.06, 31.42, 41.23, 30.87);
    CGContextAddLineToPoint(context, 44.26, 30.41);
    CGContextAddCurveToPoint(context, 44.55, 30.36, 44.75, 30.09, 44.75, 29.81);
    CGContextClosePath(context);

    CGContextMoveToPoint(context, 32, 34.37);
    CGContextAddCurveToPoint(context, 28.49, 34.37, 25.63, 31.51, 25.63, 28);
    CGContextAddCurveToPoint(context, 25.63, 24.49, 28.49, 21.63, 32, 21.63);
    CGContextAddCurveToPoint(context, 35.51, 21.63, 38.37, 24.49, 38.37, 28);
    CGContextAddCurveToPoint(context, 38.37, 31.51, 35.51, 34.37, 32, 34.37);
    CGContextDrawPath(context, kCGPathFillStroke);

    [pluginImage unlockFocus];
    return pluginImage;
}

- (NSString *)toolbarItemLabel
{
    return @"Plugins";
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[_pluginManager plugins] count];
}

-(id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [[[_pluginManager plugins] objectAtIndex:row] name];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    if(_currentPluginPreferencePaneView)
        [_currentPluginPreferencePaneView removeFromSuperview];
    
    if([_tableView selectedRow] == -1) return;
    
    id<PluginProtocol> plugin = [[_pluginManager plugins] objectAtIndex:[_tableView selectedRow]];
    if([plugin respondsToSelector:@selector(preferencePaneView)]) {
        _currentPluginPreferencePaneView = [plugin preferencePaneView];
        [_currentPluginPreferencePaneView setFrame:NSMakeRect(245, 20, 230, 370)];
        [[self view] addSubview:_currentPluginPreferencePaneView];
    }
}



@end
