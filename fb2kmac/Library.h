//
//  Library.h
//  fb2kmac
//
//  Created by Miles Wu on 08/02/2013.
//
//

#import <Foundation/Foundation.h>

@interface Library : NSObject

-(void)addFile:(NSString*)file;
-(void)searchDirectory:(NSString*)dir;

@end
