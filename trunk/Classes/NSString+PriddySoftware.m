//
//  NSString+PriddySoftware.m
//  MyTime
//
//  Created by Brent Priddy on 9/18/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "NSString+PriddySoftware.h"

@implementation NSNumber (PriddySoftrware)
- (NSTimeInterval)timeIntervalSinceReferenceDate
{
	return [self doubleValue];
}

@end


@implementation NSString (PriddySoftrware)

- (NSComparisonResult)numericalCaseInsensitiveCompare:(NSString *)other
{
	return [self compare:other options:(NSNumericSearch | NSCaseInsensitiveSearch)];
}

- (NSTimeInterval)timeIntervalSinceReferenceDate
{
	return [self doubleValue];
}

+ (NSString *)stringFromGeneratedUUID
{
	CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
	//get the string representation of the UUID
	NSString *uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return [uuidString autorelease];
}

@end
