//
//  DatePickerViewControllerDelegate.h
//  MyTime
//
//  Created by Brent Priddy on 8/15/08.
//  Copyright 2008 PG Software. All rights reserved.
//


@class DatePickerViewController;

@protocol DatePickerViewControllerDelegate<NSObject>

@required

- (void)datePickerViewControllerDone:(DatePickerViewController *)datePickerViewController;

@end

