//
//  MyTime
//
//  Created by Brent Priddy on 12/29/07.
//  Copyright 2007 PG Software. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UIThreePartButton.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UITable.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UITableColumn.h>
#import <UIKit/UIPickerView.h>
#import <UIKit/UISectionIndex.h>
#import "App.h"
#import "MainView.h"
#import "CallView.h"
#import "SortedCallsView.h"


#define ARRAY_SIZE(a) (sizeof(a)/sizeof(a[0]))

@implementation CustomSectionList
- (UISectionIndex *)sectionIndex
{
	return(_index);
}
@end

@implementation SortedCallsView

- (void)unselectRow
{
	DEBUG(NSLog(@"unselectRow");)
	// unselect the row
	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
}


- (void)setBounds:(CGRect)boundsRect
{
	_rect = boundsRect;
	[super setBounds:boundsRect];
}


- (int)numberOfRowsInTable:(UITable*)table
{
	return [_calls count];
}

- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(UITableColumn *)column
{
	id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
	NSString *title = [[[NSString alloc] init] autorelease];
	NSString *houseNumber = [[_calls objectAtIndex:row] objectForKey:CallStreetNumber ];
	NSString *street = [[_calls objectAtIndex:row] objectForKey:CallStreet];

	if(houseNumber && [houseNumber length])
		title = [title stringByAppendingFormat:@"%@ ", houseNumber];
	if(street && [street length])
		title = [title stringByAppendingString:street];
	if([title length] == 0)
		title = @"(unknown street)";

	[cell setTitle: title];

	CGSize s = CGSizeMake( [column width], [table rowHeight] );
	UITextLabel* label = [[[UITextLabel alloc] initWithFrame: CGRectMake(200,0,s.width,s.height)] autorelease];
	float bgColor[] = { 0,0,0,0 };
	[label setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	[label setText:[[_calls objectAtIndex:row] objectForKey:CallName]];
	[cell addSubview: label];

	return cell;
}

-(BOOL)table:(UITable*)table showDisclosureForRow:(int)row
{
    return(NO);
}

-(BOOL)table:(UITable*)table canDeleteRow:(int)row
{
	return YES;
}

-(void)table:(UITable*)table movedRow:(int)fromRow toRow:(int)toRow
{
    DEBUG(NSLog(@"table: movedRow");)
}

- (void)tableRowSelected:(NSNotification*)notification
{
    int row = [[notification object] selectedRow];
    DEBUG(NSLog(@"tableRowSelected: tableRowSelected row=%@ row%d", notification, row);)

    if(row < [_calls count])
    {
        // save this row so we know where to stick the changes when the 
        // user is done
        _selectedCall = row;

        // make the new call view 
        CallView *p = [[[CallView alloc] initWithFrame:[[App getInstance] rect] call:[_calls objectAtIndex:row]] autorelease];

        // setup the callbacks for save or cancel
        [p setCancelAction: @selector(editCallCancelAction:) forObject:self];
        [p setSaveAction: @selector(editCallSaveAction:) forObject:self];
        [p setDeleteAction: @selector(editCallDeleteAction:) forObject:self];
		[p setAutoresizingMask: kMainAreaResizeMask];
		[p setAutoresizesSubviews: YES];

        // transition from bottom up sliding ontop of the old view
        [[App getInstance] transition:1 fromView:[[App getInstance] mainView] toView:p];
    }
}

- (int)numberOfSectionsInSectionList:(UISectionList *)aSectionList 
{
	int ret;
	switch(_sortBy)
	{
		case CALLS_SORTED_BY_DATE:
			ret = 1;
			break;
			
		case CALLS_SORTED_BY_CITY:
			ret = [_citySections count];
			break;
			
		case CALLS_SORTED_BY_STREET:
			ret = [_streetSections count];
			break;
	}
	VERBOSE(NSLog(@"numberOfSectionsInSectionList: return=%d", ret);)
	return ret;
}

- (NSString *)sectionList:(UISectionList *)aSectionList titleForSection:(int)section 
{
	NSString *name;

	switch(_sortBy)
	{
		case CALLS_SORTED_BY_DATE:
			name = @"Oldest Return Visits First";
			break;
			
		case CALLS_SORTED_BY_CITY:
			name = [_citySections objectAtIndex:section];
			break;

		case CALLS_SORTED_BY_STREET:
			name = [_streetSections objectAtIndex:section];
			break;
	}
	VERBOSE(NSLog(@"sectionList: titleForSection:%d return = %@", section, name);)
	return(name);
}       

- (int)sectionList:(UISectionList *)aSectionList rowForSection:(int)section 
{
	int ret;
	switch(_sortBy)
	{
		case CALLS_SORTED_BY_DATE:
			ret = 0;
			break;
			
		case CALLS_SORTED_BY_CITY:
			ret = [[_cityOffsets objectAtIndex:section] intValue];
			break;

		case CALLS_SORTED_BY_STREET:
			ret = [[_streetOffsets objectAtIndex:section] intValue];
			break;
	}
	VERBOSE(NSLog(@"sectionList: section:%d (cont=%d) return=%d", section, [_streetOffsets count], ret);)
	return(ret);
}

- (void)navigationBar:(UINavigationBar*)nav buttonClicked:(int)button
{
    DEBUG(NSLog(@"navigationBar: buttonClicked:%s", button ? "Edit" : "+");)

	if(button == 0)
	{
		// make the new call view 
		CallView *p = [[[CallView alloc] initWithFrame:[[App getInstance] rect]] autorelease];
		
		// setup the callbacks for save or cancel
		[p setCancelAction: @selector(addNewCallCancelAction:) forObject:self];
		[p setSaveAction: @selector(addNewCallSaveAction:) forObject:self];
		[p setAutoresizingMask: kMainAreaResizeMask];
		[p setAutoresizesSubviews: YES];

		// transition from bottom up sliding ontop of the old view
		[[App getInstance] transition:8 fromView:[[App getInstance] mainView] toView:p];
	}
}

- (void) dealloc
{
    DEBUG(NSLog(@"SortedCallsView: dealloc");)
    
    [_navigationBar release];
	[_savedSectionIndex release];
    [_section release];
	
    [super dealloc];
}

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
	
	int compare = [street1 localizedCaseInsensitiveCompare:street2];
	if(compare == 0)
	{
		compare = [house1 compare:house2];
		if(compare == 0)
		{
			compare = sortByName(v1, v2, context);
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

- (void)updateSections
{
	VERBOSE(NSLog(@"updateSections");)
	
	// sort the data
	// we should sort by the house number too
	NSArray *sortedArray;
	switch(_sortBy)
	{
		case CALLS_SORTED_BY_STREET:
			sortedArray = [_calls sortedArrayUsingFunction:sortByStreet context:NULL];	
			break;
		case CALLS_SORTED_BY_DATE:
			sortedArray = [_calls sortedArrayUsingFunction:sortByDate context:NULL];
			break;
		case CALLS_SORTED_BY_CITY:
			sortedArray = [_calls sortedArrayUsingFunction:sortByCity context:NULL];
			break;
	}
	[sortedArray retain];
	[_calls setArray:sortedArray];
	[sortedArray release];
	
	int i;
	int count = [_calls count];
	[_streetSections removeAllObjects];
	[_streetOffsets removeAllObjects];
	VERY_VERBOSE(NSLog(@"count=%d", count);)
	NSString *lastSectionTitle = @"";
	for(i = 0; i < count; ++i)
	{
		NSString *sectionTitle;
		NSString *street = [[_calls objectAtIndex:i] objectForKey:CallStreet];
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
		BOOL addSection = NO;
		if([_streetSections count] == 0) 
		{
			addSection = YES;
		}
		else 
		{
			if(![sectionTitle isEqual:lastSectionTitle])
			{
				addSection = YES;
			}
		}

		if(addSection == YES)
		{
			lastSectionTitle = sectionTitle;
			VERY_VERBOSE(NSLog(@"added");)
			[_streetOffsets addObject:[NSNumber numberWithInt:i]];
			[_streetSections addObject:sectionTitle];
		}
	}

	[_citySections removeAllObjects];
	[_cityOffsets removeAllObjects];
	VERY_VERBOSE(NSLog(@"count=%d", count);)
	lastSectionTitle = @"";
	for(i = 0; i < count; ++i)
	{
		NSString *sectionTitle;
		NSString *city = [[_calls objectAtIndex:i] objectForKey:CallCity];
		if([city length] == 0)
		{
			sectionTitle = @"Unknown";
		}
		else
		{
			sectionTitle = city;
		}
		VERY_VERBOSE(NSLog(@"title=%@ city=%@", sectionTitle, city);)
		// lets see if the new section has a different letter than the previous or if
		// this is the first entry add it to the sections
		BOOL addSection = NO;
		if([_citySections count] == 0) 
		{
			addSection = YES;
		}
		else 
		{
			if(![sectionTitle isEqual:lastSectionTitle])
			{
				addSection = YES;
			}
		}

		if(addSection == YES)
		{
			lastSectionTitle = sectionTitle;
			VERY_VERBOSE(NSLog(@"added");)
			[_cityOffsets addObject:[NSNumber numberWithInt:i]];
			[_citySections addObject:sectionTitle];
		}
	}

	[_sectionIndex noteIndexTitlesDidChangeInSectionList:_table];
	[_section reloadData];
}

- (SortCallsType)sortBy
{
	return(_sortBy);
}

- (void)setSortBy: (SortCallsType)sortBy
{
	BOOL refresh = _sortBy != sortBy;
	
	_sortBy = sortBy;

	if(refresh)
	{
		[self updateSections];
		if(_sectionIndex)
		{
			[_sectionIndex removeFromSuperview];
		}
		if(_sortBy == CALLS_SORTED_BY_STREET)
		{
			_sectionIndex = _savedSectionIndex;
			[_section addSubview:_savedSectionIndex];
		}
		else
		{
			_sectionIndex = nil;
		}

	}
}

- (id) initWithFrame: (CGRect)rect settings:(NSMutableDictionary *)settings sortBy:(SortCallsType) sortBy
{
    if((self = [super initWithFrame: rect])) 
    {
		_settings = settings;
        _calls = [settings objectForKey:SettingsCalls];
		[_calls retain];

		[self setAutoresizingMask: kMainAreaResizeMask];
		[self setAutoresizesSubviews: YES];

		_sortBy = -1;
				
        // we should read from the file the _calls
		_streetSections = [[NSMutableArray alloc] init];
		_streetOffsets = [[NSMutableArray alloc] init];
		_citySections = [[NSMutableArray alloc] init];
		_cityOffsets = [[NSMutableArray alloc] init];
		
        
        DEBUG(NSLog(@"SortedCallsView initWithFrame: %p", self);)
        _rect = rect;   
        // make the navigation bar with
        //                        +
        CGSize s = [UINavigationBar defaultSize];
        _navigationBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0,0,rect.size.width, s.height)];
        [_navigationBar setDelegate: self];
		[_navigationBar setAutoresizingMask: kTopBarResizeMask];
		[_navigationBar setAutoresizesSubviews: YES];
		
        [self addSubview: _navigationBar]; 

		[_navigationBar showLeftButton:nil withStyle:0 rightButton:@"+" withStyle:3];
        [_navigationBar pushNavigationItem: [[[UINavigationItem alloc] initWithTitle:@"Calls"] autorelease] ];
		_tableOffset.x = s.height;
		_tableOffset.y = 0;
		_section = [[CustomSectionList alloc] initWithFrame: CGRectMake(0, s.height, rect.size.width, rect.size.height - s.height) showSectionIndex:YES]; 
        [_section setDataSource:self];
		[_section setShouldHideHeaderInShortLists:NO];
		[_section setAllowsScrollIndicators:YES];
		[_section setAutoresizingMask: kMainAreaResizeMask];
		[_section setAutoresizesSubviews: YES];
		
        _table = [_section table];
        [_table addTableColumn: [[[UITableColumn alloc] initWithTitle:@"Calls" identifier:nil width:rect.size.width] autorelease]];
        [_table setSeparatorStyle:1];
        [_table setRowHeight:48.0f];
        [_table setDelegate:self];
        [_table setDataSource:self];
		[_table setControlTint:1]; // don't know ?
		[_table setAllowsScrollIndicators:YES];		

		_sectionIndex = [_section sectionIndex];
		_savedSectionIndex = _sectionIndex;
		[_sectionIndex retain];
		
		_sortBy = -1;
		[self setSortBy:sortBy];
		
		[self addSubview: _section];
    }
    
    return(self);
}

- (void)editCallDeleteAction: (CallView *)callView
{
    DEBUG(NSLog(@"SortedCallsView editCallDeleteAction:");)

	// remove the call from the array
	NSMutableDictionary *call = [_calls objectAtIndex:_selectedCall];
	NSMutableArray *deletedCalls = [NSMutableArray arrayWithArray:[_settings objectForKey:SettingsDeletedCalls]];
	[_settings setObject:deletedCalls forKey:SettingsDeletedCalls];
	[deletedCalls addObject:call];
	[_calls removeObjectAtIndex:_selectedCall];

    //transitions:
    // 0 nothing
    // 1 slide left with the to view to the right
    // 2 slide right with the to view to the left
    // 3 from bottom up with the to view right below the from view
    // 4 from bottom up, but background seems to be invisible
    // 5 from top down, but background seems to be invisible
    // 6 fade away to the to view
    // 7 down with the to view above the from view
    // 8 from bottom up sliding ontop of
    // 9 from top down sliding ontop of
	[self updateSections];
    [[App getInstance] transition:9 fromView:callView toView:[[App getInstance] mainView]];

	// have the row unselect after the transition back to the View so that the user
	// knows where they were and what they clicked on 
	[self performSelector: @selector(unselectRow) 
			   withObject:_table
			   afterDelay:.2];
	[[App getInstance] saveData];
}


- (void)editCallCancelAction: (CallView *)callView
{
    DEBUG(NSLog(@"SortedCallsView editCallCancelAction:");)
    //transitions:
    // 0 nothing
    // 1 slide left with the to view to the right
    // 2 slide right with the to view to the left
    // 3 from bottom up with the to view right below the from view
    // 4 from bottom up, but background seems to be invisible
    // 5 from top down, but background seems to be invisible
    // 6 fade away to the to view
    // 7 down with the to view above the from view
    // 8 from bottom up sliding ontop of
    // 9 from top down sliding ontop of
	[self updateSections];
    [[App getInstance] transition:2 fromView:callView toView:[[App getInstance] mainView]];

	// have the row unselect after the transition back to the View so that the user
	// knows where they were and what they clicked on 
	[self performSelector: @selector(unselectRow) 
			   withObject:_table
			   afterDelay:.2];
}

- (void)editCallSaveAction: (CallView *)callView
{
    DEBUG(NSLog(@"SortedCallsView editCallSaveAction:");)

    // get the call from the CallView and assign it do the calltable
    [_calls replaceObjectAtIndex:_selectedCall withObject:[callView call]];
	[[App getInstance] saveData];
}

- (void)addNewCallCancelAction: (CallView *)callView
{
    DEBUG(NSLog(@"SortedCallsView addNewCallCancelAction:");)
    //transitions:
    // 0 nothing
    // 1 left right with the to view to the right
    // 2 slide right with the to view to the left
    // 3 from bottom up with the to view right below the from view
    // 4 from bottom up, but background seems to be invisible
    // 5 from top down, but background seems to be invisible
    // 6 fade away to the to view
    // 7 down with the to view above the from view
    // 8 from bottom up sliding ontop of
    // 9 from top down sliding ontop of
    [[App getInstance] transition:9 fromView:callView toView:[[App getInstance] mainView]];
}

- (void)addNewCallSaveAction: (CallView *)callView
{
    DEBUG(NSLog(@"SortedCallsView addNewCallSaveAction:");)

    // add the new call to the list of _calls at the end
    [_calls addObject:[callView call]];

	[self updateSections];
    [[App getInstance] transition:9 fromView:callView toView:[[App getInstance] mainView]];

	[[App getInstance] saveData];
}

- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"SortedCallsView respondsToSelector: %s", selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"SortedCallsView methodSignatureForSelector: %s", selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"SortedCallsView forwardInvocation: %s", [invocation selector]);)
    [super forwardInvocation:invocation];
}
@end


