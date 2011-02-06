//
//  PSCheckmarkCellController.m
//  MyTime
//
//  Created by Brent Priddy on 2/3/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "PSCheckmarkCellController.h"


@implementation PSCheckmarkCellController
@synthesize checkedValue;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = [[self class] description];
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
	}
	
	cell.textLabel.text = self.title;
	if([self.checkedValue isEqual:[self.model valueForKeyPath:self.modelPath]])
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.model setValue:[[self.checkedValue copy] autorelease] forKey:self.modelPath];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;

	[super tableView:tableView didSelectRowAtIndexPath:indexPath];

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
