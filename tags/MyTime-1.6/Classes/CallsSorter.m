//
//  CallsSorter.m
//  MyTime
//
//  Created by Brent Priddy on 7/25/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "CallsSorter.h"
#import "Settings.h"

@implementation CallsSorter

@synthesize calls;
@synthesize streetSections;
@synthesize citySections;
@synthesize streetRowCount;
@synthesize cityRowCount;
@synthesize streetOffsets;
@synthesize cityOffsets;
@synthesize sortedBy;

int sortByName(id v1, id v2, void *context)
{
	NSString *name1 = [v1 objectForKey:CallName];
	NSString *name2 = [v2 objectForKey:CallName];
	
	return([name1 localizedCaseInsensitiveCompare:name2]);
}

int sortByStreet(id v1, id v2, void *context)
{
	NSString *street1 = [v1 objectForKey:CallStreet];
	NSString *street2 = [v2 objectForKey:CallStreet];
	NSNumber *house1 = [v1 objectForKey:CallStreetNumber];
	NSNumber *house2 = [v2 objectForKey:CallStreetNumber];
	NSNumber *apartment1 = [v1 objectForKey:CallApartmentNumber];
	NSNumber *apartment2 = [v2 objectForKey:CallApartmentNumber];
	
	int compare = [street1 localizedCaseInsensitiveCompare:street2];
	if(compare == 0)
	{
		compare = [house1 compare:house2];
		if(compare == 0)
		{
			compare = [apartment1 compare:apartment2];
			if(compare == 0)
			{
				compare = sortByName(v1, v2, context);
			}
		}
	}
	return(compare);
}

int sortByCity(id v1, id v2, void *context)
{
	NSString *city1 = [v1 objectForKey:CallCity];
	NSString *city2 = [v2 objectForKey:CallCity];
	
	int compare = [city1 localizedCaseInsensitiveCompare:city2];
	if(compare == 0)
	{
		compare = sortByStreet(v1, v2, context);
	}
	return(compare);
}



// sort by date where the earlier dates come first
int sortByDate(id v1, id v2, void *context)
{
	// for speed sake we are going to assume that the first entry in the array
	// is the most recent entry	
	NSArray *returnVisits1 = [v1 objectForKey:CallReturnVisits];
	NSArray *returnVisits2 = [v2 objectForKey:CallReturnVisits];
	if([returnVisits1 count] == 0)
	{
		// if there are no calls, then just sort by the street since there
		// are no dates to sort by
		if([returnVisits2 count] == 0)
			return(sortByStreet(v1, v2, context));
		else
			return(-1); // v1 is less since there is no date
	}
	else if([returnVisits2 count] == 0)
	{
		return(1); // v1 is greater than v2
	}
	else
	{
		// ok, we need to compare the dates of the calls since we have
		// at least one call for each of 
		NSDate *date1 = [[returnVisits1 objectAtIndex:0] objectForKey:CallReturnVisitDate];
		NSDate *date2 = [[returnVisits2 objectAtIndex:0] objectForKey:CallReturnVisitDate];
		return([date1 compare:date2]);
	}
}

- (void)dealloc
{
    DEBUG(NSLog(@"%s: dealloc", __FILE__);)
	self.calls = nil;
	self.citySections = nil;
	self.streetSections = nil;
	self.cityRowCount = nil;
	self.streetRowCount = nil;
	self.cityOffsets = nil;
	self.streetOffsets = nil;

	[super dealloc];
}

- (id)initSortedBy:(SortCallsType)theSortedBy
{
	[super init];
	sortedBy = theSortedBy;
	
	self.calls = [[[Settings sharedInstance] settings] objectForKey:SettingsCalls];
	if(calls == nil)
	{
		self.calls = [NSMutableArray array];
		[[[Settings sharedInstance] settings] setObject:self.calls forKey:SettingsCalls];
	}
	self.citySections = [[NSMutableArray alloc] init];
	self.streetSections = [[NSMutableArray alloc] init];
	self.cityRowCount = [[NSMutableArray alloc] init];
	self.streetRowCount = [[NSMutableArray alloc] init];
	self.cityOffsets = [[NSMutableArray alloc] init];
	self.streetOffsets = [[NSMutableArray alloc] init];
	[self refreshData];
	return(self);
}

