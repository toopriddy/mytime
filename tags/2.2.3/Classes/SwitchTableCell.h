//
//  SwitchTableCell.h
//  MyTime
//
//  Created by Brent Priddy on 10/11/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwitchTableCell;

@protocol SwitchTableCellDelegate <NSObject>
- (void)switchTableCellChanged:(SwitchTableCell *)switchTableCell;
@end

@interface SwitchTableCell : UITableViewCell 
{
	UISwitch *uiSwitch;
	id<SwitchTableCellDelegate> delegate;
}
@property (nonatomic, retain) UISwitch *uiSwitch;
@property (nonatomic, assign) id<SwitchTableCellDelegate> delegate;
@end
