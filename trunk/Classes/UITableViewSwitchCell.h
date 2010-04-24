//
//  UITableViewSwitchCell.h
//  MyTime
//
//  Created by Brent Priddy on 7/6/09.
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
#import <Foundation/Foundation.h>

@class UITableViewSwitchCell;

@protocol UITableViewSwitchCellDelegate<NSObject>
@required
- (void)uiTableViewSwitchCellChanged:(UITableViewSwitchCell *)uiTableViewSwitchCell;
@end


@interface UITableViewSwitchCell : UITableViewCell 
{
    UISwitch *booleanSwitch;
	UILabel *otherTextLabel;
	NSObject<UITableViewSwitchCellDelegate> *_delegate;
	BOOL observeEditing;
}

@property (nonatomic, assign) NSObject<UITableViewSwitchCellDelegate> *delegate;
@property (nonatomic, retain) IBOutlet UISwitch *booleanSwitch;
@property (nonatomic, retain) IBOutlet UILabel *otherTextLabel;
@property (nonatomic, assign) BOOL observeEditing;

- (IBAction)switchChanged;

@end
