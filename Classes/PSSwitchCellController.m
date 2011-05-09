//
//  PSSwitchCellController.m
//  MyTime
//
//  Created by Brent Priddy on 2/1/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "PSSwitchCellController.h"


@implementation PSSwitchCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = @"UITableViewSwitchCell";
	UITableViewSwitchCell *cell = (UITableViewSwitchCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	if(cell == nil)
	{
		UIViewController *controller = [[[UIViewController alloc] initWithNibName:identifier bundle:nil] autorelease];
		cell = (UITableViewSwitchCell *)controller.view;
	}
	cell.otherTextLabel.text = self.title;
	cell.booleanSwitch.on = [[self.model valueForKeyPath:self.modelPath] boolValue];
	cell.delegate = self;
	
	return cell;
}

- (void)uiTableViewSwitchCellChanged:(UITableViewSwitchCell *)uiTableViewSwitchCell;
{
	[self.model setValue:[NSNumber numberWithBool:uiTableViewSwitchCell.booleanSwitch.on] forKey:self.modelPath];
}

@end
