//
//  Column.m
//  fb2kmac
//
//  Created by Miles Wu on 03/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Column.h"

@implementation Column
@synthesize key = _key;
@synthesize offset = _offset;
@synthesize image = _image;

-(id)initWithKey:(NSString *)key offset:(int)offset
{
    self = [self init];
    _key = key;
    _offset = offset;
    [self reloadImage];
    return self;
}

-(void)reloadImage
{
    NSString *path = [NSString stringWithFormat:@"%@/%@.png", @"/Users/mileswu/Desktop/fb2kmac/design/playlistmockups", _key];
    
    NSImage *nim = [[NSImage alloc] initByReferencingFile:path];
    if(nim == nil) {
        _image = nil;
    }
    else {
        _image = [TUIImage imageWithNSImage:nim];
    }
}

@end
