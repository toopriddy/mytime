//
//  PSSegmentedControlCellController.m
//  MyTime
//
//  Created by Brent Priddy on 2/1/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "PSSegmentedControlCellController.h"


@implementation PSSegmentedControlCellController
@synthesize segmentedControlValues;
@synthesize segmentedControlTitles;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = @"UITableViewSegmentedControlCell";
	UITableViewSegmentedControlCell *cell = (UITableViewSegmentedControlCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	if(cell == nil)
	{
		UIViewController *controller = [[[UIViewController alloc] initWithNibName:identifier bundle:nil] autorelease];
		cell = (UITableViewSegmentedControlCell *)controller.view;
	}
	cell.otherTextLabel.text = self.title;
	cell.segmentedControlTitles = self.segmentedControlTitles;
	NSInteger index = [self.segmentedControlValues indexOfObject:[self.model valueForKey:self.modelPath]];
	if(index == NSNotFound)
	{
		index = 0;
	}
	cell.selectedSegmentIndex = index;
	cell.delegate = self;
	
	return cell;
}

- (void)uiTableViewSegmentedControllCellChanged:(UITableViewSegmentedControlCell *)uiTableViewSwitchCell;
{
	[self.model setValue:[self.segmentedControlValues objectAtIndex:uiTableViewSwitchCell.segmentedControl.selectedSegmentIndex] forKey:self.modelPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [UITableViewSegmentedControlCell heightForRow];
}
@end
