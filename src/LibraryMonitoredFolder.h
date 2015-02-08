//
//  LibraryFolder.h
//  dokibox
//
//  Created by Miles Wu on 04/11/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface LibraryMonitoredFolder : NSManagedObject

@property() NSString *path;
@property() NSNumber *lastEventID;
@property() NSNumber *initialScanDone;

-(BOOL)isOnNetworkMount;

@end
