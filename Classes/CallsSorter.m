//
//  CallsSorter.m
//  MyTime
//
//  Created by Brent Priddy on 7/25/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "CallsSorter.h"
#import "Settings.h"
#import "PSLocalization.h"

@interface CallsSorter ()

- (BOOL)isFilteredText:(NSString *)searchText inObject:(NSObject *)entry;
- (BOOL)isFilteredText:(NSString *)searchText inArray:(NSArray *)array;
- (BOOL)isFilteredText:(NSString *)searchText inDictionary:(NSDictionary *)dictionary;

@end



@implementation CallsSorter

@synthesize calls;
@synthesize sectionNames;
@synthesize sectionIndexNames;
@synthesize sectionRowCount;
@synthesize sectionOffsets;
@synthesize sortedBy;
@synthesize displayArray = _displayArray;
@synthesize searchText = _searchText;

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
	NSString *house1 = [v1 objectForKey:CallStreetNumber];
	NSString *house2 = [v2 objectForKey:CallStreetNumber];
	NSString *apartment1 = [v1 objectForKey:CallApartmentNumber];
	NSString *apartment2 = [v2 objectForKey:CallApartmentNumber];
	
	int compare = [street1 localizedCaseInsensitiveCompare:street2];
	if(compare == 0)
	{
		NSInteger house1Number = [house1 integerValue];
		NSInteger house2Number = [house2 integerValue];
		if(house1Number == 0 || house1Number == 0)
		{
			compare = [house1 compare:house2];
		}
		else
		{
			if(house1Number == house2Number)
			{
				compare = NSOrderedSame;
			}
			else if(house1Number < house2Number)
			{
				compare = NSOrderedAscending;
			}
			else
			{
				compare = NSOrderedDescending;
			}
		}
		if(compare == NSOrderedSame)
		{
			NSInteger apartment1Number = [apartment1 integerValue];
			NSInteger apartment2Number = [apartment2 integerValue];
			if(apartment1Number == 0 || apartment1Number == 0)
			{
				compare = [apartment1 compare:apartment2];
			}
			else
			{
				if(apartment1Number == apartment2Number)
				{
					compare = NSOrderedSame;
				}
				else if(apartment1Number < apartment2Number)
				{
					compare = NSOrderedAscending;
				}
				else
				{
					compare = NSOrderedDescending;
				}
			}
			if(compare == NSOrderedSame)
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
	self.sectionNames = nil;
	self.sectionRowCount = nil;
	self.sectionOffsets = nil;
	self.displayArray = nil;
	
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
	[self refreshData];
	return(self);
}

- (void)filterUsingSearchText:(NSString *)searchText
{
	self.searchText = searchText;
}


- (BOOL)isFilteredText:(NSString *)searchText inObject:(NSObject *)entry
{
	if([entry isKindOfClass:[NSString class]])
	{
		if([(NSString *)entry rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
		{
			return YES;
		}
	}
	else if([entry isKindOfClass:[NSArray class]])
	{
		if([self isFilteredText:searchText inArray:(NSArray *)entry])
		{
			return YES;
		}
	}
	else if([entry isKindOfClass:[NSDictionary class]])
	{
		if([self isFilteredText:searchText inDictionary:(NSDictionary *)entry])
		{
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)isFilteredText:(NSString *)searchText inArray:(NSArray *)array
{
	for(NSObject *entry in array)
	{
		if([self isFilteredText:searchText inObject:entry])
			return YES;
	}
	return NO;
}


- (BOOL)isFilteredText:(NSString *)searchText inDictionary:(NSDictionary *)dictionary
{
	NSEnumerator *enumerator = [dictionary objectEnumerator];
	NSObject *entry;
	while( (entry = [enumerator nextObject]) )
	{
		if([self isFilteredText:searchText inObject:entry])
			return YES;
	}
	
	return NO;
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
			self.displayArray = nil;
			break;
		case CALLS_SORTED_BY_DATE:
			sortedArray = [calls sortedArrayUsingFunction:sortByDate context:NULL];
			self.displayArray = nil;
			break;
		case CALLS_SORTED_BY_CITY:
			sortedArray = [calls sortedArrayUsingFunction:sortByCity context:NULL];
			self.displayArray = nil;
			break;
		case CALLS_SORTED_BY_NAME:
			sortedArray = [calls sortedArrayUsingFunction:sortByName context:NULL];
			self.displayArray = nil;
			break;
		case CALLS_SORTED_BY_STUDY:
		{
			sortedArray = [calls sortedArrayUsingFunction:sortByName context:NULL];
			NSEnumerator *enumerator = [sortedArray objectEnumerator];
			self.displayArray = [NSMutableArray array];
			NSDictionary *call;
			int i = 0;
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
					if([[visit objectForKey:CallReturnVisitType] isEqualToString:CallReturnVisitTypeStudy])
					{
						[_displayArray addObject:[NSNumber numberWithInt:i]];
						break;
					}
				}
				i++;
			}
			break;
		}
	}

	if(_searchText && _searchText.length)
	{
		if(_displayArray)
		{
			NSMutableArray *filteredArray = [NSMutableArray array];
			int i = 0;
			for(NSNumber *number in _displayArray)
			{
				if([self isFilteredText:_searchText inDictionary:[sortedArray objectAtIndex:[number intValue]]])
				{
					[filteredArray addObject:number];
				}
				i++;
			}
			self.displayArray = filteredArray;
		}
		else
		{
			self.displayArray = [NSMutableArray array];

			int i = 0;
			for(NSDictionary *call in sortedArray)
			{
				if([self isFilteredText:_searchText inDictionary:call])
				{
					[_displayArray addObject:[NSNumber numberWithInt:i]];
				}
				i++;
			}
		}
	}

	[sortedArray retain];
	[calls setArray:sortedArray];
	[sortedArray release];

	int i;
	int count;
	if(_displayArray)
		count = [_displayArray count];
	else
		count = [calls count];

	// reinitalize the info
	self.sectionNames = [NSMutableArray array];
	self.sectionIndexNames = [NSMutableArray array];
	self.sectionRowCount = [NSMutableArray array];
	self.sectionOffsets = [NSMutableArray array];

	if(_searchText == nil || _searchText.length == 0)
	{
		switch(sortedBy)
		{
			case CALLS_SORTED_BY_DATE:
			{
				self.sectionIndexNames = nil;
				[sectionNames addObject:NSLocalizedString(@"Oldest Return Visits First", @"Section Title for Date Sorted Calls 'Oldest Return Visits First'")];
				[sectionOffsets addObject:[NSNumber numberWithInt:0]];
				break;
			}
			
			case CALLS_SORTED_BY_STREET:
			case CALLS_SORTED_BY_NAME:
			case CALLS_SORTED_BY_STUDY:
			{
				NSString *key = sortedBy == CALLS_SORTED_BY_STREET ? CallStreet : CallName;
				self.sectionIndexNames = [NSMutableArray arrayWithObjects:@"{search}", @"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil]; 
				
				VERY_VERBOSE(NSLog(@"street count=%d", count);)
				NSString *lastSectionTitle = @"#";
				int rowCount = 0;

				[sectionRowCount addObject:[NSNumber numberWithInt:0]];
				[sectionOffsets addObject:[NSNumber numberWithInt:0]];
				
				if(count == 0)
				{
					[sectionNames addObject:@""];
				}
				else
				{
					NSString *street;
					if(_displayArray)
						street = [[calls objectAtIndex:[[_displayArray objectAtIndex:0] intValue]] objectForKey:key];
					else
						street = [[calls objectAtIndex:0] objectForKey:key];
						
					if([street length] == 0)
					{
						[sectionNames addObject:lastSectionTitle];
					}
					else
					{
						[sectionNames addObject:@""];
					}

					for(i = 0; i < count; ++i)
					{
						NSString *sectionTitle;
						if(_displayArray)
							street = [[calls objectAtIndex:[[_displayArray objectAtIndex:i] intValue]] objectForKey:key];
						else
							street = [[calls objectAtIndex:i] objectForKey:key];
						
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
							[sectionRowCount addObject:[NSNumber numberWithInt:rowCount]];
							[sectionOffsets addObject:[NSNumber numberWithInt:i]];
							[sectionNames addObject:sectionTitle];
							rowCount = 0;
						}
					}
				}
				
				break;
			}
			
			case CALLS_SORTED_BY_CITY:
			{
				VERY_VERBOSE(NSLog(@"city count=%d", count);)
				NSString *lastSectionTitle = NSLocalizedString(@"Unknown", @"Sorted by Street Calls view section title for an unknown street");
				int rowCount = 0;

				[sectionRowCount addObject:[NSNumber numberWithInt:0]];
				[sectionOffsets addObject:[NSNumber numberWithInt:0]];

				if(count == 0)
				{
					[sectionNames addObject:@""];
				}
				else
				{
					NSString *city = [[calls objectAtIndex:0] objectForKey:CallCity];
					if([city length] == 0)
					{
						[sectionNames addObject:lastSectionTitle];
					}
					else
					{
						[sectionNames addObject:@""];
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
							[sectionRowCount addObject:[NSNumber numberWithInt:rowCount]];
							[sectionOffsets addObject:[NSNumber numberWithInt:i]];
							[sectionNames addObject:sectionTitle];
							rowCount = 0;
						}
					}
				}
				// the index is the same as the section names
				[sectionIndexNames setArray:sectionNames];
				break;
			}
			case CALLS_SORTED_BY_METADATA:
			{
				self.sectionRowCount = [NSMutableArray array];
				self.sectionOffsets = [NSMutableArray array];
				self.sectionNames = [NSMutableArray array];

				VERY_VERBOSE(NSLog(@"city count=%d", count);)
				NSString *lastSectionTitle = NSLocalizedString(@"Unknown", @"Sorted by Street Calls view section title for an unknown street");
				int rowCount = 0;

				[sectionRowCount addObject:[NSNumber numberWithInt:0]];
				[sectionOffsets addObject:[NSNumber numberWithInt:0]];

				if(count == 0)
				{
					[sectionNames addObject:@""];
				}
				else
				{
					NSString *city = [[calls objectAtIndex:0] objectForKey:CallCity];
					if([city length] == 0)
					{
						[sectionNames addObject:lastSectionTitle];
					}
					else
					{
						[sectionNames addObject:@""];
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
							[sectionRowCount addObject:[NSNumber numberWithInt:rowCount]];
							[sectionOffsets addObject:[NSNumber numberWithInt:i]];
							[sectionNames addObject:sectionTitle];
							rowCount = 0;
						}
					}
				}
				break;
			}
		}
	}
	else
	{
		// we are searching so there is only one section
		self.sectionIndexNames = nil;
		[sectionNames addObject:NSLocalizedString(@"Search Results", @"Section Title when the user is searching")];
		[sectionOffsets addObject:[NSNumber numberWithInt:0]];
	}
}

