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

@implementation HumanReadableTimeSinceDate
+(Class)transformedValueClass {
    return [NSString class];
}
-(NSString *)timeAgoString:(int)t withUnit:(NSString *)unit
{
    return [NSString stringWithFormat:@"%d %@%@ ago", t, unit, t > 1 ? @"s" : @""];
}
-(id)transformedValue:(id)value {
    if (value == nil) {
        return nil;
    } else {
        if([value isKindOfClass:[NSDate class]]) {
            NSDate *d = (NSDate *)value;
            NSTimeInterval time = [d timeIntervalSinceNow];
            int time_int = -time;
            
            // Technically this isn't accurate due to days in the month and leap years
            // but I dont think this matters for what we want to do
            if(time_int < 1) {
                return @"Less than a second ago";
            }
            else if(time_int < 60) {
                return [self timeAgoString:time_int withUnit:@"second"];
            }
            else if(time_int < 60*60) {
                return [self timeAgoString:time_int/60 withUnit:@"minute"];
            }
            else if(time_int < 60*60*24) {
                return [self timeAgoString:time_int/60/60 withUnit:@"hour"];
            }
            else if(time_int < 60*60*24*7) {
                return [self timeAgoString:time_int/60/60/24 withUnit:@"day"];
            }
            else if(time_int < 60*60*24*30) {
                return [self timeAgoString:time_int/60/60/24/7 withUnit:@"week"];
            }
            else if(time_int < 60*60*24*365) {
                return [self timeAgoString:time_int/60/60/24/30 withUnit:@"month"];
            }
            else {
                return [self timeAgoString:time_int/60/60/24/365 withUnit:@"year"];
            }
        }
        else {
            DDLogError(@"HumanReadableTimeSinceDate value transformer used on a non NSDate (%@", [value className]);
            return nil;
        }
    }
}
@end
