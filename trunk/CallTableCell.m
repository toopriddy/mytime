//
//  CallTableCell.m
//  MyTime
//
//  Created by Brent Priddy on 7/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CallTableCell.h"
#import "App.h"
#import <WebCore/WebFontCache.h>


@implementation CallTableCell
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

- (CallTableCell *)initWithCall:(NSMutableDictionary *)call
{
	if( (self = [super initWithFrame:CGRectZero]) )
	{
		NSString *title = [[[NSString alloc] init] autorelease];
		NSString *houseNumber = [call objectForKey:CallStreetNumber ];
		NSString *street = [call objectForKey:CallStreet];

		if(houseNumber && [houseNumber length] && street && [street length])
			title = [title stringByAppendingFormat:NSLocalizedString(@"%@ %@", @"House number and Street represented by %1$@ as the house number and %2$@ as the street name"), houseNumber, street];
		else if(houseNumber && [houseNumber length])
			title = [title stringByAppendingString:houseNumber];
		else if(street && [street length])
			title = [title stringByAppendingString:street];
		if([title length] == 0)
			title = NSLocalizedString(@"(unknown street)", @"(unknown street) Placeholder Section title in the Sorted By Calls view");

		float darkGreyColor[] = { 0.0/3.3, 1.0};
		float lightGreyColor[] = { 2.0/3.3, 1.0};
		float whiteColor[] = { 1.0, 1.0};
		float clearColor[] = { 0,0,0,0 };
		CGColorRef streetColor = CGColorCreate(CGColorSpaceCreateDeviceGray(), darkGreyColor);
		CGColorRef nameColor = CGColorCreate(CGColorSpaceCreateDeviceGray(), darkGreyColor);
		CGColorRef infoColor = CGColorCreate(CGColorSpaceCreateDeviceGray(), lightGreyColor);
		CGColorRef highlightColor = CGColorCreate(CGColorSpaceCreateDeviceGray(),whiteColor);
		CGColorRef bgColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), clearColor);
		
		streetLabel = [[[UITextLabel alloc] initWithFrame:CGRectZero] autorelease];
		[streetLabel setBackgroundColor:bgColor];
		[streetLabel setHighlightedColor:highlightColor];
		[streetLabel setColor:streetColor];
		[streetLabel setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:18]];
		[streetLabel setText:title];
		[self addSubview: streetLabel];

		nameLabel = [[[UITextLabel alloc] initWithFrame:CGRectZero] autorelease];
		[nameLabel setBackgroundColor:bgColor];
		[nameLabel setHighlightedColor:highlightColor];
		[nameLabel setColor:nameColor];
		[nameLabel setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:12]];
		[nameLabel setText:[call objectForKey:CallName]];
		[self addSubview: nameLabel];

		NSString *info = @"";
		infoLabel = [[[UITextLabel alloc] initWithFrame:CGRectZero] autorelease];
		[infoLabel setBackgroundColor:bgColor];
		[infoLabel setHighlightedColor:highlightColor];
		[infoLabel setColor:infoColor];
		[infoLabel setWrapsText:YES];
		if([[call objectForKey:CallReturnVisits] count] > 0)
		{
			NSMutableDictionary *returnVisit = [[call objectForKey:CallReturnVisits] objectAtIndex:0];
			info = [returnVisit objectForKey:CallReturnVisitNotes];
		}
		[infoLabel setFont:[NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:10]];
		[infoLabel setText:info];
		[self addSubview: infoLabel];
	}
	return self;
}


- (void)setSelected:(BOOL)selected withFade:(BOOL)animated {
	/*
	 Views are drawn most efficiently when they are opaque and do not have a clear background, so in newLabelForMainText: the labels are made opaque and given a white background.  To show selection properly, however, the views need to be transparent (so that the selection color shows through).  
    */
	[super setSelected:selected withFade:animated];
	
	[streetLabel setHighlighted:selected];
	[nameLabel setHighlighted:selected];
	[infoLabel setHighlighted:selected];
	
}

- (void)layoutSubviews 
{

    [super layoutSubviews];
    CGRect contentRect = [self bounds];
	
	float boundsX = contentRect.origin.x;
	float width = contentRect.size.width;
	CGRect frame;

	frame = CGRectMake(boundsX + LEFT_OFFSET, STREET_TOP_OFFSET, width, STREET_HEIGHT);
	[streetLabel setFrame:frame];

	frame = CGRectMake(boundsX + LEFT_OFFSET, NAME_TOP_OFFSET, width, NAME_HEIGHT);
	[nameLabel setFrame:frame];

	frame = CGRectMake(boundsX + LEFT_OFFSET, INFO_TOP_OFFSET, width, INFO_HEIGHT);
	[infoLabel setFrame:frame];
}


@end
