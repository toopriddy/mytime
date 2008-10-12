//
//  StatisticsViewController.h
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMonthsShown 12

@interface StatisticsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> 
{
	UITableView *theTableView;

	int _serviceYearMinutes;
	
	int _thisMonth;
	int _lastMonth;
	int _thisYear;
	int _lastYear;
	
	int _books[kMonthsShown];
	int _brochures[kMonthsShown];
	int _minutes[kMonthsShown];
	int _magazines[kMonthsShown];
	int _returnVisits[kMonthsShown];
	int _bibleStudies[kMonthsShown];
	int _specialPublications[kMonthsShown];

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
