//
//  ValueTransformers.m
//  dokibox
//
//  Created by Miles Wu on 12/05/2014.
//
//

#import "ValueTransformers.h"

@implementation IsNotEmptyString
+(Class)transformedValueClass {
    return [NSNumber class];
}
-(id)transformedValue:(id)value {
    if (value == nil) {
        return nil;
    } else {
        if([value isKindOfClass:[NSString class]]) {
            NSString *s = (NSString *)value;
            s = [s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([s isEqualToString:@""]) {
                return @NO;
            } else {
                return @YES;
            }
        }
        else {
            DDLogError(@"IsNotEmptyString value transformer used on a non string (%@", [value className]);
            return nil;
        }
    }
}
@end
