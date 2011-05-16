//
//  PSDateCellController.m
//  MyTime
//
//  Created by Brent Priddy on 12/29/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "PSDateCellController.h"


@implementation PSDateCellController
@synthesize dateFormat;
@synthesize datePickerMode;
@synthesize modelValueIsString;

- (id)init
{
	if( (self = [super init]) )
	{
		datePickerMode = UIDatePickerModeDateAndTime;
	}
	return self;
}
- (NSDate *)modelDate
{
	id date = [self.model valueForKeyPath:self.modelPath];
	if(self.modelValueIsString)
	{
		if([date length] == 0)
		{
			date = [NSDate date];
			[self.model setValue:[NSString stringWithFormat:@"%f", [date timeIntervalSinceReferenceDate]] forKeyPath:self.modelPath];
		}
		else
		{
			date = [NSDate dateWithTimeIntervalSinceReferenceDate:[date doubleValue]];
		}
	}
	return date;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = [[self class] description];
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
	}

	// create dictionary entry for This Return Visit
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	assert(self.dateFormat.length != 0); // you forgot to include a date format
	[dateFormatter setDateFormat:self.dateFormat];
	cell.accessoryType = self.accessoryType;

	NSDate *date = [self modelDate];
	if([self.title length])
	{
		cell.textLabel.text = self.title;
		cell.detailTextLabel.text = [dateFormatter stringFromDate:date];
	}
	else
	{
		cell.textLabel.text = [dateFormatter stringFromDate:date];
		cell.detailTextLabel.text = @"";
	}

	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.selectedRow = indexPath;
	NSDate *date = [self modelDate];
	DatePickerViewController *p = [[[DatePickerViewController alloc] initWithDate:date] autorelease];
	p.delegate = self;
	p.datePickerMode = self.datePickerMode;
	[self.tableViewController.navigationController pushViewController:p animated:YES];		
	[self.tableViewController retainObject:self whileViewControllerIsManaged:p];
}

- (void)datePickerViewControllerDone:(DatePickerViewController *)datePickerViewController
{
	if(self.modelValueIsString)
	{
		[self.model setValue:[NSString stringWithFormat:@"%f", [[datePickerViewController date] timeIntervalSinceReferenceDate]] forKeyPath:self.modelPath];
	}
	else
	{
		[self.model setValue:[datePickerViewController date] forKeyPath:self.modelPath];
	}
	
	[self.tableViewController.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableViewController.navigationController popViewControllerAnimated:YES];
}
@end
