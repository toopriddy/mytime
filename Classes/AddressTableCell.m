//
//  AddressTableCell.m
//  MyTime
//
//  Created by Brent Priddy on 10/6/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "AddressTableCell.h"
#import "Settings.h"


@implementation AddressTableCell

@synthesize topLabel;
@synthesize bottomLabel;


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier 
{
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) 
	{
		[self setText:NSLocalizedString(@"Address", @"Address label for call") ];

		UIView *view = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		[self.contentView addSubview:view];
		
		self.topLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		topLabel.highlightedTextColor = self.selectedTextColor;
		topLabel.backgroundColor = [UIColor clearColor];
		[view addSubview:topLabel];
		[topLabel setText:@""];

		self.bottomLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		bottomLabel.highlightedTextColor = self.selectedTextColor;
		bottomLabel.backgroundColor = [UIColor clearColor];
		[bottomLabel setText:@""];
		[view addSubview:bottomLabel];
	
		[self.contentView addSubview:bottomLabel];
	}
	return self;
}

- (void)dealloc
{
	DEBUG(NSLog(@"%s: dealloc", __FILE__);)
	self.topLabel = nil;
	self.bottomLabel = nil;

	[super dealloc];
}

- (void)setStreetNumber:(NSString *)streetNumber street:(NSString *)street city:(NSString *)city state:(NSString *)state;
{
	NSMutableString *top = [[[NSMutableString alloc] init] autorelease];
	[top setString:@""];
	NSMutableString *bottom = [[[NSMutableString alloc] init] autorelease];
	[bottom setString:@""];

	if(streetNumber && [streetNumber length] && street && [street length])
	{
		[top appendFormat:NSLocalizedString(@"%@ %@", @"House number and Street represented by %1$@ as the house number and %2$@ as the street name"), streetNumber, street];
	}
	else if(streetNumber && [streetNumber length])
	{
		[top appendFormat:@"%@", streetNumber];
	}
	else if(street && [street length])
	{
		[top appendFormat:@"%@", street];
	}
	if(city != nil && [city length])
	{
		[bottom appendFormat:@"%@", city];
	}
	if(state != nil && [state length])
	{
		[bottom appendFormat:@", %@", state];
	}
	topLabel.text = top;
	bottomLabel.text = bottom;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
	/*
	 Views are drawn most efficiently when they are opaque and do not have a clear background, so in newLabelForMainText: the labels are made opaque and given a white background.  To show selection properly, however, the views need to be transparent (so that the selection color shows through).  
    */
	[super setSelected:selected animated:animated];

	[topLabel setHighlighted:selected];
	[bottomLabel setHighlighted:selected];
}

- (void)layoutSubviews 
{
    [super layoutSubviews];

	self.accessoryType = [self isEditing] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;

	[topLabel sizeToFit];
	CGRect lrect = [topLabel bounds];
	lrect.origin.x += 100.0f;
	lrect.origin.y += 15.0f;
	[topLabel setFrame: lrect];

	[bottomLabel sizeToFit];
	lrect = [bottomLabel bounds];
	lrect.origin.x += 100.0f;
	lrect.origin.y += 35.0f;
	[bottomLabel setFrame: lrect];
}


- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s respondsToSelector: %s", __FILE__, selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s methodSignatureForSelector: %s", __FILE__, selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"%s forwardInvocation: %s", __FILE__, [invocation selector]);)
    [super forwardInvocation:invocation];
}



@end

