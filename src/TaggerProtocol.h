//
//  TaggerProtocol.h
//  dokibox
//
//  Created by Miles Wu on 22/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TaggerProtocol <NSObject>

-(id)initWithFilename:(NSString *)filename;
-(NSMutableDictionary *)tag;
//-(NSMutableDictionary *)properties;


@end
