//
//  DatePickerViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/15/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickerViewControllerDelegate.h"
#import "NumberedPickerView.h"

@interface  DatePickerViewController : UIViewController 
{
    UIDatePicker *datePicker;
	UIView *containerView;
	
	id<DatePickerViewControllerDelegate> delegate;
}

@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, assign) id<DatePickerViewControllerDelegate> delegate;


- (id) init;
// initialize this view given the curent configuration
- (id) initWithDate: (NSDate *)date;

- (NSDate *)date;
@end