//
//  StatisticsViewController.h
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatisticsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> 
{
	UITableView *theTableView;
	
	int _thisMonth;
	int _lastMonth;
	int _thisYear;
	int _lastYear;
	
	int _thisMonthBooks;
	int _thisMonthBrochures;
	int _thisMonthMinutes;
	int _thisMonthMagazines;
	int _thisMonthReturnVisits;
	int _thisMonthBibleStudies;
	int _thisMonthSpecialPublications;
	
	int _lastMonthBooks;
	int _lastMonthBrochures;
	int _lastMonthMinutes;
	int _lastMonthMagazines;
	int _lastMonthReturnVisits;
	int _lastMonthBibleStudies;
	int _lastMonthSpecialPublications;

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
