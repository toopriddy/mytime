//
//  NotAtHomeTerritoryDetailViewController.m
//  MyTime
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "NotAtHomeTerritoryViewController.h"
#import "UITableViewTextFieldCell.h"
#import "NotesViewController.h"
#import "Settings.h"
#import "NotAtHomeStreetViewController.h"
#import "UITableViewTitleAndValueCell.h"
#import <AddressBookUI/AddressBookUI.h>
#import "PSLocalization.h"

@interface SelectRowNextResponder : UIResponder <UITextFieldDelegate>
{
	UITableView *tableView;
	NSIndexPath *indexPath;
}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSIndexPath *indexPath;

- (id)initWithTable:(UITableView *)theTableView indexPath:(NSIndexPath *)theIndexPath;
@end

@implementation SelectRowNextResponder

@synthesize tableView;
@synthesize indexPath;
- (void)dealloc
{
	self.tableView = nil;
	self.indexPath = nil;
	[super dealloc];
}

- (id)initWithTable:(UITableView *)theTableView indexPath:(NSIndexPath *)theIndexPath
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	if((self = [super init]))
	{
		self.tableView = theTableView;
		self.indexPath = theIndexPath;
	}
	return self;
}

- (BOOL)becomeFirstResponder 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	[self.tableView deselectRowAtIndexPath:nil animated:NO];
	[self.tableView selectRowAtIndexPath:self.indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
	[self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:self.indexPath];
	return NO;
}
@end


@interface NotAtHomeTerritoryViewCellController : NSObject<TableViewCellController>
{
	NotAtHomeTerritoryViewController *delegate;
}
@property (nonatomic, assign) NotAtHomeTerritoryViewController *delegate;
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
 *   NAHTerritoryNameCellController
 *
 ******************************************************************/
#pragma mark NAHTerritoryNameCellController

@interface NAHTerritoryNameCellController : NotAtHomeTerritoryViewCellController<UITableViewTextFieldCellDelegate>
{
@private	
	BOOL obtainFocus;
	SelectRowNextResponder *nextRowResponder;
}
@property (nonatomic, assign) BOOL obtainFocus;
@property (nonatomic, retain) SelectRowNextResponder *nextRowResponder;
@end
@implementation NAHTerritoryNameCellController
@synthesize obtainFocus;
@synthesize nextRowResponder;

