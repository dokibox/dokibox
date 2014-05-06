//
//  PlaylistTrack.m
//  dokibox
//
//  Created by Miles Wu on 20/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaylistTrack.h"
#import "TaggerProtocol.h"

@implementation PlaylistTrack

@dynamic artistName;
@dynamic albumName;
@dynamic playlist;
@dynamic index;
@dynamic length;
@synthesize playbackStatus = _playbackStatus;
@synthesize hasErrorOpeningFile;

+(PlaylistTrack *)trackWithFilename:(NSString *)filename inContext:(NSManagedObjectContext *)objectContext;
{
    PlaylistTrack *t = [NSEntityDescription insertNewObjectForEntityForName:@"track" inManagedObjectContext:objectContext];
    [t setFilename:filename];
    [t setName:([[t attributes] objectForKey:@"TITLE"] ? [[t attributes] objectForKey:@"TITLE"] : @"")];
    [t setArtistName:([[t attributes] objectForKey:@"ARTIST"] ? [[t attributes] objectForKey:@"ARTIST"] : @"")];
    [t setAlbumName:([[t attributes] objectForKey:@"ALBUM"] ? [[t attributes] objectForKey:@"ALBUM"] : @"")];
    [t setLength:[[t attributes] objectForKey:@"length"]];

    return t;
}

-(NSString *)menuItemFormatString
{
    NSDictionary *dict = [self attributes];
    NSString *str = [[NSString alloc] initWithFormat:@"%@ [%@ kbit/s]", [dict objectForKey:@"format"], [dict objectForKey:@"bitrate"]];
    return str;
}

@end
