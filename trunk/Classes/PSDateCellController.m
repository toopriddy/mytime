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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = [[self class] description];
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	}

	// create dictionary entry for This Return Visit
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateFormat:self.dateFormat];
	cell.accessoryType = self.accessoryType;
	cell.textLabel.text = [dateFormatter stringFromDate:[self.model valueForKeyPath:self.modelPath]];
	
	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.selectedRow = indexPath;
	// make the new call view 
	DatePickerViewController *p = [[[DatePickerViewController alloc] initWithDate:[self.model valueForKeyPath:self.modelPath]] autorelease];
	p.delegate = self;
	[self.tableViewController.navigationController pushViewController:p animated:YES];		
	[self.tableViewController retainObject:self whileViewControllerIsManaged:p];
}

- (void)datePickerViewControllerDone:(DatePickerViewController *)datePickerViewController
{
	[self.model setValue:[datePickerViewController date] forKeyPath:self.modelPath];
	
	[self.tableViewController.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableViewController.navigationController popViewControllerAnimated:YES];
}
@end
