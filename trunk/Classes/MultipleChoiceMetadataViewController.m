//
//  MultipleChoiceMetadataViewController.m
//  MyTime
//
//  Created by Brent Priddy on 11/28/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "MultipleChoiceMetadataViewController.h"
#import "MetadataCustomViewController.h"
#import "PSLocalization.h"
#import "Settings.h"

@interface MultipleChoiceMetadataViewController ()
@property (nonatomic, retain) NSMutableArray *data;
@end



/******************************************************************
 *
 *   CHOICE SECTION
 *
 ******************************************************************/
#pragma mark MultipleChoiceSectionController
@interface MultipleChoiceSectionController : GenericTableViewSectionController
{
	MultipleChoiceMetadataViewController *delegate;
}
@property (nonatomic, assign) MultipleChoiceMetadataViewController *delegate;
@end
@implementation MultipleChoiceSectionController
@synthesize delegate;

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if(tableView.editing)
		return NSLocalizedString(@"Enter the Multiple Choice Values here", @"text that appears in the Call->Edit->Add Additional Information->Edit->Add Custom->Multiple Choice type area so that you can add values to your multiple choice type");
	return nil;
}

@end





@implementation MultipleChoiceMetadataViewController

@synthesize delegate;
@synthesize data;
@synthesize value;

- (void)dealloc
{
	self.data = nil;
	self.value = nil;
	
	[super dealloc];
}

- (id) initWithName:(NSString *)theName value:(NSString *)theValue
{
	if ([super initWithStyle:UITableViewStyleGrouped]) 
	{
		for(NSDictionary *entry in [[[Settings sharedInstance] userSettings] objectForKey:SettingsPreferredMetadata])
		{
			if([theName isEqualToString:[entry objectForKey:SettingsMetadataName]])
			{
				self.data = [entry objectForKey:SettingsMetadataData];
			}
		}
		for(NSDictionary *entry in [[[Settings sharedInstance] userSettings] objectForKey:SettingsMetadata])
		{
			if([theName isEqualToString:[entry objectForKey:SettingsMetadataName]])
			{
				self.data = [entry objectForKey:SettingsMetadataData];
			}
		}
		if(self.data == nil)
		{
			self.data = [NSMutableArray arrayWithObject:theValue];
		}

		self.value = theValue;
		
		// set the title, and tab bar images from the dataSource
		self.title = NSLocalizedString(@"Custom", @"Title for field in the Additional Information for the user to create their own additional information field");
	}
	return self;
}

- (void)tableView:(UITableView *)tableView didSelectValue:(NSString *)theValue atIndexPath:(NSIndexPath *)indexPath
{
	self.value = theValue;
	int count = [tableView numberOfRowsInSection:indexPath.section];
	for(int i = 0; i < count; ++i)
	{
		if(i == indexPath.row)
			[[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]] setAccessoryType:UITableViewCellAccessoryCheckmark];
		else
			[[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]] setAccessoryType:UITableViewCellAccessoryNone];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if(delegate && [delegate respondsToSelector:@selector(multipleChoiceMetadataViewControllerDone:)])
	{
		[delegate multipleChoiceMetadataViewControllerDone:self];
	}
	[[self navigationController] popViewControllerAnimated:YES];
}

- (NSString *)selectedMetadataValue
{
	return self.value;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)navigationControlEdit:(id)sender 
{
	[self.tableView flashScrollIndicators];
	
	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	
	// hide the back button so that they cant cancel the edit without hitting done
	self.navigationItem.hidesBackButton = YES;
	
	self.editing = YES;
}	

- (void)navigationControlDone:(id)sender 
{
	[self.tableView flashScrollIndicators];
	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																			 target:self
																			 action:@selector(navigationControlEdit:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	// show the back button when they are done editing
	self.navigationItem.hidesBackButton = NO;
	
	[[Settings sharedInstance] saveData];
	self.editing = NO;
}	


- (void)loadView 
{
	[super loadView];
	
	self.editing = NO;
	
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																			 target:self
																			 action:@selector(navigationControlEdit:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath 
{
	GenericTableViewSectionController *sectionController = [self.displaySectionControllers objectAtIndex:proposedDestinationIndexPath.section];
	// check to see if they are moving it beyond the "Add custom information", the last entry and there are no entries in the list
	if(proposedDestinationIndexPath.section == sourceIndexPath.section && 
	   (sectionController.displayCellControllers.count - 1) == proposedDestinationIndexPath.row &&
	   sectionController.displayCellControllers.count > 1)
	{
		// only subtract 1 off of the row if the source row is in the same section (cause the row count is not increasing just getting shuffled)
		int offset = proposedDestinationIndexPath.section == sourceIndexPath.section ? 1 : 0;
		// if there is only one section controller in this section then put the entry 
		return [NSIndexPath indexPathForRow:(proposedDestinationIndexPath.row - offset) inSection:proposedDestinationIndexPath.section];
	}
    // Allow the proposed destination.
    return proposedDestinationIndexPath;
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];
	
	// Multiple Choice section
	{
		MultipleChoiceSectionController *sectionController = [[MultipleChoiceSectionController alloc] init];
		sectionController.delegate = self;
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		[MetadataCustomViewController addCellMultipleChoiceCellControllersToSectionController:sectionController tableController:self choices:self.data metadataDelegate:self];
	}
}

@end



