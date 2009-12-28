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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"NameCell";
	UITableViewTextFieldCell *cell = (UITableViewTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
		cell.textField.placeholder = NSLocalizedString(@"Territory Number", @"This is the territory idetifier that is on the Not At Home->New/edit territory");
	}
	NSMutableString *name = [self.delegate.territory objectForKey:NotAtHomeTerritoryName];
	if(name == nil)
	{
		name = [[NSMutableString alloc] init];
		[self.delegate.territory setObject:name forKey:NotAtHomeTerritoryName];
	}
	cell.textField.text = [self.delegate.territory objectForKey:NotAtHomeTerritoryName];
	cell.delegate = self;
	if(self.obtainFocus)
	{
		[cell.textField performSelector:@selector(becomeFirstResponder)
							 withObject:nil
							 afterDelay:0.0000001];
		self.obtainFocus = NO;
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
@interface TerritoryOwnerCellController : NotAtHomeTerritoryViewCellController<ABPeoplePickerNavigationControllerDelegate,
																			   UITableViewTextFieldCellDelegate>
{
	UITextField *owner;
}
@property (nonatomic, retain) UITextField *owner;
@end
@implementation TerritoryOwnerCellController
@synthesize owner;

- (id)initWithTextField:(UITextField *)theOwner
{
	if( (self = [super init]) )
	{
		self.owner = theOwner;
		NSSet *targets = [(UIButton *)self.owner.rightView allTargets];
		for(TerritoryOwnerCellController *controller in targets)
		{
			[(UIButton *)self.owner.rightView removeTarget:controller action:@selector(userSelected) forControlEvents:UIControlEventTouchUpInside];
		}
		[(UIButton *)self.owner.rightView addTarget:self action:@selector(userSelected) forControlEvents:UIControlEventTouchUpInside];

	}
	return self;
}

- (void)dealloc
{
	[(UIButton *)self.owner.rightView removeTarget:self action:@selector(userSelected) forControlEvents:UIControlEventTouchUpInside];
	self.owner = nil;
	
	[super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"OwnerCell";
	UITableViewTextFieldCell *cell = (UITableViewTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault textField:self.owner reuseIdentifier:commonIdentifier] autorelease];
		cell.textField.placeholder = NSLocalizedString(@"Territory Owner's Email Address", @"this is the label in the Not At Home View when you press on the Add button and enter in the territory's information");
	}
	cell.delegate = self;
	cell.textField.text = [self.delegate ownerEmailAddress];
	return cell;
}


- (void)userSelected
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.owner becomeFirstResponder];
}

- (BOOL)tableViewTextFieldCell:(UITableViewTextFieldCell *)cell shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSMutableString *emailAddress = [NSMutableString stringWithString:[self.delegate.territory objectForKey:NotAtHomeTerritoryOwnerEmailAddress]];
	[emailAddress replaceCharactersInRange:range withString:string];

	[self.delegate.territory setObject:emailAddress forKey:NotAtHomeTerritoryOwnerEmailAddress];
	[self.delegate.territory removeObjectForKey:NotAtHomeTerritoryOwnerId];
	[self.delegate.territory removeObjectForKey:NotAtHomeTerritoryOwnerEmailId];

	[[Settings sharedInstance] saveData];
	
	return YES;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker 
{
    [[self.delegate navigationController] dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person 
{
	ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
	if(ABMultiValueGetCount(emails) == 1)
	{
		[[self.delegate navigationController] dismissModalViewControllerAnimated:YES];
		[self.delegate.territory setObject:[NSNumber numberWithInt:ABRecordGetRecordID(person)] forKey:NotAtHomeTerritoryOwnerId];
		[self.delegate.territory setObject:[NSNumber numberWithInt:ABMultiValueGetIdentifierAtIndex(emails, 0)] forKey:NotAtHomeTerritoryOwnerEmailId];
		[self.delegate.territory setObject:[self.delegate ownerEmailAddress] forKey:NotAtHomeTerritoryOwnerEmailAddress];
		
		[self.delegate updateAndReload];
		return NO;
	}
	CFRelease(emails);
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
	[[self.delegate navigationController] dismissModalViewControllerAnimated:YES];
	[self.delegate.territory setObject:[NSNumber numberWithInt:ABRecordGetRecordID(person)] forKey:NotAtHomeTerritoryOwnerId];
	[self.delegate.territory setObject:[NSNumber numberWithInt:identifier] forKey:NotAtHomeTerritoryOwnerEmailId];
	[self.delegate.territory setObject:[self.delegate ownerEmailAddress] forKey:NotAtHomeTerritoryOwnerEmailAddress];
	
	[self.delegate updateAndReload];
    return NO;
}
@end



@implementation NotAtHomeTerritoryDetailViewController
@synthesize territory;
@synthesize delegate;
@synthesize owner;

- (UITextField *)owner
{
	if(owner == nil)
	{
		owner = [[[UITextField alloc] init] autorelease];
		[owner setBackgroundColor:[UIColor blueColor]];
		UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
		button.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
		owner.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		owner.returnKeyType = UIReturnKeyDone;
		
		owner.rightView = button;
		owner.rightViewMode = UITextFieldViewModeAlways;
	}
	return owner;
}

- (NSString *)ownerEmailAddress
{
	NSString *name = [[[self.territory objectForKey:NotAtHomeTerritoryOwnerEmailAddress] retain] autorelease];
	NSNumber *ownerId = [self.territory objectForKey:NotAtHomeTerritoryOwnerId];
	if(ownerId)
	{
		NSNumber *ownerEmailId = [self.territory objectForKey:NotAtHomeTerritoryOwnerEmailId];
		if(addressBook == nil)
			addressBook = ABAddressBookCreate();
		
		ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, [ownerId intValue]);
		ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
		int index = ABMultiValueGetIndexForIdentifier(emails, [ownerEmailId intValue]);
		if(index < ABMultiValueGetCount(emails))
		{
			name = [(NSString *)ABMultiValueCopyValueAtIndex(emails , index) autorelease];
		}
		CFRelease(emails);
	}	
	return name;
}

- (id)initWithTerritory:(NSMutableDictionary *)theTerritory
{
	if( (self = [super initWithStyle:UITableViewStyleGrouped]))
	{
		if(theTerritory == nil)
		{
			theTerritory = [[[NSMutableDictionary alloc] init] autorelease];
		}
		self.territory = theTerritory;
	}
	return self;
}

- (id)init
{
	return [self initWithTerritory:nil];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	
	if(addressBook)
	{
		CFRelease(addressBook);
		addressBook = nil;
	}
	
	self.owner = nil;
}



- (void)dealloc
{
	if(addressBook)
	{
		CFRelease(addressBook);
	}
	self.owner = nil;
	self.territory = nil;
	
	[super dealloc];
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
	
		{
			// Territory Owner
			TerritoryOwnerCellController *cellController = [[TerritoryOwnerCellController alloc] initWithTextField:self.owner];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	}
}


@end
