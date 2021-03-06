//
//  PlaylistTrack.m
//  dokibox
//
//  Created by Miles Wu on 20/11/2011.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "PlaylistTrack.h"
#import "TaggerProtocol.h"
#import "LibraryTrack.h"
#import "LibraryAlbum.h"
#import "LibraryArtist.h"

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

+(PlaylistTrack *)trackWithLibraryTrack:(LibraryTrack *)libraryTrack inContext:(NSManagedObjectContext *)objectContext
{
    PlaylistTrack *t = [NSEntityDescription insertNewObjectForEntityForName:@"track" inManagedObjectContext:objectContext];
    
    [t setFilename:[libraryTrack filename]];
    [t setName:[libraryTrack name]];
    [t setAlbumName:[[libraryTrack album] name]];
    [t setLength:[libraryTrack length]];
    
    // Conversion between LibraryTrack and PlaylistTrack semantics as regards track/album artist
    // LibraryTrack always has album artist and only has track artist set if it is different from album artist
    // PlaylistTrack always has track artist and only has album artist if the tag exists
    if([libraryTrack trackArtistName]) {
        [t setAlbumArtistName:[[[libraryTrack album] artist] name]];
        [t setTrackArtistName:[libraryTrack trackArtistName]];
    }
    else {
        [t setTrackArtistName:[[[libraryTrack album] artist] name]];
    }
    
    return t;
}

+(PlaylistTrack *)trackWithPlaylistTrack:(PlaylistTrack *)playlistTrack inContext:(NSManagedObjectContext *)objectContext
{
    PlaylistTrack *t = [NSEntityDescription insertNewObjectForEntityForName:@"track" inManagedObjectContext:objectContext];

    // Copy attributes
    NSArray *attributeKeys = [[playlistTrack entity] attributeKeys];
    for(NSString *key in attributeKeys) {
        [t setValue:[playlistTrack valueForKey:key] forKey:key];
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
    
    // If ALBUMARTIST tag exists (and is not blank)
    if([[self attributes] objectForKey:@"ALBUMARTIST"] && [[[self attributes] objectForKey:@"ALBUMARTIST"] isEqual:@""] == NO) {
        [self setAlbumArtistName:[[self attributes] objectForKey:@"ALBUMARTIST"]];
    }
    
    // Reset needsUpdate flag
    [super updateFromFile];
    return YES;
}

-(NSString *)menuItemFormatString
{
    NSDictionary *dict = [self attributes];
    NSString *str = [[NSString alloc] initWithFormat:@"%@ [%@ kbit/s]", [dict objectForKey:@"format"], [dict objectForKey:@"bitrate"]];
    return str;
}

-(NSString *)displayName
{
    NSString *text;
    
    if([self albumArtistName] && [[self albumArtistName] isEqual:[self trackArtistName]] == NO) {
        // If album artist exists and isn't the same as the track artist, append the track artist to the title
        text = [NSString stringWithFormat:@"%@ // %@", [self name], [self trackArtistName]];
    }
    else {
        text = [self name];
    }
    
    return text;
}

-(NSString *)displayAlbumName
{
    return [self albumName];
}

-(NSString *)displayArtistName
{
    NSString *text;
    
    if([self albumArtistName] && [[self albumArtistName] isEqual:@""] == NO) {
        // If album artist exists and isn't "", use it instead of track artist
        text = [self albumArtistName];
    }
    else {
        text = [self trackArtistName];
    }
    
    return text;
}


@end
