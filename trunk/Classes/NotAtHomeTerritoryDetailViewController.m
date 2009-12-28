//
//  NotAtHomeTerritoryDetailViewController.m
//  MyTime
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "NotAtHomeTerritoryDetailViewController.h"
#include "UITableViewTextFieldCell.h"
#import "PSLocalization.h"
#if 0
@interface NotAtHomeTerritoryViewCellController : NSObject<TableViewCellController>
{
	NotAtHomeTerritoryDetailViewController *delegate;
}
@property (nonatomic, assign) NotAtHomeTerritoryDetailViewController *delegate;
@end
@implementation NotAtHomeTerritoryViewCellController
@synthesize delegate;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}
@end


/******************************************************************
 *
 *   TerritoryNameCellController
 *
 ******************************************************************/
#pragma mark TerritoryNameCellController

@interface TerritoryNameCellController : NotAtHomeTerritoryViewCellController<UITableViewTextFieldCellDelegate>
{
@private	
	UITextField *name;
	BOOL obtainFocus;
}
@property (nonatomic, retain) UITextField *name;
@property (nonatomic, assign) BOOL obtainFocus;
@end
@implementation TerritoryNameCellController
@synthesize name;
@synthesize obtainFocus;

- (void)dealloc
{
	self.name = nil;
	
	[super dealloc];
}

- (BOOL)isViewableWhenNotEditing
{
	return [[self.delegate.territory objectForKey:NotAtHomeTerritoryName] length];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"NameCell";
	UITableViewTextFieldCell *cell = (UITableViewTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewTextFieldCell alloc] initWithStyle: UITableViewCellStyleDefault textField:_name reuseIdentifier:commonIdentifier] autorelease];
	}
	else
	{
		cell.textField = self.name;
	}
	cell.delegate = self;
	cell.observeEditing = YES;
	if(tableView.editing)
	{
		if(self.obtainFocus)
		{
			[cell.textField performSelector:@selector(becomeFirstResponder)
								 withObject:nil
								 afterDelay:0.0000001];
			self.obtainFocus = NO;
		}
	}
	
	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.name becomeFirstResponder];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end


/******************************************************************
 *
 *   TerritoryOwnerCellController
 *
 ******************************************************************/
#pragma mark TerritoryOwnerCellController
@interface TerritoryOwnerCellController : NotAtHomeTerritoryViewCellController<ABPeoplePickerNavigationControllerDelegate>
{
}
@end
@implementation TerritoryOwnerCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"OwnerCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = NSLocalizedString(@"Create a note from scratch", @"More View Table Enable shown popups");
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// make the new call view 
	NotesViewController *p = [[[NotesViewController alloc] initWithNotes:@""] autorelease];
	p.delegate = self;
	[[self.delegate navigationController] pushViewController:p animated:YES];		
	[self.delegate retainObject:self whileViewControllerIsManaged:p];
}

- (void)notesViewControllerDone:(NotesViewController *)notesViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	if(self.delegate.delegate && [self.delegate.delegate respondsToSelector:@selector(notesViewControllerDone:)])
	{
		[self.delegate.delegate notesViewControllerDone:notesViewController];
	}
}

@end



@implementation NotAtHomeTerritoryDetailViewController
@synthesize territory;
@synthesize delegate;

- (void)constructSectionControllers
{
	[super constructSectionControllers];

	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];

		{
			// Territory Name
			TerritoryNameCellController *cellController = [[TerritoryNameCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	}

	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		sectionController.title = NSLocalizedString(@"Territory Owner", @"This is in the Not At Homes View when you add/edit a territory and you want to give the territory an owner");
		[sectionController release];
	
		{
			// Territory Owner
			TerritoryOwnerCellController *cellController = [[TerritoryOwnerCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	}
}


@end
#endif