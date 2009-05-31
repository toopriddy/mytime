//
//  CallTableCell.m
//  MyTime
//
//  Created by Brent Priddy on 7/6/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "CallTableCell.h"
#import "Settings.h"
#import "PSLocalization.h"


@implementation CallTableCell

@synthesize call;
@synthesize mainLabel;
@synthesize secondaryLabel;
@synthesize infoLabel;

#define LEFT_OFFSET 10
	
#define STREET_TOP_OFFSET 2
#define STREET_HEIGHT 22
#define NAME_TOP_OFFSET (STREET_TOP_OFFSET + STREET_HEIGHT + 2)
#define NAME_HEIGHT 14
#define INFO_TOP_OFFSET (NAME_TOP_OFFSET + NAME_HEIGHT + 1)
#define INFO_HEIGHT 28

#define TOTAL_HEIGHT (INFO_TOP_OFFSET + INFO_HEIGHT + STREET_TOP_OFFSET)

+ (float)height
{
	return(TOTAL_HEIGHT);
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier 
{
	if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) 
	{
		_nameAsMainLabel = false;
		
		self.mainLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		mainLabel.backgroundColor = [UIColor clearColor];
		mainLabel.font = [UIFont boldSystemFontOfSize:18];
		mainLabel.textColor = [UIColor blackColor];
		mainLabel.highlightedTextColor = [UIColor whiteColor];
		[self.contentView addSubview: mainLabel];

		self.secondaryLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		secondaryLabel.backgroundColor = [UIColor clearColor];
		secondaryLabel.font = [UIFont boldSystemFontOfSize:12];
		secondaryLabel.textColor = [UIColor darkGrayColor];
		secondaryLabel.highlightedTextColor = [UIColor whiteColor];
		[self.contentView addSubview: secondaryLabel];

		self.infoLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		infoLabel.backgroundColor = [UIColor clearColor];
		infoLabel.font = [UIFont boldSystemFontOfSize:10];
		infoLabel.textColor = [UIColor lightGrayColor];
		infoLabel.highlightedTextColor = [UIColor whiteColor];
		infoLabel.lineBreakMode = UILineBreakModeWordWrap;
		infoLabel.numberOfLines = 0;
		[self.contentView addSubview:infoLabel];
	}
	return self;
}

- (void)dealloc
{
	DEBUG(NSLog(@"%s: dealloc", __FILE__);)
	self.mainLabel = nil;
	self.secondaryLabel = nil;
	self.infoLabel = nil;
	[super dealloc];
}

- (void)useNameAsMainLabel
{
	_nameAsMainLabel = true;
}

- (void)useStreetAsMainLabel
{
	_nameAsMainLabel = false;
}

- (void)setCall:(NSMutableDictionary *)theCall
{
	call = theCall;
	
	NSMutableString *top = [[[NSMutableString alloc] init] autorelease];
	NSString *houseNumber = [call objectForKey:CallStreetNumber ];
	NSString *apartmentNumber = [call objectForKey:CallApartmentNumber ];
	NSString *street = [call objectForKey:CallStreet];

	[Settings formatStreetNumber:houseNumber apartment:apartmentNumber street:street city:nil state:nil topLine:top bottomLine:nil];

	if([top length] == 0)
		[top setString:NSLocalizedString(@"(unknown street)", @"(unknown street) Placeholder Section title in the Sorted By Calls view")];

	NSString *info = @"";
	if([[call objectForKey:CallReturnVisits] count] > 0)
	{
		NSMutableDictionary *returnVisit = [[call objectForKey:CallReturnVisits] objectAtIndex:0];
		info = [returnVisit objectForKey:CallReturnVisitNotes];
	}
	if(_nameAsMainLabel)
	{
		mainLabel.text = [call objectForKey:CallName];
		secondaryLabel.text = top;
	}
	else
	{
		mainLabel.text = top;
		secondaryLabel.text = [call objectForKey:CallName];
	}
	infoLabel.text = info;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated 
{
	/*
	 Views are drawn most efficiently when they are opaque and do not have a clear background, so in newLabelForMainText: the labels are made opaque and given a white background.  To show selection properly, however, the views need to be transparent (so that the selection color shows through).  
    */
	[super setSelected:selected animated:animated];

	UIColor *backgroundColor = selected || animated ? [UIColor clearColor] : [UIColor whiteColor];

	mainLabel.backgroundColor = backgroundColor;
	mainLabel.highlighted = selected;
	mainLabel.opaque = !selected;

	secondaryLabel.backgroundColor = backgroundColor;
	secondaryLabel.highlighted = selected;
	secondaryLabel.opaque = !selected;

	infoLabel.backgroundColor = backgroundColor;
	infoLabel.highlighted = selected;
	infoLabel.opaque = !selected;
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    CGRect contentRect = [self.contentView bounds];
	
	float boundsX = contentRect.origin.x;
	float width = contentRect.size.width;
	CGRect frame;

	frame = CGRectMake(boundsX + LEFT_OFFSET, STREET_TOP_OFFSET, width, STREET_HEIGHT);
	[mainLabel setFrame:frame];

	frame = CGRectMake(boundsX + LEFT_OFFSET, NAME_TOP_OFFSET, width, NAME_HEIGHT);
	[secondaryLabel setFrame:frame];

	frame = CGRectMake(boundsX + LEFT_OFFSET, INFO_TOP_OFFSET, width, INFO_HEIGHT);
	[infoLabel setFrame:frame];
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
