//
//  Library.m
//  fb2kmac
//
//  Created by Miles Wu on 08/02/2013.
//
//

#import "Library.h"
#import "PlaylistTrack.h"

@implementation Library

-(void)searchDirectory:(NSString*)dir
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *denum = [fm enumeratorAtPath:dir];
    
    NSString *filepath = [denum nextObject];
    // Probably a bug in that it doesn't do symlinks
    while(filepath) {
        @autoreleasepool {
            NSString *fullfilepath = [dir stringByAppendingPathComponent:filepath];
            if([[fullfilepath pathExtension] isEqualToString:@"mp3"])
                [self addFile:fullfilepath];
            filepath = [denum nextObject];
        }
    }
}

-(void)addFile:(NSString*)file
{
    PlaylistTrack *t = [[PlaylistTrack alloc] initWithFilename:file];
    NSDictionary *dict = [t attributes];
    
    for(id key in dict) {
        NSLog(@"%@: %@", key, [dict objectForKey:key]);
    }
    
}

@end
