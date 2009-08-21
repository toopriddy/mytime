//
//  StatisticsViewController.h
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <UIKit/UIKit.h>
#import "MonthChooserViewController.h"

#define kMonthsShown 12

@interface StatisticsViewController : UIViewController <UITableViewDelegate, 
                                                        UITableViewDataSource,
														MonthChooserViewControllerDelegate,
														UIActionSheetDelegate> 
{
	UITableView *theTableView;

	int _serviceYearBooks;
	int _serviceYearBrochures;
	int _serviceYearMinutes;
	int _serviceYearQuickBuildMinutes;
	int _serviceYearMagazines;
	int _serviceYearReturnVisits;
	int _serviceYearBibleStudies;
	int _serviceYearCampaignTracts;

	int _thisMonth;
	int _lastMonth;
	int _thisYear;
	int _lastYear;
	
	int _books[kMonthsShown];
	int _brochures[kMonthsShown];
	int _minutes[kMonthsShown];
	int _quickBuildMinutes[kMonthsShown];
	int _magazines[kMonthsShown];
	int _returnVisits[kMonthsShown];
	int _bibleStudies[kMonthsShown];
	int _campaignTracts[kMonthsShown];
	
	int _selectedMonth;
	BOOL _emailActionSheet;
	NSString *_serviceYearText;
}
@property (nonatomic,retain) UITableView *theTableView;

/**
 * initialize this view with a watchtower at the current month/year
 *
 * @param rect - the rect
 * @returns self
 */
- (id)init;
- (void)dealloc;
- (void)reloadData;
@end
