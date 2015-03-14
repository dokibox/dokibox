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
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *italicSystemFont = [fontManager convertFont:[NSFont systemFontOfSize:fontSize] toHaveTrait:NSItalicFontMask];

    // Check that it worked. It can fail if there is no italic version of the system font (eg on <10.10)
    if(([fontManager traitsOfFont:italicSystemFont] & NSItalicFontMask) != NSItalicFontMask) {
        // Manually get Helvetica Oblique
        italicSystemFont = [NSFont fontWithName:@"Helvetica-Oblique" size:fontSize];
    }

    return italicSystemFont;
}

@end
