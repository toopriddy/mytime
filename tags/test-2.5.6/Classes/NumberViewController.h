//
//  NumberViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/11/08.
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
#import "NumberViewControllerDelegate.h"
#import "NumberedPickerView.h"

@interface  NumberViewController : UIViewController 
{
	NumberedPickerView *numberPicker;
	UIView *containerView;
	
	BOOL showCount;
	
	id<NumberViewControllerDelegate> delegate;
}

@property (nonatomic, retain) NumberedPickerView *numberPicker;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, assign) id<NumberViewControllerDelegate> delegate;

/**
 * initialize this view 
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithTitle:(NSString *)title singularLabel:(NSString *)singularLabel label:(NSString *)label number:(int)number min:(int)min max:(int)max;

- (void)navigationControlDone:(id)sender;

@end
