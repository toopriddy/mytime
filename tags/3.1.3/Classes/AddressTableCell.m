//
//  AddressTableCell.m
//  MyTime
//
//  Created by Brent Priddy on 10/6/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "AddressTableCell.h"
#import "PSLocalization.h"


@implementation AddressTableCell

@synthesize topLabel;
@synthesize bottomLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) 
	{
		self.textLabel.text = NSLocalizedString(@"Address", @"Address label for call");

		UIView *view = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		[self.contentView addSubview:view];
		
		self.topLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		topLabel.highlightedTextColor = self.textLabel.highlightedTextColor;
		topLabel.backgroundColor = [UIColor clearColor];
		[view addSubview:topLabel];
		[topLabel setText:@""];

		self.bottomLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		bottomLabel.highlightedTextColor = self.textLabel.highlightedTextColor;
		bottomLabel.backgroundColor = [UIColor clearColor];
		[bottomLabel setText:@""];
		[view addSubview:bottomLabel];
	
		[self.contentView addSubview:bottomLabel];
	}
	return self;
}

- (void)dealloc
{
	self.topLabel = nil;
	self.bottomLabel = nil;

	[super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
	[super setSelected:selected animated:animated];

	UIColor *backgroundColor = selected || animated ? [UIColor clearColor] : [UIColor whiteColor];

	topLabel.backgroundColor = backgroundColor;
	topLabel.highlighted = selected;
	topLabel.opaque = !selected;

	bottomLabel.backgroundColor = backgroundColor;
	bottomLabel.highlighted = selected;
	bottomLabel.opaque = !selected;
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    CGRect contentRect = [self.contentView bounds];
	
	self.accessoryType = [self isEditing] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;

	[topLabel sizeToFit];
	CGRect lrect = [topLabel bounds];
	lrect.origin.x += 100.0f;
	lrect.origin.y += 15.0f;
	lrect.size.width = contentRect.size.width - lrect.origin.x;
	[topLabel setFrame: lrect];

	[bottomLabel sizeToFit];
	lrect = [bottomLabel bounds];
	lrect.origin.x += 100.0f;
	lrect.origin.y += 35.0f;
	lrect.size.width = contentRect.size.width - lrect.origin.x;
	[bottomLabel setFrame: lrect];
}

@end

