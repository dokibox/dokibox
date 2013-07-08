//
//  PlaylistTrack.m
//  fb2kmac
//
//  Created by Miles Wu on 20/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaylistTrack.h"
#import "TaggerProtocol.h"

@implementation PlaylistTrack

@dynamic artistName;
@dynamic albumName;

+(PlaylistTrack *)trackWithFilename:(NSString *)filename inContext:(NSManagedObjectContext *)objectContext
{
    PlaylistTrack *t = [NSEntityDescription insertNewObjectForEntityForName:@"track" inManagedObjectContext:objectContext];
    [t setFilename:filename];
    [t setName:([[t attributes] objectForKey:@"TITLE"] ? [[t attributes] objectForKey:@"TITLE"] : @"")];
    [t setArtistName:([[t attributes] objectForKey:@"ARTIST"] ? [[t attributes] objectForKey:@"ARTIST"] : @"")];
    [t setAlbumName:([[t attributes] objectForKey:@"ALBUM"] ? [[t attributes] objectForKey:@"ALBUM"] : @"")];
    return t;
}

@end
