//
//  NotAtHomeHouseCell.m
//
//  Created by Brent Priddy on 1/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NotAtHomeHouseCell.h"

@implementation NotAtHomeHouseCell
@synthesize houseLabel;
@synthesize countLabel;
@synthesize delegate;

- (void)dealloc
{
	self.houseLabel = nil;
	self.countLabel = nil;
	
	[super dealloc];
}


- (IBAction)addPressed
{
	self.attempts = attempts + 1;
	if(self.delegate && [self.delegate respondsToSelector:@selector(notAtHomeHouseCellAttemptsChanged:)])
	{
		[self.delegate notAtHomeHouseCellAttemptsChanged:self];
	}
}

- (IBAction)subtractPressed
{
	if(attempts > 1)
	{
		self.attempts = attempts - 1;
		if(self.delegate && [self.delegate respondsToSelector:@selector(notAtHomeHouseCellAttemptsChanged:)])
		{
			[self.delegate notAtHomeHouseCellAttemptsChanged:self];
		}
	}
}

- (int)attempts
{
	return attempts;
}

- (void)setAttempts:(int)value
{
	attempts = value;
	countLabel.text = [NSString stringWithFormat:@"%u", attempts];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
	UIColor *backgroundColor = selected || animated ? [UIColor clearColor] : [UIColor whiteColor];
	
	[super setSelected:selected animated:animated];
	
	if(self.selectionStyle != UITableViewCellSelectionStyleNone)
	{
		houseLabel.backgroundColor = backgroundColor;
		houseLabel.highlighted = selected;
		houseLabel.opaque = !selected;
		
		countLabel.backgroundColor = backgroundColor;
		countLabel.highlighted = selected;
		countLabel.opaque = !selected;
	}
}


@end
