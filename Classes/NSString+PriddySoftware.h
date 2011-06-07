//
//  NSString+PriddySoftware.h
//  MyTime
//
//  Created by Brent Priddy on 9/18/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (PriddySoftrware) 
@end

@interface NSString (PriddySoftrware) 

- (NSComparisonResult)numericalCaseInsensitiveCompare:(NSString *)other;
+ (NSString *)stringFromGeneratedUUID;
@end
