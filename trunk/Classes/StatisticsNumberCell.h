//
//  StatisticsNumberCell.h
//  MyTime
//
//  Created by Brent Priddy on 4/12/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
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
	UILabel *nameLabel;
	UIButton *subtractButton;
	UIButton *addButton;
	NSObject<StatisticsNumberCellDelegate> *delegate;
	int statistic;
}
@property (nonatomic, retain) IBOutlet UILabel *countLabel;
@property (nonatomic, retain) IBOutlet UILabel *editingCountLabel;
@property (nonatomic, retain) IBOutlet UIButton *subtractButton;
@property (nonatomic, retain) IBOutlet UIButton *addButton;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, assign) NSObject<StatisticsNumberCellDelegate> *delegate;
@property (nonatomic, assign) int statistic;

- (IBAction)addPressed;
- (IBAction)subtractPressed;

@end
