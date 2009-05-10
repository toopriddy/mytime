//
//  MonthChooserViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/22/08.
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
#import "UITableViewTextFieldCell.h"
#import "NotesViewControllerDelegate.h"

@class MonthChooserViewController;

@protocol MonthChooserViewControllerDelegate<NSObject>
@required
- (void)monthChooserViewControllerSendEmail:(MonthChooserViewController *)monthChooserViewController;
@end

@interface MonthChooserViewController : UIViewController <UITableViewDelegate, 
													      UITableViewDataSource,
														  UITableViewTextFieldCellDelegate,
														  NotesViewControllerDelegate> 
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
@property (nonatomic,retain) NSArray *months;
@property (nonatomic,retain) NSArray *selected;


/**
 * initialize this view with the address information
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithMonths:(NSArray *)months;

@end