- (NSInteger)numberOfSections 
{
	int ret = [sectionNames count];
	if(ret <= 0)
		ret = 1;
	VERBOSE(NSLog(@"numberOfSectionsInSectionList: return=%d", ret);)
	return ret;
}

- (NSArray *)sectionIndexTitles 
{
	VERBOSE(NSLog(@"numberOfSectionsInSectionList: return=%@", sectionNames);)
	if(_searchText == nil || _searchText.length == 0)
		return sectionIndexNames;
	else
		return nil;
}

- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	VERBOSE(NSLog(@"sectionForSectionIndexTitle:%@ index%d", title, index);)
	NSInteger ret = index;
	if([title isEqualToString:@"{search}"])
	{
		return -1;
	}
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
			NSEnumerator *e = [sectionNames objectEnumerator];
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
	if(section == ([sectionOffsets count]-1))
	{
		if(_displayArray)
			ret = [_displayArray count] - [[sectionOffsets objectAtIndex:section] intValue];
		else
			ret = [calls count] - [[sectionOffsets objectAtIndex:section] intValue];
	}
	else
	{
		ret = [[sectionOffsets objectAtIndex:(section + 1)] intValue] - [[sectionOffsets objectAtIndex:section] intValue];
	}
	VERBOSE(NSLog(@"numberOfRowsInSection:%d return=%d", section, ret);)
	return(ret);
}


