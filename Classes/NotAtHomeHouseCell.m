//
//  NotAtHomeHouseCell.m
//
//  Created by Brent Priddy on 1/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
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
