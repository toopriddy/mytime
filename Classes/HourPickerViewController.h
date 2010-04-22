//
//  HourPickerViewController.h
//  MyTime
//
//  Created by Brent Priddy on 4/19/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <UIKit/UIKit.h>
#import "HourPickerView.h"

@class HourPickerViewController;

@protocol HourPickerViewControllerDelegate<NSObject>

@required

- (void)hourPickerViewControllerDone:(HourPickerViewController *)hourPickerViewController;

@end



@interface  HourPickerViewController : UIViewController
{
	HourPickerView *datePicker;
	UIView *containerView;
	int tag;
	id<HourPickerViewControllerDelegate> delegate;
	BOOL first;
	int minutes;
}

@property (nonatomic, assign) int tag;
@property (nonatomic, retain) HourPickerView *datePicker;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, assign) id<HourPickerViewControllerDelegate> delegate;


- (id)initWithTitle:(NSString *)title;
// initialize this view given the curent configuration
- (id)initWithTitle:(NSString *)title minutes:(int)minutes;

- (int)minutes;
@end