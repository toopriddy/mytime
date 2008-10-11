//
//  NumberViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/11/08.
//  Copyright 2008 PG Software. All rights reserved.
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
