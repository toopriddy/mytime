//
//  StatisticsNumberCell.m
//  MyTime
//
//  Created by Brent Priddy on 4/12/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "StatisticsNumberCell.h"


@implementation StatisticsNumberCell
@synthesize nameLabel;
@synthesize countLabel;
@synthesize editingCountLabel;
@synthesize subtractButton;
@synthesize addButton;
@synthesize delegate;

- (void)dealloc
{
	self.nameLabel = nil;
	self.countLabel = nil;
	self.editingCountLabel = nil;
	self.subtractButton = nil;
	self.addButton = nil;
	
	[super dealloc];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	if(animated)
	{
		[UIView beginAnimations:nil context:nil];
	}
	
	self.editingCountLabel.hidden = !editing;
	self.addButton.hidden = !editing;
	self.subtractButton.hidden = !editing;
	self.countLabel.hidden = editing;
	
	if(animated)
	{
		[UIView commitAnimations];
	}
}

- (IBAction)addPressed
{
	self.statistic = statistic + 1;
	if(self.delegate && [self.delegate respondsToSelector:@selector(statisticsNumberCellValueChanged:)])
	{
		[self.delegate statisticsNumberCellValueChanged:self];
	}
}

- (IBAction)subtractPressed
{
	if(statistic >= 1)
	{
		self.statistic = statistic - 1;
		if(self.delegate && [self.delegate respondsToSelector:@selector(statisticsNumberCellValueChanged:)])
		{
			[self.delegate statisticsNumberCellValueChanged:self];
		}
	}
}

- (int)statistic
{
	return statistic;
}

- (void)setStatistic:(int)value
{
	statistic = value;
	countLabel.text = [NSString stringWithFormat:@"%u", statistic];
	editingCountLabel.text = countLabel.text;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
	UIColor *backgroundColor = selected || animated ? [UIColor clearColor] : [UIColor whiteColor];
	
	[super setSelected:selected animated:animated];
	
	if(self.selectionStyle != UITableViewCellSelectionStyleNone)
	{
		nameLabel.backgroundColor = backgroundColor;
		nameLabel.highlighted = selected;
		nameLabel.opaque = !selected;
		
		countLabel.backgroundColor = backgroundColor;
		countLabel.highlighted = selected;
		countLabel.opaque = !selected;
		
		editingCountLabel.backgroundColor = backgroundColor;
		editingCountLabel.highlighted = selected;
		editingCountLabel.opaque = !selected;
	}
}


@end