- (void)dealloc
{
	self.nextRowResponder = nil;
	
	[super dealloc];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"NameCell";
	UITableViewTextFieldCell *cell = (UITableViewTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(self.nextRowResponder == nil)
	{
		self.nextRowResponder = [[[SelectRowNextResponder alloc] initWithTable:tableView indexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] autorelease];
	}
	if(cell == nil)
	{
		cell = [[[UITableViewTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
		cell.textField.placeholder = NSLocalizedString(@"Territory Number", @"This is the territory idetifier that is on the Not At Home->New/edit territory");
		cell.nextKeyboardResponder = self.nextRowResponder;
	}
	NSMutableString *name = [self.delegate.territory objectForKey:NotAtHomeTerritoryName];
	if(name == nil)
	{
		name = [[NSMutableString alloc] init];
		[self.delegate.territory setObject:name forKey:NotAtHomeTerritoryName];
		[name release];
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
	NSMutableString *name = [self.delegate.territory objectForKey:NotAtHomeTerritoryName];
	[name replaceCharactersInRange:range withString:string];
	if(!self.delegate.newTerritory)
		self.delegate.title = name;
	return YES;
}

@end


/******************************************************************
 *
 *   NAHTerritoryCityCellController
 *
 ******************************************************************/
#pragma mark NAHTerritoryCityCellController

@interface NAHTerritoryCityCellController : NotAtHomeTerritoryViewCellController<UITableViewTextFieldCellDelegate>
{
	SelectRowNextResponder *nextRowResponder;
}
@property (nonatomic, retain) SelectRowNextResponder *nextRowResponder;
@end
@implementation NAHTerritoryCityCellController
@synthesize nextRowResponder;

- (void)dealloc
{
	self.nextRowResponder = nil;
	
	[super dealloc];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"CityCell";
	UITableViewTextFieldCell *cell = (UITableViewTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(self.nextRowResponder == nil)
	{
		self.nextRowResponder = [[[SelectRowNextResponder alloc] initWithTable:tableView indexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] autorelease];
	}
	if(cell == nil)
	{
		cell = [[[UITableViewTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
		cell.textField.placeholder = NSLocalizedString(@"City", @"City");
		cell.textField.returnKeyType = UIReturnKeyNext;
		cell.textField.clearButtonMode = UITextFieldViewModeAlways;
		cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		cell.nextKeyboardResponder = self.nextRowResponder;
	}
	NSMutableString *name = [self.delegate.territory objectForKey:NotAtHomeTerritoryCity];
	if(name == nil)
	{
		name = [[NSMutableString alloc] init];
		[self.delegate.territory setObject:name forKey:NotAtHomeTerritoryCity];
		[name release];
	}
	cell.textField.text = [self.delegate.territory objectForKey:NotAtHomeTerritoryCity];
	cell.delegate = self;

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
	NSMutableString *name = [self.delegate.territory objectForKey:NotAtHomeTerritoryCity];
	[name replaceCharactersInRange:range withString:string];
	return YES;
}

@end


/******************************************************************
 *
 *   NAHNAHTerritoryStateCellController
 *
 ******************************************************************/
#pragma mark NAHTerritoryStateCellController

@interface NAHTerritoryStateCellController : NotAtHomeTerritoryViewCellController<UITableViewTextFieldCellDelegate>
{
	SelectRowNextResponder *nextRowResponder;
}
@property (nonatomic, retain) SelectRowNextResponder *nextRowResponder;
@end
@implementation NAHTerritoryStateCellController
@synthesize nextRowResponder;

- (void)dealloc
{
	self.nextRowResponder = nil;
	
	[super dealloc];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"StateCell";
	UITableViewTextFieldCell *cell = (UITableViewTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(self.nextRowResponder == nil)
	{
		self.nextRowResponder = [[[SelectRowNextResponder alloc] initWithTable:tableView indexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] autorelease];
	}
	if(cell == nil)
	{
		cell = [[[UITableViewTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
		cell.textField.placeholder = NSLocalizedString(@"State or Country", @"State or Country");
		cell.textField.returnKeyType = UIReturnKeyDone;
		cell.textField.clearButtonMode = UITextFieldViewModeAlways;
		cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		cell.nextKeyboardResponder = self.nextRowResponder;
	}
	NSMutableString *name = [self.delegate.territory objectForKey:NotAtHomeTerritoryState];
	if(name == nil)
	{
		name = [[NSMutableString alloc] init];
		[self.delegate.territory setObject:name forKey:NotAtHomeTerritoryState];
		[name release];
	}
	cell.textField.text = [self.delegate.territory objectForKey:NotAtHomeTerritoryState];
	cell.delegate = self;
	
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
	NSMutableString *name = [self.delegate.territory objectForKey:NotAtHomeTerritoryState];
	[name replaceCharactersInRange:range withString:string];
	return YES;
}

@end


/******************************************************************
 *
 *   NAHTerritoryOwnerCellController
 *
 ******************************************************************/
#pragma mark NAHTerritoryOwnerCellController
@interface NAHTerritoryOwnerCellController : NotAtHomeTerritoryViewCellController<ABPeoplePickerNavigationControllerDelegate,
																			   UITableViewTextFieldCellDelegate>
{
	UITextField *owner;
}
@property (nonatomic, retain) UITextField *owner;
@end
@implementation NAHTerritoryOwnerCellController
@synthesize owner;

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (id)initWithTextField:(UITextField *)theOwner
{
	if( (self = [super init]) )
	{
		self.owner = theOwner;
		NSSet *targets = [(UIButton *)self.owner.rightView allTargets];
		for(NAHTerritoryOwnerCellController *controller in targets)
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
	[self.delegate.owner becomeFirstResponder];
	[self.delegate.owner resignFirstResponder];
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
	NSString *previousEmail = [self.delegate.territory objectForKey:NotAtHomeTerritoryOwnerEmailAddress];
	NSMutableString *emailAddress = [NSMutableString stringWithString:previousEmail ? previousEmail : @""];
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
		CFRelease(emails);
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




/******************************************************************
*
*   NAHTerritoryStreetCellController
*
******************************************************************/
#pragma mark NAHTerritoryStreetCellController

@interface NAHTerritoryStreetCellController : NotAtHomeTerritoryViewCellController <NotAtHomeStreetViewControllerDelegate>
{
@private	
}
@end
@implementation NAHTerritoryStreetCellController

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"StreetCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	cell.textLabel.text = [[[self.delegate.territory objectForKey:NotAtHomeTerritoryStreets] objectAtIndex:indexPath.row] objectForKey:NotAtHomeTerritoryStreetName];
	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NotAtHomeStreetViewController *controller = [[NotAtHomeStreetViewController alloc] initWithStreet:[[self.delegate.territory objectForKey:NotAtHomeTerritoryStreets] objectAtIndex:indexPath.row]];
	controller.delegate = self;
	[self.delegate.navigationController pushViewController:controller animated:YES];
	[self.delegate retainObject:self whileViewControllerIsManaged:controller];
	[controller release];
}

- (void)notAtHomeStreetViewControllerDone:(NotAtHomeStreetViewController *)notAtHomeStreetViewController
{
	[[Settings sharedInstance] saveData];
	[self.delegate.navigationController popViewControllerAnimated:YES];
	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		self.delegate.forceReload = YES;
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		DEBUG(NSLog(@"deleteReturnVisitAtIndex: %@", indexPath);)
		
		[[self.delegate.territory objectForKey:NotAtHomeTerritoryStreets] removeObjectAtIndex:indexPath.row];
		
		// save the data
		// save the data
		[[Settings sharedInstance] saveData];
		
		[[self retain] autorelease];
		[self.delegate deleteDisplayRowAtIndexPath:indexPath];
	}
}

@end

/******************************************************************
 *
 *   NAHTerritoryAddStreetCellController
 *
 ******************************************************************/
#pragma mark NAHTerritoryAddStreetCellController

@interface NAHTerritoryAddStreetCellController : NotAtHomeTerritoryViewCellController <NotAtHomeStreetViewControllerDelegate>
{
@private	
	int section;
	int row;
}
@end
@implementation NAHTerritoryAddStreetCellController

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleInsert;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"StreetCell";
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	[cell setValue:NSLocalizedString(@"Add Street", @"button to add streets to the list of not at home streets")];
	section = indexPath.section;
	row = indexPath.row;
	return cell;
}

- (void)notAtHomeDetailCanceled
{
	[self.delegate dismissModalViewControllerAnimated:YES];
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NotAtHomeStreetViewController *controller = [[[NotAtHomeStreetViewController alloc] init] autorelease];
	controller.delegate = self;

	// push the element view controller onto the navigation stack to display it
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
	
	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");
	
	controller.title = NSLocalizedString(@"Add New Street", @"Title for the a new street in the Not At Home view");
	[self.delegate presentModalViewController:navigationController animated:YES];
	[temporaryBarButtonItem setAction:@selector(notAtHomeDetailCanceled)];
	[temporaryBarButtonItem setTarget:self];
	controller.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
	
	[self.delegate retainObject:self whileViewControllerIsManaged:controller];
}

- (void)notAtHomeStreetViewControllerDone:(NotAtHomeStreetViewController *)notAtHomeStreetViewController
{
	NSMutableArray *streets = [self.delegate.territory objectForKey:NotAtHomeTerritoryStreets];
	if(streets == nil)
	{
		streets = [[NSMutableArray alloc] init];
		[self.delegate.territory setObject:streets forKey:NotAtHomeTerritoryStreets];
		[streets release];
	}
	[streets addObject:notAtHomeStreetViewController.street];
	[[Settings sharedInstance] saveData];
	
	NAHTerritoryStreetCellController *cellController = [[NAHTerritoryStreetCellController alloc] init];
	cellController.delegate = self.delegate;
	[[[self.delegate.sectionControllers objectAtIndex:section] cellControllers] insertObject:cellController atIndex:([streets count] - 1)];

	[self.delegate dismissModalViewControllerAnimated:YES];
	[self.delegate updateWithoutReload];
}

@end


@implementation NotAtHomeTerritoryViewController
@synthesize territory;
@synthesize delegate;
@synthesize owner;
@synthesize tag;
@synthesize newTerritory;

- (UITextField *)owner
{
	if(owner == nil)
	{
		owner = [[UITextField alloc] init];
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

- (void)navigationControlDone:(id)sender 
{
	VERBOSE(NSLog(@"navigationControlDone:");)
	if(delegate)
	{
		[delegate notAtHomeTerritoryViewControllerDone:self];
	}
}

- (void)navigationControlAction:(id)sender 
{
}

- (id)initWithTerritory:(NSMutableDictionary *)theTerritory
{
	if( (self = [super initWithStyle:UITableViewStyleGrouped]))
	{
		if(theTerritory == nil)
		{
			newTerritory = YES;
			theTerritory = [[[NSMutableDictionary alloc] init] autorelease];
		}
		self.territory = theTerritory;
		if(!newTerritory)
		{
			self.title = [theTerritory objectForKey:NotAtHomeTerritoryName];
			UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
																					 target:self 
																					 action:@selector(navigationControlAction:)] autorelease];
			[self.navigationItem setLeftBarButtonItem:button animated:YES];
		}
		self.hidesBottomBarWhenPushed = YES;
		self.editing = YES;
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
	
//	self.owner = nil;
}

- (void)loadView
{
	[super loadView];
	
	// add DONE button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];	
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

#if 0
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//	[super scrollViewDidScroll:scrollView];
	[owner becomeFirstResponder];
	[owner resignFirstResponder];
}
#endif

- (void)constructSectionControllers
{
	[super constructSectionControllers];

	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];

		{
			// Territory Name
			NAHTerritoryNameCellController *cellController = [[NAHTerritoryNameCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		{
			// Territory City
			NAHTerritoryCityCellController *cellController = [[NAHTerritoryCityCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		{
			// Territory State
			NAHTerritoryStateCellController *cellController = [[NAHTerritoryStateCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		{
			// Territory Owner
			NAHTerritoryOwnerCellController *cellController = [[NAHTerritoryOwnerCellController alloc] initWithTextField:self.owner];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	}

	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		sectionController.title = NSLocalizedString(@"Streets", @"Title of the section in the Not-At-Homes territory view that allows you to add/edit streets in the territory");
		[sectionController release];

		for(NSDictionary *street in [self.territory objectForKey:NotAtHomeTerritoryStreets])
		{
			// Add Territory Street
			NAHTerritoryStreetCellController *cellController = [[NAHTerritoryStreetCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		{
			// Add Territory Street
			NAHTerritoryAddStreetCellController *cellController = [[NAHTerritoryAddStreetCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
	}
}


@end
