//
//  NSTableView+ContextMenu.m
//  dokibox
//
// Modifications made by Miles Wu are licensed under the project license (see: LICENSE).
/*
Original source was obtained from https://github.com/jerrykrinock/CategoriesObjC/ and are:
 
Copyright 2012 Jerome Krinock.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use the files in this repository except in compliance with the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

#import "NSTableView+ContextMenu.h"
#import <objc/runtime.h>

@implementation NSTableView (ContextMenu)

+ (void)load {
    // Swap the implementations of -menuForEvent: and -replacement_menuForEvent.
    // When the -menuForEvent: message is sent to any NSTableView instance, -replacement_menuForEvent will
    // be invoked instead.  Conversely, -replacement_menuForEvent invokes -menuForEvent:.
    Method originalMethod = class_getInstanceMethod(self, @selector(menuForEvent:)) ;
    Method replacedMethod = class_getInstanceMethod(self, @selector(replacement_menuForEvent:)) ;
    method_exchangeImplementations(originalMethod, replacedMethod);
}

- (NSMenu*)replacement_menuForEvent:(NSEvent*)event {
    SEL selector = @selector(tableView:menuForTableColumnIndex:rowIndex:) ;
    
    if ([self delegate] && [[self delegate] respondsToSelector:selector]) {
        NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil] ;
        NSInteger iCol = [self columnAtPoint:point];
        NSInteger iRow = [self rowAtPoint:point];
        
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[(NSObject *)[self delegate] methodSignatureForSelector:selector]];
        [inv setSelector:selector];
        [inv setTarget:[self delegate]];
        [inv setArgument:(void *)&self atIndex:2];
        [inv setArgument:&iCol atIndex:3];
        [inv setArgument:&iRow atIndex:4];
        [inv invoke];
        __unsafe_unretained id retval;
        [inv getReturnValue:&retval];
        return retval;
    }
    else {
        // Call the original sendEvent: method, whose implementation was exchanged with our own.
        // Note:  this ISN'T a recursive call, because this method should have been called through -sendEvent:.
        NSParameterAssert(_cmd == @selector(menuForEvent:));
        NSMenu* menu = [self replacement_menuForEvent:event];
        return menu;
    }
    
}

@end
