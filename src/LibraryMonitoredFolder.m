//
//  LibraryFolder.m
//  dokibox
//
//  Created by Miles Wu on 04/11/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "LibraryMonitoredFolder.h"
#include <sys/param.h>
#include <sys/mount.h>

@implementation LibraryMonitoredFolder

@dynamic path;
@dynamic lastEventID;
@dynamic initialScanDone;

-(BOOL)isOnNetworkMount
{
    struct statfs buf;
    statfs([[self path] UTF8String], &buf);

    if((buf.f_flags & MNT_LOCAL) != 0) {
        return FALSE;
    }
    else {
        return TRUE;
    }
}

@end
