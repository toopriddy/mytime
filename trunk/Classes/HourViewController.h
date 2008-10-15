//
//  HourViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/11/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimePickerViewControllerDelegate.h"

@interface HourViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, TimePickerViewControllerDelegate> 
{
	UITableView *tableView;
	NSMutableArray *timeEntries;
	BOOL _quickBuild;
	
	NSIndexPath *selectedIndexPath;
}
@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) NSMutableArray *timeEntries;
@property (nonatomic,retain) NSIndexPath *selectedIndexPath;

/**
 * initialize this view with a watchtower at the current month/year
 *
 * @param rect - the rect
 * @returns self
 */
- (id)initForQuickBuild:(BOOL)quickBuild;
- (void)dealloc;
- (void)reloadData;
@end
