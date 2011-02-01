#import "MTSorter.h"

NSString * const MTSorterGroupName = @"groupName";
NSString * const MTSorterGroupArray = @"array";
NSString * const MTSorterEntryPath = @"path";
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
	[NSArray arrayWithObjects:
	 [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Call", @"category in the Display Rules when picking sorting rules"), MTSorterGroupName,
	  [NSArray arrayWithObjects:
	   [NSDictionary dictionaryWithObjectsAndKeys:@"name", MTSorterEntryPath, NSLocalizedString(@"Most Return Visit Date", @"Title for the Display Rules 'pick a sort rule' screen"), MTSorterEntryName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"locationLookupType", MTSorterEntryPath, NSLocalizedString(@"Location Lookup Type", @"Title for the Display Rules 'pick a sort rule' screen"), MTSorterEntryName, nil],
	   nil], MTSorterGroupArray, nil],
	 [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Address", @"category in the Display Rules when picking sorting rules"), MTSorterGroupName,
	  [NSArray arrayWithObjects:
	   [NSDictionary dictionaryWithObjectsAndKeys:@"houseNumber", MTSorterEntryPath, NSLocalizedString(@"House Number", @"Title for the Display Rules 'pick a sort rule' screen"), MTSorterEntryName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"apartmentNumber", MTSorterEntryPath, NSLocalizedString(@"Apt/Floor", @"Title for the Display Rules 'pick a sort rule' screen"), MTSorterEntryName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"street", MTSorterEntryPath, NSLocalizedString(@"Street", @"Title for the Display Rules 'pick a sort rule' screen"), MTSorterEntryName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"city", MTSorterEntryPath, NSLocalizedString(@"City", @"Title for the Display Rules 'pick a sort rule' screen"), MTSorterEntryName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"state", MTSorterEntryPath, NSLocalizedString(@"State or Country", @"Title for the Display Rules 'pick a sort rule' screen"), MTSorterEntryName, nil],
	   nil], MTSorterGroupArray, nil],
	 [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Return Visit", @"category in the Display Rules when picking sorting rules"), MTSorterGroupName,
	  [NSArray arrayWithObjects:
	   [NSDictionary dictionaryWithObjectsAndKeys:@"mostRecentReturnVisitDate", MTSorterEntryPath, NSLocalizedString(@"Most Return Visit Date", @"Title for the Display Rules 'pick a sort rule' screen"), MTSorterEntryName, nil],
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

@end
