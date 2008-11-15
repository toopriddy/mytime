//
//  MonthChooserViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/22/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewTextFieldCell.h"

@class MonthChooserViewController;

@protocol MonthChooserViewControllerDelegate<NSObject>
@required
- (void)monthChooserViewControllerSendEmail:(MonthChooserViewController *)monthChooserViewController;
@end

@interface MonthChooserViewController : UIViewController <UITableViewDelegate, 
													      UITableViewDataSource> 
{
	id<MonthChooserViewControllerDelegate> delegate;
@private
	UITableView *theTableView;
	NSArray *_months;
	NSMutableArray *_selected;
	UITableViewTextFieldCell *_emailAddress;
	int _countSelected;
}

@property (nonatomic, assign) id<MonthChooserViewControllerDelegate> delegate;
@property (nonatomic, retain) UITableViewTextFieldCell *emailAddress;


/**
 * initialize this view with the address information
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithMonths:(NSArray *)months;

@end




