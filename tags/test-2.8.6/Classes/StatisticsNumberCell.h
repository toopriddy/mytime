//
//  StatisticsNumberCell.h
//  MyTime
//
//  Created by Brent Priddy on 4/12/10.
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

@class StatisticsNumberCell;

@protocol StatisticsNumberCellDelegate
- (void)statisticsNumberCellValueChanged:(StatisticsNumberCell *)cell;
@end

@interface StatisticsNumberCell : UITableViewCell 
{
	UILabel *countLabel;
	UILabel *editingCountLabel;
	UILabel *realCountLabel;
	UILabel *nameLabel;
	UIButton *subtractButton;
	UIButton *addButton;
	NSObject<StatisticsNumberCellDelegate> *delegate;
	int statistic;
}
@property (nonatomic, retain) IBOutlet UILabel *countLabel;
@property (nonatomic, retain) IBOutlet UILabel *editingCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *realCountLabel;
@property (nonatomic, retain) IBOutlet UIButton *subtractButton;
@property (nonatomic, retain) IBOutlet UIButton *addButton;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) NSObject<StatisticsNumberCellDelegate> *delegate;
@property (nonatomic, assign) int statistic;

- (IBAction)addPressed;
- (IBAction)subtractPressed;

@end
