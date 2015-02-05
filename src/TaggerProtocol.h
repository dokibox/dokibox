//
//  TaggerProtocol.h
//  dokibox
//
//  Created by Miles Wu on 22/07/2012.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TaggerProtocol <NSObject>

-(id)initWithFilename:(NSString *)filename;
-(NSMutableDictionary *)tag;
//-(NSMutableDictionary *)properties;
-(NSImage *)cover;

@end
