#import "MTSorter.h"
#import "MTDisplayRule.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSLocalization.h"

NSString * const MTSorterGroupName = @"groupName";
NSString * const MTSorterGroupArray = @"array";
NSString * const MTSorterEntryPath = @"path";
NSString * const MTSorterEntrySectionIndexPath = @"sectionIndexPath";
NSString * const MTSorterEntryName = @"name";

@implementation MTSorter

NSArray *globalSorterDictionary;
// Custom logic goes here.

+ (NSArray *)additionalInformationGroupArray
{
	return [NSArray array];
}

+ (NSArray *)sorterInformationArray
{
	if(globalSorterDictionary)
		return globalSorterDictionary;
	
	globalSorterDictionary = 
	[[NSArray alloc] initWithObjects:
	 [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Call", @"category in the Display Rules when picking sorting rules"), MTSorterGroupName,
	  [NSArray arrayWithObjects:
	   [NSDictionary dictionaryWithObjectsAndKeys:@"name", MTSorterEntryPath, @"uppercaseFirstLetterOfName", MTSorterEntrySectionIndexPath, NSLocalizedString(@"Most Return Visit Date", @"Title for the Display Rules 'pick a sort rule' screen"), MTSorterEntryName, nil],
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
	
	return globalSorterDictionary;
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
