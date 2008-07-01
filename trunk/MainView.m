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
#import <UIKit/UIButtonBar.h>
#import <UIKit/UISectionIndex.h>
#import <UIKit/UIKit.h>
#import <Foundation/NSPropertyList.h>
#import "App.h"
#import "MainView.h"
#import "CallView.h"
#import "TimeView.h"
#import "StatisticsView.h"

#define ARRAY_SIZE(a) (sizeof(a)/sizeof(a[0]))


NSString const * const CallName = @"name";
NSString const * const CallStreetNumber = @"streetNumber";
NSString const * const CallStreet = @"street";
NSString const * const CallCity = @"city";
NSString const * const CallState = @"state";
NSString const * const CallPhoneNumbers = @"phoneNumbers";
NSString const * const CallPhoneNumberType = @"type";
NSString const * const CallPhoneNumber = @"number";
NSString const * const CallReturnVisits = @"returnVisits";
NSString const * const CallReturnVisitNotes = @"notes";
NSString const * const CallReturnVisitDate = @"date";
NSString const * const CallReturnVisitPublications = @"publications";
NSString const * const CallReturnVisitPublicationTitle = @"title";
NSString const * const CallReturnVisitPublicationType = @"type";
NSString const * const CallReturnVisitPublicationName = @"name";
NSString const * const CallReturnVisitPublicationYear = @"year";
NSString const * const CallReturnVisitPublicationMonth = @"month";
NSString const * const CallReturnVisitPublicationDay = @"day";

NSString const * const SettingsBulkLiterature = @"bulkLiterature";
NSString const * const BulkLiteratureDate = @"date";
NSString const * const BulkLiteratureArray = @"literature";
NSString const * const BulkLiteratureArrayCount = @"count";
NSString const * const BulkLiteratureArrayTitle = @"title";
NSString const * const BulkLiteratureArrayType = @"type";
NSString const * const BulkLiteratureArrayName = @"name";
NSString const * const BulkLiteratureArrayYear = @"year";
NSString const * const BulkLiteratureArrayMonth = @"month";
NSString const * const BulkLiteratureArrayDay = @"day";

NSString const * const SettingsCalls = @"calls";
NSString const * const SettingsDeletedCalls = @"deletedCalls";
NSString const * const SettingsMagazinePlacements = @"magazinePlacements";

NSString const * const SettingsLastCallStreetNumber = @"lastStreetNumber";
NSString const * const SettingsLastCallStreet = @"lastStreet";
NSString const * const SettingsLastCallCity = @"lastCity";
NSString const * const SettingsLastCallState = @"lastState";
NSString const * const SettingsCurrentButtonBarView = @"currentButtonBarView";

NSString const * const SettingsTimeAlertSheetShown = @"timeAlertShown";
NSString const * const SettingsStatisticsAlertSheetShown = @"statisticsAlertShown";

NSString const * const SettingsTimeStartDate = @"timeStartDate";
NSString const * const SettingsTimeEntries = @"timeEntries";
NSString const * const SettingsTimeEntryDate = @"date";
NSString const * const SettingsTimeEntryMinutes = @"minutes";


NSString const * const SettingsDonated = @"donated";
NSString const * const SettingsFirstView = @"firstView";
NSString const * const SettingsSecondView = @"secondView";
NSString const * const SettingsThirdView = @"thirdView";
NSString const * const SettingsFourthView = @"fourthView";


static NSString *oldDataFile = @"/var/root/Library/MyTime/record.plist";
static NSString *newDataFile = @"/var/mobile/Library/MyTime/record.plist";
static NSString *newDataPath = @"/var/mobile/Library/";

@implementation MainView

#define PROPERTY_LIST 0

