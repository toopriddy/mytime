#import "MTSorter.h"
#import "MTDisplayRule.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "MTAdditionalInformationType.h"
#import "MTUser.h"
#import "PSLocalization.h"

NSString * const MTSorterGroupName = @"groupName";
NSString * const MTSorterGroupArray = @"array";
NSString * const MTSorterEntryPath = @"path";
NSString * const MTSorterEntrySectionIndexPath = @"sectionIndexPath";
NSString * const MTSorterEntryName = @"name";
NSString * const MTSorterEntryUUID = @"uuid";
NSString * const MTSorterEntryRequiresArraySorting = @"requiresArraySorting";

@implementation MTSorter

- (void)awakeFromFetch
{
	[super awakeFromFetch];
	if([self primitiveRequiresArraySorting] == nil)
	{
		self.requiresArraySortingValue = NO;
	}
}

- (void)awakeFromInsert 
{ 
	[super awakeFromInsert];
	if([self primitiveRequiresArraySorting] == nil)
	{
		[self setPrimitiveRequiresArraySortingValue:NO];
	}
}

+ (NSArray *)additionalInformationGroupArray
{
	NSMutableArray *returnArray = [NSMutableArray array];
	MTUser *currentUser = [MTUser currentUser];
	NSArray *types = [currentUser.managedObjectContext fetchObjectsForEntityName:[MTAdditionalInformationType entityName] 
															   propertiesToFetch:nil 
															 withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"name" ascending:YES]]
																   withPredicate:@"user == %@", currentUser];
	for(MTAdditionalInformationType *type in types)
	{
		NSMutableDictionary *entry = [NSMutableDictionary dictionary];
		switch(type.typeValue)
		{
			case PHONE:
				[entry setObject:@"value" forKey:MTSorterEntryPath];
				break;
			case EMAIL:
				[entry setObject:@"value" forKey:MTSorterEntryPath];
				break;
			case URL:
				[entry setObject:@"value" forKey:MTSorterEntryPath];
				break;
			case STRING:
				[entry setObject:@"value" forKey:MTSorterEntryPath];
				[entry setObject:@"sectionIndexString" forKey:MTSorterEntrySectionIndexPath];
				break;
			case NOTES:
				[entry setObject:@"value" forKey:MTSorterEntryPath];
				break;
			case CHOICE:
				[entry setObject:@"value" forKey:MTSorterEntryPath];
				[entry setObject:@"sectionIndexString" forKey:MTSorterEntrySectionIndexPath];
				break;
			case SWITCH:
				[entry setObject:@"boolean" forKey:MTSorterEntryPath];
				[entry setObject:@"sectionIndexBoolean" forKey:MTSorterEntrySectionIndexPath];
				break;
			case DATE:
				[entry setObject:@"date" forKey:MTSorterEntryPath];
				break;
			case NUMBER:
				[entry setObject:@"number" forKey:MTSorterEntryPath];
				[entry setObject:@"sectionIndexNumber" forKey:MTSorterEntrySectionIndexPath];
				break;
		}
		[entry setObject:type.uuid forKey:MTSorterEntryUUID];
		[entry setObject:type.name forKey:MTSorterEntryName];
		[entry setObject:[NSNumber numberWithBool:YES] forKey:MTSorterEntryRequiresArraySorting];
		[returnArray addObject:entry];
	}
	return returnArray;
}

+ (void)updateSortersForAdditionalInformationType:(MTAdditionalInformationType *)type
{
	NSArray *sorters = [type.managedObjectContext fetchObjectsForEntityName:[MTSorter entityName] 
															   propertiesToFetch:nil 
																   withPredicate:@"additionalInformationTypeUuid == %@", type.uuid];
	for(MTSorter *sorter in sorters)
	{
		[sorter setFromAdditionalInformationType:type];
	}
}


- (void)setFromAdditionalInformationType:(MTAdditionalInformationType *)type
{
	switch(type.typeValue)
	{
		case PHONE:
			self.path = @"value";
			break;
		case EMAIL:
			self.path = @"value";
			break;
		case URL:
			self.path = @"value";
			break;
		case STRING:
			self.path = @"value";
			self.sectionIndexPath = @"sectionIndexString";
			break;
		case NOTES:
			self.path = @"value";
			break;
		case CHOICE:
			self.path = @"value";
			self.sectionIndexPath = @"sectionIndexString";
			break;
		case SWITCH:
			self.path = @"boolean";
			self.sectionIndexPath = @"sectionIndexBoolean";
			break;
		case DATE:
			self.path = @"date";
			break;
		case NUMBER:
			self.path = @"number";
			self.sectionIndexPath = @"sectionIndexNumber";
			break;
	}
	self.additionalInformationTypeUuid = type.uuid;
	self.name = type.name;
	self.requiresArraySortingValue = YES;
}

- (SEL)selector
{
	if([self.name isEqualToString:@"value"])
	{
		return @selector(localizedCaseInsensitiveCompare:);
	}
	else 
	{
		return @selector(compare:);
	}
}

