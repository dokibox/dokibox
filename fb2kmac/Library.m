//
//  Library.m
//  fb2kmac
//
//  Created by Miles Wu on 08/02/2013.
//
//

#import "Library.h"
#import "Track.h"
#import "CoreDataManager.h"

@implementation Library

-(void)searchDirectory:(NSString*)dir
{
    NSError *error;
    CoreDataManager *cdm = [CoreDataManager sharedInstance];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *denum = [fm enumeratorAtPath:dir];
    
    NSString *filepath = [denum nextObject];
    // Probably a bug in that it doesn't do symlinks
    while(filepath) {
        @autoreleasepool {
            NSString *fullfilepath = [dir stringByAppendingPathComponent:filepath];
            if([[fullfilepath pathExtension] isEqualToString:@"flac"] || [[fullfilepath pathExtension] isEqualToString:@"mp3"])
                [self addFile:fullfilepath];
            filepath = [denum nextObject];
        }
    }
    if([[cdm context] save:&error] == NO) {
        NSLog(@"error saving");
        NSLog(@"%@", [error localizedDescription]);
        for(NSError *e in [[error userInfo] objectForKey:NSDetailedErrorsKey]) {
            NSLog(@"%@", [e localizedDescription]);
        }
    };
    
    /*{
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"track"];
    [fr setReturnsObjectsAsFaults:NO];
    
    NSArray *results = [[cdm context] executeFetchRequest:fr error:&error];
    for(Track* i in results) {
        NSLog(@"%@", [i filename]);
        NSLog(@"%@", [[i attributes] objectForKey:@"TITLE"]);
    }
    NSLog(@"finished retrive@");
    }*/
}

-(void)addFile:(NSString*)file
{
    NSError *error;
    Track *t;
    CoreDataManager *cdm = [CoreDataManager sharedInstance];
    
    NSFetchRequest *fr = [NSFetchRequest fetchRequestWithEntityName:@"track"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filename LIKE %@", file];
    [fr setPredicate:predicate];
    
    NSArray *results = [[cdm context] executeFetchRequest:fr error:&error];
    if(results == nil) {
        NSLog(@"error fetching results");
    }
    else if([results count] == 0) {
        t = [NSEntityDescription insertNewObjectForEntityForName:@"track" inManagedObjectContext:[cdm context]];
        [t setFilename:file];
        [t setName:([[t attributes] objectForKey:@"TITLE"] ? [[t attributes] objectForKey:@"TITLE"] : @"")];
        [t setArtistByName:([[t attributes] objectForKey:@"ARTIST"] ? [[t attributes] objectForKey:@"ARTIST"] : @"") andAlbumByName:([[t attributes] objectForKey:@"ALBUM"] ? [[t attributes] objectForKey:@"ALBUM"] : @"")];
    }
    else { //already exists in library
        t = [results objectAtIndex:0];
    }
}

@end
