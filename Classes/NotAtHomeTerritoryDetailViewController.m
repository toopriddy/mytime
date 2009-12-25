//
//  NotAtHomeTerritoryDetailViewController.m
//  MyTime
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "NotAtHomeTerritoryDetailViewController.h"
#import "UITableViewTextFieldCell.h"
#import "NotesViewController.h"
#import "Settings.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "PSLocalization.h"

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
	BOOL obtainFocus;
}
@property (nonatomic, assign) BOOL obtainFocus;
@end
@implementation TerritoryNameCellController
@synthesize obtainFocus;

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
		cell = [[[UITableViewTextFieldCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	NSMutableString *name = [self.delegate.territory objectForKey:NotAtHomeTerritoryName];
	if(name == nil)
	{
		name = [[NSMutableString alloc] init];
		[self.delegate.territory setObject:name forKey:NotAtHomeTerritoryName];
	}
	cell.textField.text = [self.delegate.territory objectForKey:NotAtHomeTerritoryName];
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
	[[(UITableViewTextFieldCell *)[tableView cellForRowAtIndexPath:indexPath] textField] becomeFirstResponder];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableViewTextFieldCell:(UITableViewTextFieldCell *)cell selected:(BOOL)selected
{
}

- (BOOL)tableViewTextFieldCell:(UITableViewTextFieldCell *)cell shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	[[self.delegate.territory objectForKey:NotAtHomeTerritoryName] replaceCharactersInRange:range withString:string];
	return YES;
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
	
//	[cell.textLabel.r addSubView:[UIButton buttonWithType:UIButtonTypeContactAdd]];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// make the new call view 
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.title = NSLocalizedString(@"Email Address", @"pick an email address");
	picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
    picker.peoplePickerDelegate = self;
    [[self.delegate navigationController] presentModalViewController:picker animated:YES];
	[self.delegate retainObject:self whileViewControllerIsManaged:picker];
    [picker release];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker 
{
    [[self.delegate navigationController] dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person 
{
#if 0
    NSString* name = (NSString *)ABRecordCopyValue(person,
												   kABPersonFirstNameProperty);
    self.firstName.text = name;
    [name release];
	name = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    self.lastName.text = name;
    [name release];
#endif
//    [[self.delegate navigationController] dismissModalViewControllerAnimated:YES];
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}
@end



@implementation NotAtHomeTerritoryDetailViewController
@synthesize territory;
@synthesize delegate;

- (id)init
{
	if( (self = [super initWithStyle:UITableViewStyleGrouped]))
	{
		
	}
	return self;
}

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