#if 0
- (void)setBounds:(CGRect)boundsRect
{
	boundsRect.origin.x = 0;
	boundsRect.origin.y = 0;
	_rect = boundsRect;
	[super setBounds:boundsRect];
	//[_sortedCallsView setBounds:boundsRect];
}
#endif
-(void)loadData
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDir = NO;
	NSString *theDataFile;
	if([fileManager fileExistsAtPath:newDataPath isDirectory:&isDir] && isDir)
	{
		theDataFile = newDataFile;
	}
	else
	{
		theDataFile = oldDataFile;
	}

#if PROPERTY_LIST
	NSString *errorString = nil;
	NSData *data = [[NSData alloc] initWithContentsOfFile: theDataFile];
	_settings = [NSPropertyListSerialization propertyListFromData:data 
	                                             mutabilityOption:NSPropertyListMutableContainersAndLeaves
			                                               format:nil
												 errorDescription:&errorString];

	[data release];
#else
	_settings = [[NSMutableDictionary alloc] initWithContentsOfFile: theDataFile];
#endif
	if(_settings == nil)
	{
		_settings = [[NSMutableDictionary alloc] init];
	}
	else
	{
		DEBUG(NSLog(@"restored data from file:\n%@", _settings);)
	}
}

-(void)saveData
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL isDir = NO;
	NSString *theDataFile;
	if([fileManager fileExistsAtPath:newDataPath isDirectory:&isDir] && isDir)
	{
		theDataFile = newDataFile;
	}
	else
	{
		theDataFile = oldDataFile;
	}

	DEBUG(NSLog(@"saveData");)
#if PROPERTY_LIST
	NSString *errorString = nil;
	NSData *data = [NSPropertyListSerialization dataFromPropertyList:_settings format: NSPropertyListBinaryFormat_v1_0 errorDescription:&errorString];
	[data writeToFile:theDataFile atomically:YES];
	NSLog(@"%@", errorString);
#else
	[[NSFileManager defaultManager] createDirectoryAtPath:[theDataFile stringByDeletingLastPathComponent] attributes: nil];
	[_settings writeToFile:theDataFile atomically: YES];
#endif
}

NSString const *ButtonBarOfficialName = @"buttonBarOfficialName";

