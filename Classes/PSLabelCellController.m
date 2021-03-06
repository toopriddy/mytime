//
//  PSLabelCellController.m
//  MyTime
//
//  Created by Brent Priddy on 1/30/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "PSLabelCellController.h"


@implementation PSLabelCellController
@synthesize hideModelValue;
@synthesize textAlignment;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = [[self class] description];
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
	}
	
	if(self.accessoryView)
	{
		cell.accessoryView = self.accessoryView;
	}
	else
	{
		cell.accessoryType = self.accessoryType;
	}
	if(self.editingAccessoryView)
	{
		cell.editingAccessoryView = self.editingAccessoryView;
	}
	else
	{
		cell.editingAccessoryType = self.editingAccessoryType;
	}
	
	cell.selectionStyle = self.selectionStyle;
	
	if([self.title length])
	{
		cell.textLabel.text = self.title;
		if(!self.hideModelValue)
		{
			cell.detailTextLabel.text = [self.model valueForKeyPath:self.modelPath];
		}
	}
	else
	{
		if(!self.hideModelValue)
		{
			cell.textLabel.text = [self.model valueForKeyPath:self.modelPath];
		}
		cell.detailTextLabel.text = @"";
	}
	cell.textLabel.textAlignment = self.textAlignment;
	
	return cell;
}



@end
