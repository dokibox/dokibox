//
//  LastFMScrobblerPluginAPICall.h
//  dokibox
//
//  Created by Miles Wu on 16/09/2013.
//  Copyright (c) 2015 Miles Wu and contributors. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LastFMScrobblerPluginAPICall : NSObject {
    NSMutableDictionary *_parameters;
}
+(NSString *)apiKey;

-(void)setParameter:(NSString*)name value:(NSString*)value;
-(NSXMLDocument*)performGET;
-(NSXMLDocument*)performPOST;
-(NSXMLDocument*)performRequest:(BOOL)isPost;

@end