- (NSArray *)buttonBarItems 
{
    return [ NSArray arrayWithObjects:
        [ NSDictionary dictionaryWithObjectsAndKeys:
          @"buttonBarItemTapped:", kUIButtonBarButtonAction,
          @"street.png", kUIButtonBarButtonInfo,
          @"streetSelected.png", kUIButtonBarButtonSelectedInfo,
          [ NSNumber numberWithInt: VIEW_SORTED_BY_STREET], kUIButtonBarButtonTag,
            self, kUIButtonBarButtonTarget,
          NSLocalizedString(@"Street Sorted", @"'Street Sorted' ButtonBar View text"), kUIButtonBarButtonTitle,
          @"0", kUIButtonBarButtonType,
          NSLocalizedString(@"Calls Sorted by Street", @"Expanded name for 'Street Sorted' ButtonBar view text when on the More view"), ButtonBarOfficialName,
          nil 
        ],

        [ NSDictionary dictionaryWithObjectsAndKeys:
          @"buttonBarItemTapped:", kUIButtonBarButtonAction,
          @"time.png", kUIButtonBarButtonInfo,
          @"timeSelected.png", kUIButtonBarButtonSelectedInfo,
          [ NSNumber numberWithInt: VIEW_SORTED_BY_DATE], kUIButtonBarButtonTag,
            self, kUIButtonBarButtonTarget,
          NSLocalizedString(@"Date Sorted", @"'Date Sorted' ButtonBar View text"), kUIButtonBarButtonTitle,
          @"0", kUIButtonBarButtonType,
		  NSLocalizedString(@"Calls Sorted by Date", @"Expanded name for 'Date Sorted' ButtonBar view text when on the More view"), ButtonBarOfficialName,
          nil 
        ],

        [ NSDictionary dictionaryWithObjectsAndKeys:
          @"buttonBarItemTapped:", kUIButtonBarButtonAction,
          @"city.png", kUIButtonBarButtonInfo,
          @"citySelected.png", kUIButtonBarButtonSelectedInfo,
          [ NSNumber numberWithInt: VIEW_SORTED_BY_CITY], kUIButtonBarButtonTag,
            self, kUIButtonBarButtonTarget,
          NSLocalizedString(@"City Sorted", @"'City Sorted' ButtonBar View text"), kUIButtonBarButtonTitle,
          @"0", kUIButtonBarButtonType,
          NSLocalizedString(@"Calls Sorted by City", @"Expanded name for 'City Sorted' ButtonBar view text when on the More view"), ButtonBarOfficialName,
          nil 
        ],

        [ NSDictionary dictionaryWithObjectsAndKeys:
          @"buttonBarItemTapped:", kUIButtonBarButtonAction,
          @"timer.png", kUIButtonBarButtonInfo,
          @"timerSelected.png", kUIButtonBarButtonSelectedInfo,
          [ NSNumber numberWithInt: VIEW_TIME], kUIButtonBarButtonTag,
            self, kUIButtonBarButtonTarget,
          NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view"), kUIButtonBarButtonTitle,
          @"0", kUIButtonBarButtonType,
		  NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view"), ButtonBarOfficialName,
          nil 
        ], 

        [ NSDictionary dictionaryWithObjectsAndKeys:
          @"buttonBarItemTapped:", kUIButtonBarButtonAction,
          @"statistics.png", kUIButtonBarButtonInfo,
          @"statisticsSelected.png", kUIButtonBarButtonSelectedInfo,
          [ NSNumber numberWithInt: VIEW_STATISTICS], kUIButtonBarButtonTag,
            self, kUIButtonBarButtonTarget,
          NSLocalizedString(@"Statistics", @"'Statistics' ButtonBar View text and Statistics View Title"), kUIButtonBarButtonTitle,
          @"0", kUIButtonBarButtonType,
		  NSLocalizedString(@"End of Month Statistics", @"Expanded name for 'Statistics' ButtonBar view text when on the More view"), ButtonBarOfficialName,
          nil 
        ], 

        [ NSDictionary dictionaryWithObjectsAndKeys:
          @"buttonBarItemTapped:", kUIButtonBarButtonAction,
          @"bulkPlacements.png", kUIButtonBarButtonInfo,
          @"bulkPlacementsSelected.png", kUIButtonBarButtonSelectedInfo,
          [ NSNumber numberWithInt: VIEW_BULK_PLACEMENTS], kUIButtonBarButtonTag,
            self, kUIButtonBarButtonTarget,
          NSLocalizedString(@"Placements", @"View Title and ButtonBar Title for the Day's Bulk Placed Publications"), kUIButtonBarButtonTitle,
          @"0", kUIButtonBarButtonType,
		  NSLocalizedString(@"Anonymous Bulk Placements", @"Expanded name for 'Placements' ButtonBar view text when on the More view"), ButtonBarOfficialName,
          nil 
        ], 

        [ NSDictionary dictionaryWithObjectsAndKeys:
          @"buttonBarItemTapped:", kUIButtonBarButtonAction,
          @"settings.png", kUIButtonBarButtonInfo,
          @"settingsSelected.png", kUIButtonBarButtonSelectedInfo,
          [ NSNumber numberWithInt: VIEW_SETTINGS], kUIButtonBarButtonTag,
            self, kUIButtonBarButtonTarget,
          NSLocalizedString(@"More", @"'More' ButtonBar View text"), kUIButtonBarButtonTitle,
          @"0", kUIButtonBarButtonType,
 		  NSLocalizedString(@"More", @"'More' ButtonBar View text"), ButtonBarOfficialName,
          nil 
        ], 

        nil
    ];
}

