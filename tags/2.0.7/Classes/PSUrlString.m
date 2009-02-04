//
//  PSUrlString.m
//  MyTime
//
//  Created by Brent Priddy on 2/4/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "PSUrlString.h"


@implementation NSString (PSUrlString)

- (NSString *)stringWithEscapedCharacters
{
	NSString *temp = [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	temp = [temp stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
	return temp;
}

@end
