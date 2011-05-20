//
//  PSUrlString.m
//  MyTime
//
//  Created by Brent Priddy on 2/4/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
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
