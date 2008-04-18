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
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UIPickerView.h>
#import <UIKit/UITextFieldLabel.h>
#import "SettingsView.h"
#import "MainView.h"
#import "App.h"
#import "SortedByPickerView.h"

const char* svn_version(void);

@implementation SettingsView

- (void)dealloc
{
	[_table release];
	
	[super dealloc];
}

- (void)reloadData
{
	if((_donated = [_settings objectForKey:SettingsDonated]) == nil)
		[_settings setObject:(_donated = [[NSNumber alloc] initWithInt:0]) forKey:SettingsDonated];

	_donatedAlready = [_donated intValue] != 0;

	[_table reloadData];
}

- (id) initWithFrame: (CGRect)rect settings:(NSMutableDictionary *)settings
{
    if((self = [super initWithFrame: rect])) 
    {
        DEBUG(NSLog(@"CallView initWithFrame:");)

        _rect = rect;   
		_settings = settings;
        
        _table = [[UIPreferencesTable alloc] initWithFrame: _rect];
        [self addSubview: _table];
        [_table setDelegate: self];
        [_table setDataSource: self];
		[_table enableRowDeletion: YES animated:YES];
		[_table setAutoresizingMask: kMainAreaResizeMask];
		[_table setAutoresizesSubviews: YES];
		[self reloadData];
    }
    
    return(self);
}


/******************************************************************
 *
 *   PREFERENCES TABLE DELEGATE FUNCTIONS
 *
 ******************************************************************/
- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable *)table 
{
    VERBOSE(NSLog(@"numberOfGroupsInPreferencesTable:");)
    int count = 0;

	// Donate View
	count++;
	
	// Other Views
	count++;

	// Settings
	count++;

	// mytime website
	count++;
	
	// version
	count++;
	
	VERBOSE(NSLog(@"count=%d", count);)
    return(count);
}

- (int) preferencesTable: (UIPreferencesTable *)table numberOfRowsInGroup: (int) group 
{
	int count = 0;

    switch (group)
    { 
        // Donate
        case 0:
			count++; // always show hours
			break;

        // Other Views
        case 1:
			[[[App getInstance] mainView] unusedViewsWithCount:&count];
			break;
		
        // Settings
        case 2:
			count++; 
			break;
		
        // Website
        case 3:
			count++; 
			count++; 
			break;
		
		// version 
		case 4:
			count++; //version
			count++; //build date
    }
    VERBOSE(NSLog(@"preferencesTable: numberOfRowsInGroup:%d count:%d", group, count);)
	return(count);
}

- (UIPreferencesTableCell *)preferencesTable:(UIPreferencesTable *)aTable cellForGroup:(int)group
{
    VERBOSE(NSLog(@"preferencesTable: cellForGroup:%d", group);)
	UIPreferencesTableCell *cell = nil;
	switch(group)
	{
        // Donate
		case 0:
			break;

        // Other Views
		case 1:
			cell = [[UIPreferencesTableCell alloc] init];
			[cell setTitle:@"Other Views"];
			break;
		
        // First/Second
		case 2:
			cell = [[UIPreferencesTableCell alloc] init];
			[cell setTitle:@"Settings"];
			break;
		
        // Website
        case 3:
			cell = [[UIPreferencesTableCell alloc] init];
			[cell setTitle:@"Contact Information"];
			break;
		
		// version 
		case 4:
			cell = [[UIPreferencesTableCell alloc] init];
			[cell setTitle:@"Version"];
			break;
    }
    return(cell);
} 

- (float)preferencesTable: (UIPreferencesTable *)table heightForRow: (int)row inGroup:(int)group withProposedHeight: (float)proposed 
{
    VERBOSE(NSLog(@"preferencesTable: heightForRow:%d inGroup:%d withProposedHeight:%f", row, group, proposed);)
    switch(group)
    {
		case 0:
            if (row == -1) 
            {
                return 10;
            }
        default:
            if (row == -1) 
            {
                return 40;
            }
            break;
    }
    return proposed;
}