- (void)refreshData
{
	VERY_VERBOSE(NSLog(@"refreshData:");)
	self.calls = [[[Settings sharedInstance] settings] objectForKey:SettingsCalls];

	// sort the data
	// we should sort by the house number too
	NSArray *sortedArray;
	switch(sortedBy)
	{
		case CALLS_SORTED_BY_STREET:
			sortedArray = [calls sortedArrayUsingFunction:sortByStreet context:NULL];	
			break;
		case CALLS_SORTED_BY_DATE:
			sortedArray = [calls sortedArrayUsingFunction:sortByDate context:NULL];
			break;
		case CALLS_SORTED_BY_CITY:
			sortedArray = [calls sortedArrayUsingFunction:sortByCity context:NULL];
			break;
		case CALLS_SORTED_BY_NAME:
			sortedArray = [calls sortedArrayUsingFunction:sortByName context:NULL];
			break;
		case CALLS_SORTED_BY_STUDY:
		{
			sortedArray = [calls sortedArrayUsingFunction:sortByName context:NULL];
			NSEnumerator *enumerator = [sortedArray objectEnumerator];
			NSMutableArray *newArray = [NSMutableArray array];
			NSDictionary *call;
			
			// go through all of the calls and their visits and see if they are a study
			while( (call = [enumerator nextObject]) )
			{
				NSArray *visits = [call objectForKey:CallReturnVisits];
				NSEnumerator *visitEnumerator = [visits objectEnumerator];
				NSMutableDictionary *visit;
				while( (visit = [visitEnumerator nextObject]) )
				{
					// if this is a study, then add it to the new array which will hold the sorted
					// by name list of all studies
					if([[visit objectForKey:CallReturnVisitType] isEqualToString:(NSString *)CallReturnVisitTypeStudy])
					{
						[newArray addObject:call];
						break;
					}
				}
			}
			// assign the calls to something not the real array of calls
			self.calls = [NSMutableArray array];
			// and then finally assign the filtered and sorted array to sortedArray
			sortedArray = newArray;
			break;
		}
	}
	[sortedArray retain];
	[calls setArray:sortedArray];
	[sortedArray release];

	int i;
	int count = [calls count];

	switch(sortedBy)
	{
		case CALLS_SORTED_BY_STREET:
		case CALLS_SORTED_BY_NAME:
		case CALLS_SORTED_BY_STUDY:
		{
			const NSString *key = sortedBy == CALLS_SORTED_BY_STREET ? CallStreet : CallName;
			[streetSections removeAllObjects];
			[streetRowCount removeAllObjects];
			[streetOffsets removeAllObjects];
			
			VERY_VERBOSE(NSLog(@"street count=%d", count);)
			NSString *lastSectionTitle = @"#";
			int rowCount = 0;

			[streetRowCount addObject:[NSNumber numberWithInt:0]];
			[streetOffsets addObject:[NSNumber numberWithInt:0]];
			
			if(count == 0)
			{
				[streetSections addObject:@""];
			}
			else
			{
				NSString *street = [[calls objectAtIndex:0] objectForKey:key];
				if([street length] == 0)
				{
					[streetSections addObject:lastSectionTitle];
				}
				else
				{
					[streetSections addObject:@""];
				}

				for(i = 0; i < count; ++i)
				{
					NSString *sectionTitle;
					NSString *street = [[calls objectAtIndex:i] objectForKey:key];
					
					rowCount++;
					
					if([street length] == 0)
					{
						sectionTitle = @"#";
					}
					else
					{
						unichar c = [street characterAtIndex:0];
						sectionTitle = [[NSString stringWithCharacters:&c length:1] uppercaseString];
					}
					VERY_VERBOSE(NSLog(@"title=%@ street=%@", sectionTitle, street);)
					// lets see if the new section has a different letter than the previous or if
					// this is the first entry add it to the sections
					if(![sectionTitle isEqualToString:lastSectionTitle])
					{
						lastSectionTitle = sectionTitle;
						VERY_VERBOSE(NSLog(@"added");)
						[streetRowCount addObject:[NSNumber numberWithInt:rowCount]];
						[streetOffsets addObject:[NSNumber numberWithInt:i]];
						[streetSections addObject:sectionTitle];
						rowCount = 0;
					}
				}
			}
			
			break;
		}
		
		case CALLS_SORTED_BY_CITY:
		{
			[citySections removeAllObjects];
			[cityRowCount removeAllObjects];
			[cityOffsets removeAllObjects];
			VERY_VERBOSE(NSLog(@"city count=%d", count);)
			NSString *lastSectionTitle = NSLocalizedString(@"Unknown", @"Sorted by Street Calls view section title for an unknown street");
			int rowCount = 0;

			[cityRowCount addObject:[NSNumber numberWithInt:0]];
			[cityOffsets addObject:[NSNumber numberWithInt:0]];

			if(count == 0)
			{
				[citySections addObject:@""];
			}
			else
			{
				NSString *city = [[calls objectAtIndex:0] objectForKey:CallCity];
				if([city length] == 0)
				{
					[citySections addObject:lastSectionTitle];
				}
				else
				{
					[citySections addObject:@""];
				}

				for(i = 0; i < count; ++i)
				{
					NSString *sectionTitle;
					NSString *city = [[calls objectAtIndex:i] objectForKey:CallCity];
					
					rowCount++;
					
					if([city length] == 0)
					{
						sectionTitle = NSLocalizedString(@"Unknown", @"Sorted by Street Calls view section title for an unknown street");
					}
					else
					{
						sectionTitle = city;
					}
					VERY_VERBOSE(NSLog(@"title=%@ city=%@", sectionTitle, city);)
					// lets see if the new section has a different letter than the previous or if
					// this is the first entry add it to the sections
					if(![sectionTitle isEqualToString:lastSectionTitle])
					{
						lastSectionTitle = sectionTitle;
						VERY_VERBOSE(NSLog(@"added");)
						[cityRowCount addObject:[NSNumber numberWithInt:rowCount]];
						[cityOffsets addObject:[NSNumber numberWithInt:i]];
						[citySections addObject:sectionTitle];
						rowCount = 0;
					}
				}
			}
			break;
		}
	}
}

