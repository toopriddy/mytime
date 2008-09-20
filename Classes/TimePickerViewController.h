//
//  TimePickerViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/11/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimePickerViewControllerDelegate.h"
#import "NumberedPickerView.h"

@interface  TimePickerViewController : UIViewController 
{
    UIDatePicker *datePicker;
    UIDatePicker *timePicker;
	UIView *containerView;
	
	id<TimePickerViewControllerDelegate> delegate;
}

@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) UIDatePicker *timePicker;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, assign) id<TimePickerViewControllerDelegate> delegate;


- (id) init;
// initialize this view given the curent configuration
- (id) initWithDate: (NSDate *)date minutes:(int)minutes;

- (NSDate *)date;
- (int)minutes;
@end