//
//  PSMultipleChoiceCellController.m
//  MyTime
//
//  Created by Brent Priddy on 8/6/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "PSMultipleChoiceCellController.h"


@implementation PSMultipleChoiceCellController
@synthesize choices;

- (void)psMultipleChoiceViewController:(PSMultipleChoiceViewController *)controller choiceSelected:(NSDictionary *)choice
{
	[self.tableViewController.navigationController popViewControllerAnimated:YES];
	[self.tableViewController.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedRow] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)psMultipleChoiceCellController:(PSMultipleChoiceCellController *)cellController tableView:(UITableView *)tableView selectedAtIndexPath:(NSIndexPath *)indexPath
{
	self.selectedRow = indexPath;
	PSMultipleChoiceViewController *controller = [[[PSMultipleChoiceViewController alloc] init] autorelease];
	controller.choices = self.choices;
	controller.delegate = self;
	controller.model = self.model;
	controller.modelPath = self.modelPath;
	[self.tableViewController.navigationController pushViewController:controller animated:YES];		
	[self.tableViewController retainObject:self whileViewControllerIsManaged:controller];
}

- (id)init
{
	if ( (self = [super init]) )
	{
		self.hideModelValue = YES;
		[self setSelectionTarget:self action:@selector(psMultipleChoiceCellController:tableView:selectedAtIndexPath:)];
	}
	return self;
}

- (void)dealloc
{
	self.choices = nil;
	[super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSObject *modelValue = [self.model valueForKey:self.modelPath];
	for(NSDictionary *section in self.choices)
	{
		for(NSDictionary *row in [section valueForKey:PSMultipleChoiceOptions])
		{
			NSString *label = [row valueForKey:PSMultipleChoiceOptionsLabel];
			NSObject *value = [row valueForKey:PSMultipleChoiceOptionsValue];
			if([modelValue isEqual:(value ? value : label)])
			{
				self.title = label;
				break;
			}
		}
	}
	return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}
@end
