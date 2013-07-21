//
//  TaglibTagger.m
//  dokibox
//
//  Created by Miles Wu on 22/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaglibTagger.h"

@implementation TaglibTagger

-(id)initWithFilename:(NSString *)filename
{
	if((self = [super init])) {
        _fileref = new TagLib::FileRef([filename UTF8String]);

        if(_fileref->isNull()) {
            DDLogWarn(@"Can't find file %@", filename);
            self = nil;
            return self;
        }

        _tag = _fileref->tag();
        _audioproperties = _fileref->audioProperties();
    }
	return self;
}

-(NSMutableDictionary *)tag
{
    NSMutableDictionary *retval = [NSMutableDictionary dictionary];

    if(_tag) {
        TagLib::PropertyMap pm = _tag->properties();
        //DDLogVerbose(@"%@", [NSString stringWithUTF8String:pm.toString().toCString(true)]);

        TagLib::SimplePropertyMap::ConstIterator it;
        for(it = pm.begin(); it != pm.end(); it++) {
            NSString *key = [NSString stringWithUTF8String:it->first.toCString(true)];
            NSString *value = [NSString stringWithUTF8String:it->second.toString(", ").toCString(true)];

            [retval setValue:value forKey:key];
        }
    }

    return retval;
}


-(void)dealloc {
    delete _fileref;
}


@end
