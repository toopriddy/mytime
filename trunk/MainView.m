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

NSString const * const SettingsCalls = @"calls";
NSString const * const SettingsLastCallStreetNumber = @"lastStreetNumber";
NSString const * const SettingsLastCallStreet = @"lastStreet";
NSString const * const SettingsLastCallCity = @"lastCity";
NSString const * const SettingsLastCallState = @"lastState";
NSString const * const SettingsCurrentButtonBarView = @"currentButtonBarView";

NSString const * const SettingsTimeStartDate = @"timeStartDate";
NSString const * const SettingsTimeEntries = @"timeEntries";
NSString const * const SettingsTimeEntryDate = @"date";
NSString const * const SettingsTimeEntryMinutes = @"minutes";

static NSString *dataPath = @"/var/root/Library/MyTime/record.plist";

@implementation MainView

#define PROPERTY_LIST 0

-(void)loadData
{
#if PROPERTY_LIST
	NSString *errorString = nil;
	NSData *data = [[NSData alloc] initWithContentsOfFile: dataPath];
	_settings = [NSPropertyListSerialization propertyListFromData:data 
	                                             mutabilityOption:NSPropertyListMutableContainersAndLeaves
			                                               format:nil
												 errorDescription:&errorString];

	[data release];
#else
	_settings = [[NSMutableDictionary alloc] initWithContentsOfFile: dataPath];
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
	DEBUG(NSLog(@"saveData");)
#if PROPERTY_LIST
	NSString *errorString = nil;
	NSData *data = [NSPropertyListSerialization dataFromPropertyList:_settings format: NSPropertyListBinaryFormat_v1_0 errorDescription:&errorString];
	[data writeToFile:dataPath atomically:YES];
	NSLog(@"%@", errorString);
#else
	[[NSFileManager defaultManager] createDirectoryAtPath: [dataPath stringByDeletingLastPathComponent] attributes: nil];
	[_settings writeToFile: dataPath atomically: YES];
#endif
}

- (NSArray *)buttonBarItems 
{
    return [ NSArray arrayWithObjects:
        [ NSDictionary dictionaryWithObjectsAndKeys:
          @"buttonBarItemTapped:", kUIButtonBarButtonAction,
          @"street.png", kUIButtonBarButtonInfo,
          @"streetSelected.png", kUIButtonBarButtonSelectedInfo,
          [ NSNumber numberWithInt: VIEW_SORTED_BY_STREET], kUIButtonBarButtonTag,
            self, kUIButtonBarButtonTarget,
          @"Calls by Street", kUIButtonBarButtonTitle,
          @"0", kUIButtonBarButtonType,
          nil 
        ],

        [ NSDictionary dictionaryWithObjectsAndKeys:
          @"buttonBarItemTapped:", kUIButtonBarButtonAction,
          @"time.png", kUIButtonBarButtonInfo,
          @"timeSelected.png", kUIButtonBarButtonSelectedInfo,
          [ NSNumber numberWithInt: VIEW_SORTED_BY_DATE], kUIButtonBarButtonTag,
            self, kUIButtonBarButtonTarget,
          @"Calls by Date", kUIButtonBarButtonTitle,
          @"0", kUIButtonBarButtonType,
          nil 
        ],

        [ NSDictionary dictionaryWithObjectsAndKeys:
          @"buttonBarItemTapped:", kUIButtonBarButtonAction,
          @"time.png", kUIButtonBarButtonInfo,
          @"timeSelected.png", kUIButtonBarButtonSelectedInfo,
          [ NSNumber numberWithInt: VIEW_TIME], kUIButtonBarButtonTag,
            self, kUIButtonBarButtonTarget,
          @"Time", kUIButtonBarButtonTitle,
          @"0", kUIButtonBarButtonType,
          nil 
        ], 

        [ NSDictionary dictionaryWithObjectsAndKeys:
          @"buttonBarItemTapped:", kUIButtonBarButtonAction,
          @"time.png", kUIButtonBarButtonInfo,
          @"timeSelected.png", kUIButtonBarButtonSelectedInfo,
          [ NSNumber numberWithInt: VIEW_STATISTICS], kUIButtonBarButtonTag,
            self, kUIButtonBarButtonTarget,
          @"Statistics", kUIButtonBarButtonTitle,
          @"0", kUIButtonBarButtonType,
          nil 
        ], 

        nil
    ];
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
    int buttons[] = { VIEW_SORTED_BY_STREET, VIEW_SORTED_BY_DATE, VIEW_TIME, VIEW_STATISTICS };
    [button registerButtonGroup:0 withButtons:buttons withCount: ARRAY_SIZE(buttons)];
    [button showButtonGroup: 0 withDuration: 0.0f];

	int i;
	float width = rect.size.width/ARRAY_SIZE(buttons);
    for(i = 0; i < ARRAY_SIZE(buttons); i++) 
	{
        [ [ button viewWithTag:buttons[i] ] 
            setFrame:CGRectMake( (i*width), 1.0, width, 48.0)
        ];
    }
    [ button showSelectionForButton: _currentButtonBarView];

    return button;
}

- (void)transition:(int)transition toView:(UIView *)view
{
	if(_currentView != view)
	{
		[_transitionView transition:transition fromView:_currentView toView:view ];
		_currentView = view;
	}
}

- (void)setView:(int)button
{
    switch (button) 
	{
        case VIEW_SORTED_BY_STREET:
			DEBUG(NSLog(@"VIEW_SORTED_BY_STREET");)
			[_sortedCallsView setSortBy:CALLS_SORTED_BY_STREET];
			[self transition:0 toView:_sortedCallsView ];
            break;
        case VIEW_SORTED_BY_DATE:
			DEBUG(NSLog(@"VIEW_SORTED_BY_DATE");)
			[_sortedCallsView setSortBy:CALLS_SORTED_BY_DATE];
			[self transition:0 toView:_sortedCallsView ];
			break;
        case VIEW_TIME:
			DEBUG(NSLog(@"VIEW_TIME");)
			[ self transition:0 toView:_timeView];
			break;
        case VIEW_STATISTICS:
			DEBUG(NSLog(@"VIEW_STATISTICS");)
			[_statisticsView reloadData];
			[ self transition:0 toView:_statisticsView];
			break;
    }
}

- (void)buttonBarItemTapped:(id) sender 
{
    int button = [ sender tag ];
	DEBUG(NSLog(@"buttonBarItemTapped: %d", button);)
	
	// if they clicked on the button that we are currently on, then just return dont do anything
	if(button == _currentButtonBarView)
		return;

	[self setView:button];
	
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
        _transitionView = [[UITransitionView alloc] initWithFrame:rect];
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

        // create the calls view
		_sortedCallsView = [[SortedCallsView alloc] initWithFrame:rect 
		                                                    calls:[_settings objectForKey:SettingsCalls]
													       sortBy:CALLS_SORTED_BY_STREET];

		// create the TimeView
		_timeView = [[TimeView alloc] initWithFrame:rect settings:_settings];

		// create the TimeView
		_statisticsView = [[StatisticsView alloc] initWithFrame:rect settings:_settings];

		// set the SortedCallsView as the main view
		[self addSubview: _transitionView];
		[self setView:_currentButtonBarView];

		
		// create the buttonbar and add it at the lat 49pix of the screen
		rect.origin.y = rect.size.height;
		rect.size.height = 49.0f; 
		_buttonBar = [self allocButtonBarWithFrame:rect];
		[self addSubview: _buttonBar];
    }
    
    return(self);
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


