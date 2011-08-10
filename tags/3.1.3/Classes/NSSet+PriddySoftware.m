//
//  NSString+PriddySoftware.m
//  MyTime
//
//  Created by Brent Priddy on 9/18/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "NSString+PriddySoftware.h"

@implementation NSSet (PriddySoftrware)
- (NSArray *)sortedArrayUsingDescriptors:(NSArray *)sortDescriptors 
{
	return [[self allObjects] sortedArrayUsingDescriptors:sortDescriptors];
}

@end