- (NSString *)buttonBarNameForId:(int)id
{
	NSArray *array = [self buttonBarItems];
	int i;
	int count = [array count];
	for(i = 0; i < count; i++)
	{
		NSDictionary *entry = [array objectAtIndex:i];
		if([[entry objectForKey:kUIButtonBarButtonTag] intValue] == id)
		{
			return([entry objectForKey:ButtonBarOfficialName]);
		}
	}
}

- (NSString *)buttonBarPictureForId:(int)id
{
	NSArray *array = [self buttonBarItems];
	int i;
	int count = [array count];
	for(i = 0; i < count; i++)
	{
		NSDictionary *entry = [array objectAtIndex:i];
		if([[entry objectForKey:kUIButtonBarButtonTag] intValue] == id)
		{
			return([entry objectForKey:kUIButtonBarButtonSelectedInfo]);
		}
	}
}


- (UIButtonBar *)allocButtonBarWithFrame: (CGRect)rect
{
    UIButtonBar *button;
    button = [[ UIButtonBar alloc ] initInView: self
                                     withFrame: rect
                                  withItemList: [ self buttonBarItems ] ];
    [button setDelegate:self];
    [button setBarStyle:1];
    [button setButtonBarTrackingMode: 2];

	// create the buttons to view (this should dynamically size them depending on the number
	// of buttons that we want to show
	if([_settings objectForKey:SettingsFirstView] == nil || 
	   [[_settings objectForKey:SettingsFirstView] intValue] >= END_OF_VIEWS ||
	   [[_settings objectForKey:SettingsFirstView] intValue] <= BEGINNING_OF_VIEWS)
	{
		[_settings setObject:[NSNumber numberWithInt:VIEW_SORTED_BY_STREET] forKey:SettingsFirstView];
	}
	if([_settings objectForKey:SettingsSecondView] == nil || 
	   [[_settings objectForKey:SettingsSecondView] intValue] >= END_OF_VIEWS ||
	   [[_settings objectForKey:SettingsSecondView] intValue] <= BEGINNING_OF_VIEWS)
	{
		[_settings setObject:[NSNumber numberWithInt:VIEW_SORTED_BY_DATE] forKey:SettingsSecondView];
	}
	if([_settings objectForKey:SettingsThirdView] == nil || 
	   [[_settings objectForKey:SettingsThirdView] intValue] >= END_OF_VIEWS ||
	   [[_settings objectForKey:SettingsThirdView] intValue] <= BEGINNING_OF_VIEWS)
	{
		[_settings setObject:[NSNumber numberWithInt:VIEW_TIME] forKey:SettingsThirdView];
	}
	if([_settings objectForKey:SettingsFourthView] == nil || 
	   [[_settings objectForKey:SettingsFourthView] intValue] >= END_OF_VIEWS ||
	   [[_settings objectForKey:SettingsFourthView] intValue] <= BEGINNING_OF_VIEWS)
	{
		[_settings setObject:[NSNumber numberWithInt:VIEW_STATISTICS] forKey:SettingsFourthView];
	}
	
    _buttons[0] = [[_settings objectForKey:SettingsFirstView] intValue];
	_buttons[1] = [[_settings objectForKey:SettingsSecondView] intValue];
	_buttons[2] = [[_settings objectForKey:SettingsThirdView] intValue];
	_buttons[3] = [[_settings objectForKey:SettingsFourthView] intValue];
	_buttons[4] = VIEW_SETTINGS;

    [button registerButtonGroup:0 withButtons:_buttons withCount: ARRAY_SIZE(_buttons)];
    [button showButtonGroup: 0 withDuration: 0.0f];
	[button setDelegate:self];
	int i;
	float width = rect.size.width/ARRAY_SIZE(_buttons);
    for(i = 0; i < ARRAY_SIZE(_buttons); i++) 
	{
        [[button viewWithTag:_buttons[i]] setFrame:CGRectMake( (i*width), 1.0, width, 48.0)];
    }

    return button;
}

