//
//  TimePickerViewControllerDelegate.h
//  MyTime
//
//  Created by Brent Priddy on 8/11/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

@class TimePickerViewController;

@protocol TimePickerViewControllerDelegate<NSObject>

@required

- (void)timePickerViewControllerDone:(TimePickerViewController *)timePickerViewController;

@end
