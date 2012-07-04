//
//  Column.h
//  fb2kmac
//
//  Created by Miles Wu on 03/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TUIKit.h>

@interface Column : NSObject {
    NSString *_key;
    int _offset;
    TUIImage *_image;
}

-(id)initWithKey:(NSString *)key offset:(int)offset;
-(void)reloadImage;

@property(copy) NSString *key;
@property() int offset;
@property() TUIImage* image;

@end