- (void)buttonBar:(UIButtonBar *) bar didDismissCustomizeUI:(BOOL)did
{
	unsigned int count;
	[bar getVisibleButtonTags:_buttons count:&count maxItems:5];
	[_settings setObject:[NSNumber numberWithInt:_buttons[0]] forKey:SettingsFirstView];
	[_settings setObject:[NSNumber numberWithInt:_buttons[1]] forKey:SettingsSecondView];
	[_settings setObject:[NSNumber numberWithInt:_buttons[2]] forKey:SettingsThirdView];
	[_settings setObject:[NSNumber numberWithInt:_buttons[3]] forKey:SettingsFourthView];

	[_settingsView reloadData];

	[self saveData];
}

- (void)transition:(int)transition toView:(UIView *)view withAlert:(NSString *)alert
{
	if(_currentView != view)
	{
		if(_currentView)
		{
			[view setFrame:[_currentView frame]];
		}
		
		[_transitionView transition:transition fromView:_currentView toView:view withAlert:alert];
		_currentView = view;
	}
}

- (void)transition:(int)transition toView:(UIView *)view
{
	[self transition:transition toView:view withAlert:nil];
}

- (void)setView:(int)button transition:(int)transition
{
	NSString *alertText = nil;
    switch (button) 
	{
        case VIEW_SORTED_BY_STREET:
			DEBUG(NSLog(@"VIEW_SORTED_BY_STREET");)
			[_sortedCallsView setSortBy:CALLS_SORTED_BY_STREET];
			[self transition:transition toView:_sortedCallsView ];
            break;
        case VIEW_SORTED_BY_DATE:
			DEBUG(NSLog(@"VIEW_SORTED_BY_DATE");)
			[_sortedCallsView setSortBy:CALLS_SORTED_BY_DATE];
			[self transition:transition toView:_sortedCallsView ];
			break;
        case VIEW_SORTED_BY_CITY:
			DEBUG(NSLog(@"VIEW_SORTED_BY_CITY");)
			[_sortedCallsView setSortBy:CALLS_SORTED_BY_CITY];
			[self transition:transition toView:_sortedCallsView ];
			break;
        case VIEW_TIME:
			DEBUG(NSLog(@"VIEW_TIME");)
			if([_settings objectForKey:SettingsTimeAlertSheetShown] == nil)
			{
				alertText = NSLocalizedString(@"You can delete time entries just like you can delete emails, podcasts and other things in 'tables' on the iPhone/iTouch: Swipe the row in the table from left to right and a delete button will pop up.", @"This is a note displayed when they first see the Time view");
				[_settings setObject:@"" forKey:SettingsTimeAlertSheetShown];
				[self saveData];
			}
			[self transition:transition toView:_timeView withAlert:alertText];
			break;
        case VIEW_STATISTICS:
			DEBUG(NSLog(@"VIEW_STATISTICS");)
			[_statisticsView reloadData];
			if([_settings objectForKey:SettingsStatisticsAlertSheetShown] == nil)
			{
				alertText = NSLocalizedString(@"You can see your end of the month field service activity like books, broshures, magazines, return visits and hours, but you will only see what you actually did.", @"This is a note displayed when they first see the Statistics View");
				[_settings setObject:@"" forKey:SettingsStatisticsAlertSheetShown];
				[self saveData];
			}
			[self transition:transition toView:_statisticsView withAlert:alertText];
			break;
		case VIEW_BULK_PLACEMENTS:
			DEBUG(NSLog(@"VIEW_BULK_PLACEMENTS");)
			[_settingsView reloadData];
			[self transition:transition toView:_bulkPlacementsView];
			break;
        case VIEW_SETTINGS:
			DEBUG(NSLog(@"VIEW_SETTINGS");)
			[_settingsView reloadData];
			[self transition:transition toView:_settingsView];
			break;
    }
}

- (void)setViewFromMore:(int)view
{
	[self setView:view transition:1];
	_inMoreView = YES;
	_currentButtonBarView = view;
}

