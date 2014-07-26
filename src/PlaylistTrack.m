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

@dynamic trackArtistName;
@dynamic albumArtistName;
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
    
    BOOL retval = [t updateFromFile];
    if(retval == NO) { // delete if we weren't able to update
        [objectContext deleteObject:t];
        return nil;
    }

    return t;
}

-(BOOL)updateFromFile
// return value is YES for success. NO for failure.
{
    [self resetAttributeCache]; //reset any previously loaded attributes/tags
    
    if([self attributes] == nil) { // failure in loading tags (perhaps IO error)
        DDLogWarn(@"Failure in updateFromFile: (not able to load tags) for %@", [self filename]);
        return NO;
    }
    
    [self setName:([[self attributes] objectForKey:@"TITLE"] ? [[self attributes] objectForKey:@"TITLE"] : @"")];
    [self setLength:[[self attributes] objectForKey:@"length"]];
    [self setTrackArtistName:([[self attributes] objectForKey:@"ARTIST"] ? [[self attributes] objectForKey:@"ARTIST"] : @"")];
    [self setAlbumName:([[self attributes] objectForKey:@"ALBUM"] ? [[self attributes] objectForKey:@"ALBUM"] : @"")];
    
    return YES;
}

-(NSString *)menuItemFormatString
{
    NSDictionary *dict = [self attributes];
    NSString *str = [[NSString alloc] initWithFormat:@"%@ [%@ kbit/s]", [dict objectForKey:@"format"], [dict objectForKey:@"bitrate"]];
    return str;
}

@end
