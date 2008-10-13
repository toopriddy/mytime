//
//  SwitchTableCell.m
//  MyTime
//
//  Created by Brent Priddy on 10/11/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "SwitchTableCell.h"


@implementation SwitchTableCell
@synthesize uiSwitch;
@synthesize delegate;

- (void)valueChanged:(id)sender
{
	if(delegate)
		[delegate switchTableCellChanged:self];
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier 
{
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) 
	{
        // Initialization code
		self.uiSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
		[uiSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
		self.delegate = nil;
		
		[self.contentView addSubview:uiSwitch];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{

    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    CGRect contentRect = [self.contentView bounds];
	
	if(contentRect.origin.x == 0.0) 
	{
		contentRect.origin.x = 10.0;
		contentRect.size.width -= 20;
	}
	
	float width = contentRect.size.width;
	float height = contentRect.size.height;
	CGRect frame;
	CGRect switchBounds = [uiSwitch bounds];
	frame = CGRectMake(contentRect.origin.x + width - switchBounds.size.width, (height - switchBounds.size.height)/2, switchBounds.size.width, switchBounds.size.height);
	[uiSwitch setFrame:frame];
}


- (void)dealloc 
{
	self.uiSwitch = nil;
    [super dealloc];
}


@end
