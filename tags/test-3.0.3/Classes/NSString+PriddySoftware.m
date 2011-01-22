//
//  NSString+PriddySoftware.m
//  MyTime
//
//  Created by Brent Priddy on 9/18/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "NSString+PriddySoftware.h"


@implementation NSString (PriddySoftrware)

- (NSComparisonResult)numericalCaseInsensitiveCompare:(NSString *)other
{
	return [self compare:other options:(NSNumericSearch | NSCaseInsensitiveSearch)];
}

@end
