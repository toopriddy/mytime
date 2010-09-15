//
//  NSData_PSCompress.h
//  MyTime
//
//  Created by Brent Priddy on 4/7/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (PSCompress)

- (NSData *)compress;
- (NSData *)compress:(NSError **)errorOut;
- (NSData *)decompress;
- (NSData *)decompress:(NSError **)errorOut;

@end


