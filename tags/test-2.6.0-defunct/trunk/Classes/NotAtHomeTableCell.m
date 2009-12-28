//
//  NotAtHomeTableCell.m
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NotAtHomeTableCell.h"

@implementation NotAtHomeTableCell
@synthesize delegate;
@synthesize attempts;
@synthesize houseNumber;

- (IBAction)valueChanged
{
	if(self.delegate && [self.delegate respondsToSelector:@selector(notAtHomeTableCellAttemptsChanged:)])
	{
		[self.delegate notAtHomeTableCellAttemptsChanged:self];
	}
}

- (void)dealloc
{
	self.houseNumber = nil;
	self.attempts = nil;
	
	[super dealloc];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self bringSubviewToFront:self.houseNumber];	
	[self bringSubviewToFront:self.attempts];	
}

@end