- (NSString *)titleForHeaderInSection:(NSInteger)section 
{
	NSString *name = [sectionNames objectAtIndex:section];
	VERBOSE(NSLog(@"sectionList: titleForSection:%d return = %@", section, name);)
	return name;
}

- (NSInteger)callRowOffsetForSection:(NSInteger)section
{
	NSInteger ret = [[sectionOffsets objectAtIndex:section] intValue];
	VERBOSE(NSLog(@"callRowOffsetForSection:%d return = %d", section, ret);)
	return(ret);
}

- (NSMutableDictionary *)callForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int index;
	if(_displayArray)
		index = [[_displayArray objectAtIndex:([indexPath row] + [self callRowOffsetForSection:[indexPath section]])] intValue];
	else
		index = [indexPath row] + [self callRowOffsetForSection:[indexPath section]];

	NSMutableDictionary *call = [calls objectAtIndex:index];
	VERBOSE(NSLog(@"sectionList: cellForRowAtIndexPath:%@ return = %@", indexPath, call);)
	return(call);
}

- (void)setCall:(NSMutableDictionary *)call forIndexPath:(NSIndexPath *)indexPath
{
	int index;
	if(_displayArray)
		index = [[_displayArray objectAtIndex:([indexPath row] + [self callRowOffsetForSection:[indexPath section]])] intValue];
	else
		index = [indexPath row] + [self callRowOffsetForSection:[indexPath section]];

	[calls replaceObjectAtIndex:index withObject:call];
}

- (void)deleteCallAtIndexPath:(NSIndexPath *)indexPath
{
	int index;
	if(_displayArray)
		index = [[_displayArray objectAtIndex:([indexPath row] + [self callRowOffsetForSection:[indexPath section]])] intValue];
	else
		index = [indexPath row] + [self callRowOffsetForSection:[indexPath section]];
	[calls removeObjectAtIndex:index];
}

- (void)addCall:(NSMutableDictionary *)call
{
	[calls addObject:call];
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
