//
//  AppDDLogFormatter.m
//  dokibox
//
//  Created by Miles Wu on 24/11/2014.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "AppDDLogFormatter.h"

@interface AppDDLogFormatter(PrivateMethods)
// Hack to access private methods of superclass
- (NSString *)queueThreadLabelForLogMessage:(DDLogMessage *)logMessage;
- (NSString *)stringFromDate:(NSDate *)date;
@end


@implementation AppDDLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevelString;
    switch (logMessage->logFlag) {
        case LOG_FLAG_ERROR:
            logLevelString = @"E";
            break;
        case LOG_FLAG_INFO:
            logLevelString = @"I";
            break;
        case LOG_FLAG_VERBOSE:
            logLevelString = @"V";
            break;
        case LOG_FLAG_WARN:
            logLevelString = @"W";
            break;
        default:
            logLevelString = @" ";
            break;
    }
    NSString *timestamp = [self stringFromDate:(logMessage->timestamp)];
    NSString *queueThreadLabel = [self queueThreadLabelForLogMessage:logMessage];
    char *file = rindex(logMessage->file, '/') + 1; // Only take last component of path
    
    
    return [NSString stringWithFormat:@"%@ %@ [%@] (%s:%d) %@", timestamp, logLevelString, queueThreadLabel, file, logMessage->lineNumber, logMessage->logMsg];
}

@end
