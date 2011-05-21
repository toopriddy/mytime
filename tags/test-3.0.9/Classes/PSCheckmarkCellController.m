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
@synthesize cachedTableView;
@synthesize cachedIndexPath;

- (void)dealloc
{
	self.cachedTableView = nil;
	self.cachedIndexPath = nil;
	
	// remove old observed object/path
	if(self.model && [self.modelPath length])
	{
		[self.model removeObserver:self forKeyPath:self.modelPath];
	}

	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if(self.cachedTableView && self.cachedIndexPath && [self.cachedTableView numberOfRowsInSection:self.cachedIndexPath.section] > self.cachedIndexPath.row)
	{
		[self.cachedTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.cachedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
	}
}

- (void)setModel:(NSObject *)model
{
	// remove old observed object/path
	if(self.model && [self.modelPath length])
	{
		[self.model removeObserver:self forKeyPath:self.modelPath];
	}
	[super setModel:model];
	if(self.model && [self.modelPath length])
	{
		[self.model addObserver:self forKeyPath:self.modelPath options:0 /*NSKeyValueObservingOptionNew*/ context:nil]; 
	}
}

- (void)setModelPath:(NSString *)path
{
	// remove old observed object/path
	if(self.model && [self.modelPath length])
	{
		[self.model removeObserver:self forKeyPath:self.modelPath];
	}
	[super setModelPath:path];
	if(self.model != nil && [self.modelPath length])
	{
		[self.model addObserver:self forKeyPath:self.modelPath options:0 /*NSKeyValueObservingOptionNew*/ context:nil]; 
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = [[self class] description];
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
	}

	self.cachedTableView = tableView;
	self.cachedIndexPath = indexPath;
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