- (BOOL)preferencesTable:(UIPreferencesTable *)aTable isLabelGroup:(int)group 
{
    VERBOSE(NSLog(@"preferencesTable: isLabelGroup:%d", group);)
	return(NO);
}


- (UIPreferencesTableCell *)preferencesTable: (UIPreferencesTable *)table cellForRow: (int)row inGroup: (int)group 
{
    VERBOSE(NSLog(@"preferencesTable: cellForRow:%d inGroup:%d", row, group);)
    UIPreferencesTableCell *cell = nil;

    switch (group) 
    {
        // Donate
        case 0:
			if(row == 0)
			{
				// if we are not editing, then 
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setValue:@"Please Donate, help me help you"];
				[cell setShowDisclosure: YES];
			}
            break;

        // Other Views
		case 1:
		{
			int count;
			int *buttons = [[[App getInstance] mainView] unusedViewsWithCount:&count];
			if(row < count)
			{
				switch(buttons[row])
				{
					case VIEW_SORTED_BY_STREET:
						cell = [[UIPreferencesTableCell alloc] init];
						[cell setTitle:@"Calls Sorted by Street"];
						[cell setShowDisclosure: YES];
						break;
					case VIEW_SORTED_BY_DATE:
						cell = [[UIPreferencesTableCell alloc] init];
						[cell setTitle:@"Calls Sorted by Date"];
						[cell setShowDisclosure: YES];
						break;
					case VIEW_TIME:
						cell = [[UIPreferencesTableCell alloc] init];
						[cell setTitle:@"Time"];
						[cell setShowDisclosure: YES];
						break;
					case VIEW_STATISTICS:
						cell = [[UIPreferencesTableCell alloc] init];
						[cell setTitle:@"Statistics"];
						[cell setShowDisclosure: YES];
						break;
					case VIEW_STUDIES:
						cell = [[UIPreferencesTableCell alloc] init];
						[cell setTitle:@"Studies"];
						[cell setShowDisclosure: YES];
						break;
				}
			}
			break;
		}
        // First/Second
		case 2:
			switch(row)
			{
				case 0:
					cell = [[UIPreferencesTableCell alloc] init];
					[cell setTitle:@"Edit Button Bar"];
                    [cell setShowDisclosure: YES];
					break;
					
			}
			break;
		
        // Website
        case 3:
			switch(row)
			{
				case 0:
					cell = [[UIPreferencesTableCell alloc] init];
					[cell setTitle:@"MyTime Website"];
                    [cell setShowDisclosure: YES];
					break;
					
				case 1:
					cell = [[UIPreferencesTableCell alloc] init];
					[cell setTitle:@"Questions, Comments? Email me"];
                    [cell setShowDisclosure: YES];
					break;
			}
			break;
		
		// version 
		case 4:
			switch(row)
			{
				case 0:
					cell = [[[UIPreferencesTableCell alloc] init] autorelease];
					[cell setTitle:@"MyTime Version"];
					[cell setValue:[NSString stringWithFormat:@"%s", svn_version()]];
					[cell setShowSelection:NO];
					break;
				case 1:
					cell = [[[UIPreferencesTableCell alloc] init] autorelease];
					[cell setTitle:@"Build Date"];
					[cell setValue:[NSString stringWithFormat:@"%s", __DATE__]];
					[cell setShowSelection:NO];
					break;
			}
			break;
    }

    return(cell);
}


