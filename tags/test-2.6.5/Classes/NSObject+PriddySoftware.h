//
//  NSObject+PriddySoftware.h
//  MyTime
//
//  Created by Brent Priddy on 1/9/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//
// Inspired from Mac Developer Network podcast

#import <Foundation/Foundation.h>

@interface NSObject (PriddySoftware)

- (id)mainThreadProxy;
- (id)backgroundThreadProxy;
- (id)threadProxy:(NSThread *)object;
- (id)protocolProxy:(Protocol *)protocol;

@end

