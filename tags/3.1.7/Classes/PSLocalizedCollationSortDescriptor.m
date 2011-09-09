//
//  PSLocalizedCollationSortDescriptor.m
//  MyTime
//
//  Created by Brent Priddy on 8/25/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "PSLocalizedCollationSortDescriptor.h"


@implementation PSLocalizedCollationSortDescriptor

- (NSString *)debugDescription
{
	return [NSString stringWithFormat:@"LocalizedCollation: %@", self.key];
}

-(id)initWithSortDescriptor:(NSSortDescriptor *)sortDescriptor;
{
    if (self = [super initWithKey:sortDescriptor.key ascending:sortDescriptor.ascending selector:sortDescriptor.selector])
    {
		collation = [UILocalizedIndexedCollation currentCollation];
    }
    return self;
}

-(id)initWithReversedSortDescriptor:(NSSortDescriptor *)sortDescriptor;
{
    if (self = [super initWithKey:sortDescriptor.key ascending:!sortDescriptor.ascending selector:sortDescriptor.selector])
    {
		collation = [UILocalizedIndexedCollation currentCollation];
    }
    return self;
}

- (NSComparisonResult)compareObject:(id)object1 toObject:(id)object2
{
//	UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
	NSString *key = self.key;
	int index1 = [collation sectionForObject:object1 collationStringSelector:NSSelectorFromString(key)];
	int index2 = [collation sectionForObject:object2 collationStringSelector:NSSelectorFromString(key)];
	
	if(index1 == index2)
	{
		return NSOrderedSame;
	}
	if(index1 < index2)
	{
		return NSOrderedAscending;
	}
	return NSOrderedDescending;
}

- (id)reversedSortDescriptor
{
    return [[[[self class] alloc] initWithReversedSortDescriptor:self] autorelease];
}
@end