- (void)buttonBarItemTapped:(id) sender 
{
    int button = [ sender tag ];
	DEBUG(NSLog(@"buttonBarItemTapped: %d", button);)
	
	// if they clicked on the button that we are currently on, then just return dont do anything
	if(button == _currentButtonBarView)
		return;
	
	[self setView:button transition:(_inMoreView ? 2 : 0)];
	_inMoreView = NO;
	
	_currentButtonBarView = button;
    [_settings setObject:[[[NSNumber alloc] initWithInt:_currentButtonBarView] autorelease] forKey:SettingsCurrentButtonBarView];
}



- (void) dealloc
{
    DEBUG(NSLog(@"MainView: dealloc");)
    
    [super dealloc];
}

- (id) initWithFrame: (CGRect)rect
{
    if((self = [super initWithFrame: rect])) 
    {
		_currentView = nil;
		
        //calls = [[NSMutableArray alloc] init];
		//create the calls array from a file's data
		[self loadData];
		
		// get the calls array and make sure that there is one
		NSMutableArray *calls = [_settings objectForKey:SettingsCalls];
		if(calls == nil)
		{
			calls = [[[NSMutableArray alloc] init] autorelease];
			[_settings setObject:calls forKey:SettingsCalls];
		}
		else
		{
			// make sure that the array we created is a NSMtable array and not
			// a NSArray from restoring for a file
			NSMutableArray *tempArray = [[NSMutableArray alloc] init];
			[tempArray setArray:calls];
			[_settings setObject:calls forKey:SettingsCalls];
		}
		
		// create the transition view to change between the time and sorted calls view
        _transitionView = [[MainTransitionView alloc] initWithFrame:rect];
		[_transitionView setAutoresizingMask: kMainAreaResizeMask];
		[_transitionView setAutoresizesSubviews: YES];
        VERBOSE(NSLog(@"MainView initWithFrame: %p", self);)
		// we are given the full screen rect, now lets chop it up
        _rect = rect;

		// take away the height of the button bar
		rect.size.height -= 49.0f;
		// create the SortedCallsView
        NSNumber *buttonBarValue = [_settings objectForKey:SettingsCurrentButtonBarView];
        if(buttonBarValue != nil)
        {
            _currentButtonBarView = [buttonBarValue intValue];
        }
        else
        {
		    _currentButtonBarView = VIEW_SORTED_BY_STREET;
        }

		
		// create the buttonbar and add it at the lat 49pix of the screen
		CGRect buttonBarRect = rect;
		buttonBarRect.origin.y = buttonBarRect.size.height;
		buttonBarRect.size.height = 49.0f; 
		_inMoreView = NO;
		_buttonBar = [self allocButtonBarWithFrame:buttonBarRect];
		[_buttonBar setAutoresizingMask: kButtonBarResizeMask];
		[_buttonBar setAutoresizesSubviews: YES];

        // create the calls view
		_sortedCallsView = [[SortedCallsView alloc] initWithFrame:rect 
		                                                 settings:_settings
													       sortBy:CALLS_SORTED_BY_STREET];
		[_sortedCallsView setAutoresizingMask: kMainAreaResizeMask];
		[_sortedCallsView setAutoresizesSubviews: YES];

		// create the SettingsView
		_settingsView = [[SettingsView alloc] initWithFrame:rect settings:_settings];
		[_settingsView setAutoresizingMask: kMainAreaResizeMask];
		[_settingsView setAutoresizesSubviews: YES];

		// create the TimeView
		_timeView = [[TimeView alloc] initWithFrame:rect settings:_settings];
		[_timeView setAutoresizingMask: kMainAreaResizeMask];
		[_timeView setAutoresizesSubviews: YES];

		// create the TimeView
		_statisticsView = [[StatisticsView alloc] initWithFrame:rect settings:_settings];
		[_statisticsView setAutoresizingMask: kMainAreaResizeMask];
		[_statisticsView setAutoresizesSubviews: YES];
		
		// create the BulkLiteraturePlacementView
		_bulkPlacementsView = [[BulkLiteraturePlacementView alloc] initWithFrame:rect settings:_settings];
		[_bulkPlacementsView setAutoresizingMask: kMainAreaResizeMask];
		[_bulkPlacementsView setAutoresizesSubviews: YES];
		
		// set the SortedCallsView as the main view
		[self addSubview: _transitionView];
		[self setView:_currentButtonBarView transition:0];

		[self addSubview: _buttonBar];
		[_buttonBar showSelectionForButton: _currentButtonBarView];

    }
    
    return(self);
}