+ (NSArray *)sorterInformationArray
{
	NSArray *returnArray = 
	[[NSArray alloc] initWithObjects:
	 [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Call", @"category in the Display Rules when picking sorting rules"), MTSorterGroupName,
	  [NSArray arrayWithObjects:
	   [NSDictionary dictionaryWithObjectsAndKeys:@"name", MTSorterEntryPath, @"uppercaseFirstLetterOfName", MTSorterEntrySectionIndexPath, NSLocalizedString(@"Name", @"Title for the Display Rules 'pick a sort rule' screen"), MTSorterEntryName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"locationLookupType", MTSorterEntryPath, NSLocalizedString(@"Location Lookup Type", @"Title for the Display Rules 'pick a sort rule' screen"), MTSorterEntryName, nil],
	   nil], MTSorterGroupArray, nil],
	 [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Address", @"category in the Display Rules when picking sorting rules"), MTSorterGroupName,
	  [NSArray arrayWithObjects:
	   [NSDictionary dictionaryWithObjectsAndKeys:@"houseNumber", MTSorterEntryPath, @"houseNumber", MTSorterEntrySectionIndexPath, NSLocalizedString(@"House Number", @"Title for the Display Rules 'pick a sort rule' screen"), MTSorterEntryName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"apartmentNumber", MTSorterEntryPath, @"apartmentNumber", MTSorterEntrySectionIndexPath, NSLocalizedString(@"Apt/Floor", @"Title for the Display Rules 'pick a sort rule' screen"), MTSorterEntryName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"street", MTSorterEntryPath, @"uppercaseFirstLetterOfStreet", MTSorterEntrySectionIndexPath, NSLocalizedString(@"Street", @"Title for the Display Rules 'pick a sort rule' screen"), MTSorterEntryName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"city", MTSorterEntryPath, @"city", MTSorterEntrySectionIndexPath, NSLocalizedString(@"City", @"Title for the Display Rules 'pick a sort rule' screen"), MTSorterEntryName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"state", MTSorterEntryPath, @"state", MTSorterEntrySectionIndexPath, NSLocalizedString(@"State or Country", @"Title for the Display Rules 'pick a sort rule' screen"), MTSorterEntryName, nil],
	   nil], MTSorterGroupArray, nil],
	 [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Return Visit", @"category in the Display Rules when picking sorting rules"), MTSorterGroupName,
	  [NSArray arrayWithObjects:
	   [NSDictionary dictionaryWithObjectsAndKeys:@"mostRecentReturnVisitDate", MTSorterEntryPath, @"dateSortedSectionIndex", MTSorterEntrySectionIndexPath, NSLocalizedString(@"Most Recent Return Visit Date", @"Title for the Display Rules 'pick a sort rule' screen"), MTSorterEntryName, nil],
	   nil], MTSorterGroupArray, nil],
	 [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Additional Information", @"category in the Display Rules when picking sorting rules"), MTSorterGroupName,
	  [MTSorter additionalInformationGroupArray], MTSorterGroupArray, nil],
	 nil];
	
	return [returnArray autorelease];
}

+ (NSString *)nameForPath:(NSString *)path
{
	for(NSDictionary *group in [MTSorter sorterInformationArray])
	{
		for(NSDictionary *entry in [group objectForKey:MTSorterGroupArray])
		{
			if([[entry objectForKey:MTSorterEntryPath] isEqualToString:path])
			{
				return [entry objectForKey:MTSorterEntryName];
			}
		}
	}
	
	return nil;
}

+ (NSString *)sectionIndexPathForPath:(NSString *)path
{
	for(NSDictionary *group in [MTSorter sorterInformationArray])
	{
		for(NSDictionary *entry in [group objectForKey:MTSorterGroupArray])
		{
			if([[entry objectForKey:MTSorterEntryPath] isEqualToString:path])
			{
				return [entry objectForKey:MTSorterEntrySectionIndexPath];
			}
		}
	}
	
	return nil;
}


+ (BOOL)requiresArraySortingForPath:(NSString *)path
{
	for(NSDictionary *group in [MTSorter sorterInformationArray])
	{
		for(NSDictionary *entry in [group objectForKey:MTSorterGroupArray])
		{
			if([[entry objectForKey:MTSorterEntryPath] isEqualToString:path])
			{
				return [[entry objectForKey:MTSorterEntryRequiresArraySorting] boolValue];
			}
		}
	}
	
	return NO;
}


+ (MTSorter *)createSorterForDisplayRule:(MTDisplayRule *)displayRule
{
	// first find the highest ordering index
	double order = 0;
	for(MTSorter *sorter in [displayRule.managedObjectContext fetchObjectsForEntityName:[MTSorter entityName]
																	  propertiesToFetch:[NSArray arrayWithObject:@"order"]
																		  withPredicate:@"displayRule == %@", displayRule])
	{
		double sorterOrder = sorter.orderValue;
		if (sorterOrder > order)
			order = sorterOrder;
	}
	
	
	MTSorter *sorter = [NSEntityDescription insertNewObjectForEntityForName:[MTSorter entityName]
													 inManagedObjectContext:displayRule.managedObjectContext];
	sorter.orderValue = order + 1; // we are using the order to seperate calls and when reordering these will be mobed halfway between displayRules.
	sorter.displayRule = displayRule;
	return sorter;
}


@end
