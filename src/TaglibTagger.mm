//
//  TaglibTagger.m
//  dokibox
//
//  Created by Miles Wu on 22/07/2012.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import "TaglibTagger.h"

#include <taglib/mpegfile.h>
#include <taglib/flacfile.h>
#include <taglib/vorbisfile.h>
#include <taglib/mp4file.h>
#include <taglib/mp4properties.h>
#include <taglib/id3v2tag.h>
#include <taglib/attachedpictureframe.h>

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

    TagLib::PropertyMap pm = _fileref->file()->properties();
    //DDLogVerbose(@"%@", [NSString stringWithUTF8String:pm.toString().toCString(true)]);
    TagLib::SimplePropertyMap::ConstIterator it;
    for(it = pm.begin(); it != pm.end(); it++) {
        NSString *key = [NSString stringWithUTF8String:it->first.toCString(true)];
        NSString *value = [NSString stringWithUTF8String:it->second.toString(", ").toCString(true)];

        [retval setValue:value forKey:key];
    }

    if(_audioproperties) {
        [retval setValue:[NSNumber numberWithInt:_audioproperties->length()] forKey:@"length"];
        [retval setValue:[NSNumber numberWithInt:_audioproperties->bitrate()] forKey:@"bitrate"];
        [retval setValue:[NSNumber numberWithInt:_audioproperties->sampleRate()] forKey:@"samplerate"];
    }
    
    if(dynamic_cast<TagLib::MPEG::File*>(_fileref->file()))
        [retval setValue:@"MP3" forKey:@"format"];
    else if(dynamic_cast<TagLib::FLAC::File*>(_fileref->file()))
        [retval setValue:@"FLAC" forKey:@"format"];
    else if(dynamic_cast<TagLib::Ogg::Vorbis::File*>(_fileref->file()))
        [retval setValue:@"Ogg Vorbis" forKey:@"format"];
    else if(dynamic_cast<TagLib::MP4::File*>(_fileref->file())) {
        if(dynamic_cast<TagLib::MP4::File*>(_fileref->file())->audioProperties()->codec() == TagLib::MP4::Properties::AAC)
            [retval setValue:@"AAC" forKey:@"format"];
        else
            [retval setValue:@"ALAC" forKey:@"format"];
    }


    return retval;
}

-(NSImage *)cover
{
    TagLib::MPEG::File *file = dynamic_cast<TagLib::MPEG::File*>(_fileref->file());
    if(file) {
        TagLib::ID3v2::Tag *tag = file->ID3v2Tag();
        if(tag) {
            TagLib::ID3v2::FrameList l = tag->frameListMap()["APIC"];
            if(!l.isEmpty()) {
                TagLib::ID3v2::AttachedPictureFrame *frame = dynamic_cast<TagLib::ID3v2::AttachedPictureFrame*>(l.front());
                TagLib::ByteVector picture = frame->picture();
                NSData *data = [NSData dataWithBytes:(void *)(picture.data()) length:picture.size()];
                return [[NSImage alloc] initWithData:data];
            }
        }
    }

    return nil;
}


-(void)dealloc {
    delete _fileref;
}


@end
