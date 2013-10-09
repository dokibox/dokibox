//
//  Playlist.h
//  dokibox
//
//  Created by Miles Wu on 28/07/2012.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PlaylistTrack.h"

@interface Playlist : NSManagedObject {
}

-(NSUInteger)numberOfTracks;
-(NSUInteger)getTrackIndex:(PlaylistTrack *)track;
-(PlaylistTrack *)trackAtIndex:(NSUInteger)index;

-(void)removeTrackAtIndex:(NSUInteger)index;
-(void)removeTrack:(PlaylistTrack *)track;

-(void)insertTrackWithFilename:(NSString *)filename atIndex:(NSUInteger)index;
-(void)insertTrack:(PlaylistTrack *)track atIndex:(NSUInteger)index;
-(void)addTrackWithFilename:(NSString *)filename;
-(void)addTrack:(PlaylistTrack *)track;

-(void)playTrackAtIndex:(NSUInteger)index;
-(void)receivedTrackEndedNotification:(NSNotification *)notification;
-(void)save;

@property (nonatomic) NSString *name;
@property (nonatomic) NSSet* tracks;

@end