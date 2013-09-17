//
//  LastFMScrobblerPluginAPICall.h
//  dokibox
//
//  Created by Miles Wu on 16/09/2013.
//
//

#import <Foundation/Foundation.h>

@interface LastFMScrobblerPluginAPICall : NSObject {
    NSMutableDictionary *_parameters;
}
+(NSString *)apiKey;

-(void)setParameter:(NSString*)name value:(NSString*)value;
-(NSXMLDocument*)performRequest;

@end
