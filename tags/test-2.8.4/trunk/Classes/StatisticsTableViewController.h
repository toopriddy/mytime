//
//  StatisticsTableViewController.h
//  MyTime
//
//  Created by Brent Priddy on 4/9/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <Foundation/Foundation.h>
#import "GenericTableViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "MonthChooserViewController.h"

#define kMonthsShown 12

@interface StatisticsTableViewController : GenericTableViewController <MonthChooserViewControllerDelegate,
                                                                       UIActionSheetDelegate,
                                                                       MFMailComposeViewControllerDelegate> 
{
	int _serviceYearBooks;
	int _serviceYearBrochures;
	int _serviceYearMinutes;
	int _serviceYearQuickBuildMinutes;
	int _serviceYearMagazines;
	int _serviceYearReturnVisits;
	int _serviceYearBibleStudies;
	int _serviceYearStudyIndividuals;
	int _serviceYearCampaignTracts;
	
	NSMutableArray *_serviceYearStudyIndividualCalls;
	
	int _thisMonth;
	int _lastMonth;
	int _thisYear;
	
	int _books[kMonthsShown];
	int _brochures[kMonthsShown];
	int _minutes[kMonthsShown];
	int _quickBuildMinutes[kMonthsShown];
	int _magazines[kMonthsShown];
	int _returnVisits[kMonthsShown];
	int _bibleStudies[kMonthsShown];
	int _campaignTracts[kMonthsShown];

	NSMutableArray *_individualCalls[kMonthsShown];

	int _selectedMonth;
	BOOL _emailActionSheet;
	NSString *_serviceYearText;
	
}

@end
