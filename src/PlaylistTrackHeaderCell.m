//
//  PlaylistTrackHeaderCell.m
//  dokibox
//
//  Created by Miles Wu on 14/12/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "PlaylistTrackHeaderCell.h"

@implementation PlaylistTrackHeaderCell

- (NSRect)drawingRectForBounds:(NSRect)rect {
    rect.origin.x += 4.0;
    return [super drawingRectForBounds:rect];
}

@end
