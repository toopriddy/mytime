//
//  DatePickerViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/15/08.
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
#import "DatePickerViewControllerDelegate.h"
#import "NumberedPickerView.h"

@interface  DatePickerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UIDatePicker *datePicker;
	UIView *containerView;
	int tag;
	id<DatePickerViewControllerDelegate> delegate;
	UITableView *tableView;
	BOOL first;
}

@property (nonatomic, assign) int tag;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, assign) id<DatePickerViewControllerDelegate> delegate;
@property (nonatomic, assign) UIDatePickerMode datePickerMode;

- (id) init;
// initialize this view given the curent configuration
- (id) initWithDate: (NSDate *)date;

- (NSDate *)date;
@end