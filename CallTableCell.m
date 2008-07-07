//
//  CallTableCell.m
//  MyTime
//
//  Created by Brent Priddy on 7/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CallTableCell.h"


@implementation CallTableCell

- (CallTableCell *)initWithCall:(NSMutableDictionary *)call
{
	id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
	NSString *title = [[[NSString alloc] init] autorelease];
	NSString *houseNumber = [[_calls objectAtIndex:row] objectForKey:CallStreetNumber ];
	NSString *street = [[_calls objectAtIndex:row] objectForKey:CallStreet];

	if(houseNumber && [houseNumber length] && street && [street length])
		title = [title stringByAppendingFormat:NSLocalizedString(@"%@ %@", @"House number and Street represented by %1$@ as the house number and %2$@ as the street name"), houseNumber, street];
	else if(houseNumber && [houseNumber length])
		title = [title stringByAppendingString:houseNumber];
	else if(street && [street length])
		title = [title stringByAppendingString:street];
	if([title length] == 0)
		title = NSLocalizedString(@"(unknown street)", @"(unknown street) Placeholder Section title in the Sorted By Calls view");

	[cell setTitle: title];

	CGSize s = CGSizeMake( [column width], [table rowHeight] );
	UITextLabel* label = [[[UITextLabel alloc] initWithFrame: CGRectMake(200,0,s.width,s.height)] autorelease];
	float bgColor[] = { 0,0,0,0 };
	[label setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	[label setText:[[_calls objectAtIndex:row] objectForKey:CallName]];
	[cell addSubview: label];

	return cell;
}

- (void)layoutSubviews 
{

#define LEFT_COLUMN_OFFSET 10
#define LEFT_COLUMN_WIDTH 130
	
#define MIDDLE_COLUMN_OFFSET 140
#define MIDDLE_COLUMN_WIDTH 110
	
#define RIGHT_COLUMN_OFFSET 270
	
#define UPPER_ROW_TOP 8
#define LOWER_ROW_TOP 32

    [super layoutSubviews];
    CGRect contentRect = [[self contentView] bounds];
	
	// In this example we will never be editing, but this illustrates the appropriate pattern
    if (!self.editing) 
	{
		
		CGFloat boundsX = contentRect.origin.x;
		CGRect frame;

		frame = CGRectMake(boundsX + LEFT_COLUMN_OFFSET, UPPER_ROW_TOP, LEFT_COLUMN_WIDTH, 20);
		timeZoneNameLabel.frame = frame;

		frame = CGRectMake(boundsX + LEFT_COLUMN_OFFSET, LOWER_ROW_TOP, LEFT_COLUMN_WIDTH, 14);
		abbreviationLabel.frame = frame;

		frame = CGRectMake(boundsX + MIDDLE_COLUMN_OFFSET, UPPER_ROW_TOP, MIDDLE_COLUMN_WIDTH, 20);
		timeLabel.frame = frame;
		
		frame = CGRectMake(boundsX + MIDDLE_COLUMN_OFFSET, LOWER_ROW_TOP, MIDDLE_COLUMN_WIDTH, 14);
		dayLabel.frame = frame;
		
		frame = [imageView frame];
		frame.origin.x = boundsX + RIGHT_COLUMN_OFFSET;
		frame.origin.y = UPPER_ROW_TOP;
 		imageView.frame = frame;
   }
}


@end