- (void)setBounds:(CGRect)rect
{
	[super setBounds:rect];
	CGSize oldSize;

	rect.origin.x = 0;
	rect.origin.y = 0;

	// take away the height of the button bar
	rect.size.height -= 49.0f;

	VERY_VERBOSE(NSLog(@"MainView (%f, %f) height=%f width=%f", rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);)

	oldSize = [_sortedCallsView bounds].size;
	[_sortedCallsView setBounds:rect];
	[_sortedCallsView resizeSubviewsWithOldSize: oldSize];
	oldSize = [_timeView bounds].size;
	[_timeView setBounds:rect];
	[_timeView resizeSubviewsWithOldSize: oldSize];
	oldSize = [_statisticsView bounds].size;
	[_statisticsView setBounds:rect];
	[_statisticsView resizeSubviewsWithOldSize: oldSize];

	// create the buttonbar and add it at the lat 49pix of the screen
	rect.origin.y = rect.size.height;
	rect.size.height = 49.0f; 
	VERY_VERBOSE(NSLog(@"MainView (%f, %f) height=%f width=%f", rect.origin.x, rect.origin.y, rect.size.height, rect.size.width);)
//	[_buttonBar setBounds:rect];

	_rect = rect;
}


- (NSMutableDictionary *)getSavedData
{
	return(_settings);
}

- (void)setCalls:(NSMutableArray *)calls
{
	[_settings setObject:calls forKey:SettingsCalls];
	[self saveData];
}

- (void)buttonBarCustomize
{
	int count;
	int *buttons = [self allViewsWithCount:&count];
	[_buttonBar customize:buttons withCount:count];
}

- (int *)allViewsWithCount:(int *)count
{
	static int buttons[] = {
		VIEW_SORTED_BY_STREET,
		VIEW_SORTED_BY_DATE,
		VIEW_SORTED_BY_CITY,
		VIEW_TIME,
		VIEW_STATISTICS,
		VIEW_BULK_PLACEMENTS
	};
	*count = ARRAY_SIZE(buttons);
	return(buttons);
}

- (int *)unusedViewsWithCount:(int *)count
{
	static int *unused = NULL;
	int allButtonsCount;
	int *allButtons = [self allViewsWithCount:&allButtonsCount];
	int i;
	int j;
	int unusedCount = 0;
	BOOL found;
	VERY_VERBOSE(NSLog(@" allbuttons = %d", allButtonsCount);)
	if(unused == NULL)
	{
		unused = (int *)malloc(sizeof(int) * (allButtonsCount - 4));
	}
	
	for(i = 0; i < allButtonsCount; i++)
	{
		found = NO;
		for(j = 0; j < 4; j++)
		{
			if(allButtons[i] == _buttons[j])
			{
				VERY_VERBOSE(NSLog(@"found %d", _buttons[j]);)
				found = YES;
			}
		}
		if(!found)
		{
			unused[unusedCount++] = allButtons[i];
		}
	}
	*count = unusedCount;
	return(unused);
}

- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"MainView respondsToSelector: %s", selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"MainView methodSignatureForSelector: %s", selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"MainView forwardInvocation: %s", [invocation selector]);)
    [super forwardInvocation:invocation];
}
@end


