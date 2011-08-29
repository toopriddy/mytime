//
//  PSMultipleChoiceViewController.m
//  MyTime
//
//  Created by Brent Priddy on 8/6/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "PSMultipleChoiceViewController.h"
#import "PSCheckmarkCellController.h"

NSString * const PSMultipleChoiceHeader = @"PSMultipleChoiceHeader";
NSString * const PSMultipleChoiceFooter = @"PSMultipleChoiceFooter";
NSString * const PSMultipleChoiceOptions = @"PSMultipleChoiceOptions";
NSString * const PSMultipleChoiceOptionsLabel = @"PSMultipleChoiceOptionsLabel";
NSString * const PSMultipleChoiceOptionsValue = @"PSMultipleChoiceOptionsValue";

@implementation PSMultipleChoiceViewController
@synthesize delegate;
@synthesize choices;
@synthesize model;
@synthesize modelPath;

- (void)dealloc
{
	self.choices = nil;
	self.model = nil;
	self.modelPath = nil;
	
	[super dealloc];
}

- (id)init
{
	if ([super initWithStyle:UITableViewStyleGrouped]) 
	{
	}
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)checkmarkCellController:(PSCheckmarkCellController *)cellController tableView:(UITableView *)tableView selectedAtIndexPath:(NSIndexPath *)indexPath
{
	[self.model setValue:cellController.checkedValue forKey:self.modelPath];
	[self updateWithoutReload];
	if(self.delegate && [self.delegate respondsToSelector:@selector(psMultipleChoiceViewController:choiceSelected:)])
	{
		[self.delegate psMultipleChoiceViewController:self choiceSelected:(id)cellController.userData];
	}
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];
	
	for(NSDictionary *choiceSection in self.choices)
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		sectionController.title = [choiceSection valueForKey:PSMultipleChoiceHeader];
		sectionController.footer = [choiceSection valueForKey:PSMultipleChoiceFooter];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		for(NSDictionary *choiceRow in [choiceSection objectForKey:PSMultipleChoiceOptions])
		{
			NSString *label = [choiceRow valueForKey:PSMultipleChoiceOptionsLabel];
			NSObject *value = [choiceRow valueForKey:PSMultipleChoiceOptionsValue];
			PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
			cellController.userData = choiceRow;
			cellController.title = label;
			cellController.model = self.model;
			cellController.modelPath = self.modelPath;
			cellController.checkedValue = value ? value : label;
			[cellController setSelectionTarget:self action:@selector(checkmarkCellController:tableView:selectedAtIndexPath:)];
			[self addCellController:cellController toSection:sectionController];
		}
	}
}

@end



