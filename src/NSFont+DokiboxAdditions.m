//
//  NSFont+DokiboxAdditions.m
//  dokibox
//
//  Created by Miles Wu on 13/03/2015.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//
//

#import "NSFont+DokiboxAdditions.h"

@implementation NSFont (DokiboxAdditions)

+ (NSFont *)italicSystemFontOfSize:(CGFloat)fontSize
{
    return [[NSFontManager sharedFontManager] convertFont:[NSFont systemFontOfSize:fontSize] toHaveTrait:NSItalicFontMask];
}

@end