- (void)tableRowSelected:(NSNotification*)notification
{
    int row = [[notification object] selectedRow];
    DEBUG(NSLog(@"tableRowSelected: tableRowSelected row=%@ row%d ", notification, row);)
	if(row == 2147483647)
	{
		return;
	}
	_selectedRow = row;

	// Donate
	if(--row == 0)
	{
		// open up a url
		NSURL *url = [NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=toopriddy%40gmail%2ecom&item_name=PG%20Software&no_shipping=0&no_note=1&tax=0&currency_code=USD&lc=US&bn=PP%2dDonationsBF&charset=UTF%2d8"];
		[[App getInstance] openURL:url];
		return;
	}

	--row; // gap

	// Other Views
	int count;
	int *buttons = [[[App getInstance] mainView] unusedViewsWithCount:&count];
	int i;
	for(i = 0; i < count; i++)
	{
		if(--row == 0)
		{
			switch(buttons[row])
			{
				case VIEW_SORTED_BY_STREET:
				case VIEW_SORTED_BY_DATE:
				case VIEW_TIME:
				case VIEW_STATISTICS:
				case VIEW_STUDIES:
					[self retain];
					[[[App getInstance] mainView] setViewFromMore:buttons[row]];
					break;
			}
		}
	}
	
	--row; // gap

	
	// Edit buttons
	if(--row == 0)
	{
		[[[App getInstance] mainView] buttonBarCustomize];
		return;
	}

	--row; // gap

	// website
	if(--row == 0)
	{
		// open up a url to mytime.googlecode.com
		NSURL *url = [NSURL URLWithString:@"http://mytime.googlecode.com"];
		[[App getInstance] openURL:url];
		return;
	}

	// email me
	if(--row == 0)
	{
		// email me
		NSURL *url = [NSURL URLWithString:@"mailto:toopriddy@gmail.com?subject=Regarding%20your%20MyTime%20application"];
		[[App getInstance] openURL:url];
		return;
	}
}

/******************************************************************
 *
 *   Button change callbacks
 *
 ******************************************************************/

- (void)changeFirstButtonCancelAction: (SortedByPickerView *)view
{
    DEBUG(NSLog(@"SettingsView changeFirstButtonCancelAction:");)
	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
    [_table setKeyboardVisible:NO animated:NO];
    [[App getInstance] transition:2 fromView:view toView:self];
    // release the refcount on ourselves since we are now the main UIView
    [self release];
}

- (void)changeFirstButtonSaveAction: (SortedByPickerView *)view
{
    DEBUG(NSLog(@"SettingsView changeFirstButtonSaveAction:");)
    VERBOSE(NSLog(@"button is now = %@", [view value]);)

    [_settings setObject:[view value] forKey:SettingsFirstView];
	_firstView = [view value];
	
	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
    [_table setKeyboardVisible:NO animated:NO];
    [[App getInstance] transition:2 fromView:view toView:self];

	[_table reloadData];
    // release the refcount on ourselves since we are now the main UIView
    [self release];

	// save the data
	[[App getInstance] saveData];
}

- (void)changeSecondButtonCancelAction: (SortedByPickerView *)view
{
    DEBUG(NSLog(@"SettingsView changeSecondButtonCancelAction:");)
	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
    [_table setKeyboardVisible:NO animated:NO];
    [[App getInstance] transition:2 fromView:view toView:self];
    // release the refcount on ourselves since we are now the main UIView
    [self release];
}

- (void)changeSecondButtonSaveAction: (SortedByPickerView *)view
{
    DEBUG(NSLog(@"SettingsView changeSecondButtonSaveAction:");)
    VERBOSE(NSLog(@"button is now = %@", [view value]);)

    [_settings setObject:[view value] forKey:SettingsSecondView];
	_secondView = [view value];
	
	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
    [_table setKeyboardVisible:NO animated:NO];
    [[App getInstance] transition:2 fromView:view toView:self];

	[_table reloadData];
    // release the refcount on ourselves since we are now the main UIView
    [self release];

	// save the data
	[[App getInstance] saveData];
}


- (BOOL)respondsToSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"StatisticsView respondsToSelector: %s", selector);)
	return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"StatisticsView methodSignatureForSelector: %s", selector);)
	return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
	VERY_VERBOSE(NSLog(@"StatisticsView forwardInvocation: %s", [invocation selector]);)
	[super forwardInvocation:invocation];
}

@end