- (NSInteger)numberOfSections 
{
	int ret = 1;
	switch(sortedBy)
	{
		case CALLS_SORTED_BY_DATE:
			ret = 1;
			break;
			
		case CALLS_SORTED_BY_CITY:
			ret = [citySections count];
			break;
			
		case CALLS_SORTED_BY_STREET:
		case CALLS_SORTED_BY_NAME:
		case CALLS_SORTED_BY_STUDY:
			ret = [streetSections count];
			break;
	}
	VERBOSE(NSLog(@"numberOfSectionsInSectionList: return=%d", ret);)
	return ret;
}

- (NSArray *)sectionIndexTitles 
{
	NSArray *ret;
	switch(sortedBy)
	{
		case CALLS_SORTED_BY_DATE:
			ret = nil;
			break;
			
		case CALLS_SORTED_BY_CITY:
			ret = citySections;
			break;
			
		case CALLS_SORTED_BY_STREET:
		case CALLS_SORTED_BY_NAME:
		case CALLS_SORTED_BY_STUDY:
			ret = [NSArray arrayWithObjects:@"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil]; 
//			ret = streetSections;
			break;
	}
	VERBOSE(NSLog(@"numberOfSectionsInSectionList: return=%@", ret);)
	return ret;
}

- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	VERBOSE(NSLog(@"sectionForSectionIndexTitle:%@ index%d", title, index);)
	NSInteger ret = index;
	switch(sortedBy)
	{
		case CALLS_SORTED_BY_DATE:
			ret = index;
			break;
			
		case CALLS_SORTED_BY_CITY:
			ret = index;
			break;
			
		case CALLS_SORTED_BY_STREET:
		case CALLS_SORTED_BY_NAME:
		case CALLS_SORTED_BY_STUDY:
		{
			NSEnumerator *e = [streetSections objectEnumerator];
			NSString *name;
			int i = 0;
			while ( (name = [e nextObject]) ) 
			{
				if([name compare:title] != NSOrderedAscending)
				{
					return(i);
				}
				i++;
			}
			return(i);
			
			break;
		}
	}
	return ret;
}


