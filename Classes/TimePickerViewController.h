//
//  TimePickerViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/11/08.
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