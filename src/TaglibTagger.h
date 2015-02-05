//
//  TaglibTagger.h
//  dokibox
//
//  Created by Miles Wu on 22/07/2012.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaggerProtocol.h"
#include <taglib/fileref.h>
#include <taglib/tag.h>
#include <taglib/tpropertymap.h>

@interface TaglibTagger : NSObject<TaggerProtocol> {
    TagLib::FileRef *_fileref;
    TagLib::Tag *_tag;
    TagLib::AudioProperties *_audioproperties;

}



@end