- (NSInteger)numberOfRowsInSection:(NSInteger)section 
{
	int ret;
	switch(sortedBy)
	{
		case CALLS_SORTED_BY_DATE:
			ret = [calls count];
			break;
			
		case CALLS_SORTED_BY_CITY:
			if(section == ([cityOffsets count]-1))
			{
				ret = [calls count] - [[cityOffsets objectAtIndex:section] intValue];
			}
			else
			{
				ret = [[cityOffsets objectAtIndex:(section + 1)] intValue] - [[cityOffsets objectAtIndex:section] intValue];
			}
			break;
			
		case CALLS_SORTED_BY_STREET:
		case CALLS_SORTED_BY_NAME:
		case CALLS_SORTED_BY_STUDY:
			if(section == ([streetOffsets count]-1))
			{
				ret = [calls count] - [[streetOffsets objectAtIndex:section] intValue];
			}
			else
			{
				ret = [[streetOffsets objectAtIndex:(section + 1)] intValue] - [[streetOffsets objectAtIndex:section] intValue];
			}
			break;
	}

	VERBOSE(NSLog(@"numberOfRowsInSection:%d return=%d", section, ret);)
	return(ret);
}


- (NSString *)titleForHeaderInSection:(NSInteger)section 
{
	NSString *name;

	switch(sortedBy)
	{
		case CALLS_SORTED_BY_DATE:
			name = NSLocalizedString(@"Oldest Return Visits First", @"Section Title for Date Sorted Calls 'Oldest Return Visits First'");
			break;
			
		case CALLS_SORTED_BY_CITY:
			name = [citySections objectAtIndex:section];
			break;

		case CALLS_SORTED_BY_STREET:
		case CALLS_SORTED_BY_NAME:
		case CALLS_SORTED_BY_STUDY:
			name = [streetSections objectAtIndex:section];
			break;
	}
	VERBOSE(NSLog(@"sectionList: titleForSection:%d return = %@", section, name);)
	return(name);
}

- (NSInteger)callRowOffsetForSection:(NSInteger)section
{
	NSInteger ret = 0;

	switch(sortedBy)
	{
		case CALLS_SORTED_BY_DATE:
			ret = 0;
			break;
			
		case CALLS_SORTED_BY_CITY:
			ret = [[cityOffsets objectAtIndex:section] intValue];
			break;

		case CALLS_SORTED_BY_STREET:
		case CALLS_SORTED_BY_NAME:
		case CALLS_SORTED_BY_STUDY:
			ret = [[streetOffsets objectAtIndex:section] intValue];
			break;
	}
	VERBOSE(NSLog(@"callRowOffsetForSection:%d return = %d", section, ret);)
	return(ret);
}

- (NSMutableDictionary *)callForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *call = [calls objectAtIndex:([indexPath row] + [self callRowOffsetForSection:[indexPath section]])];
	VERBOSE(NSLog(@"sectionList: cellForRowAtIndexPath:%@ return = %@", indexPath, call);)
	return(call);
}

- (void)setCall:(NSMutableDictionary *)call forIndexPath:(NSIndexPath *)indexPath
{
	[calls replaceObjectAtIndex:([indexPath row] + [self callRowOffsetForSection:[indexPath section]]) withObject:call];
//	[[[Settings sharedInstance] settings] setObject:calls forKey:SettingsCalls];
}

- (void)deleteCallAtIndexPath:(NSIndexPath *)indexPath
{
	[calls removeObjectAtIndex:([indexPath row] + [self callRowOffsetForSection:[indexPath section]])];
}

- (void)addCall:(NSMutableDictionary *)call
{
	[calls addObject:call];
//	[[[Settings sharedInstance] settings] setObject:calls forKey:SettingsCalls];
}


- (id)retain
{
    return [super retain];
}

- (NSUInteger)retainCount
{
    return [super retainCount];
}

- (void)release
{
    [super release];
}

- (id)autorelease
{
    return [super autorelease];
}


- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s respondsToSelector: %s", __FILE__, selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s methodSignatureForSelector: %s", __FILE__, selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"%s forwardInvocation: %s", __FILE__, [invocation selector]);)
    [super forwardInvocation:invocation];
}



@end
