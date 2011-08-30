//
//  NotAtHomeStreetDetailViewController.m
//  MyTime
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "NotAtHomeHouseViewController.h"
#import "NotesViewController.h"
#import "DatePickerViewController.h"
#import "UITableViewMultiTextFieldCell.h"
#import "UITableViewMultilineTextCell.h"
#import "UITableViewTitleAndValueCell.h"
#import <AddressBookUI/AddressBookUI.h>
#import "CallViewController.h"
#import "Geocache.h"
#import "MTCall.h"
#import "MTTerritory.h"
#import "MTTerritoryStreet.h"
#import "MTTerritoryHouse.h"
#import "MTTerritoryHouseAttempt.h"
#import "PSTextViewCellController.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSLocalization.h"

@interface NotAtHomeHouseViewController ()
- (void)resignAllFirstResponders;
@end


@interface NotAtHomeHouseViewCellController : NSObject<TableViewCellController>
{
	NotAtHomeHouseViewController *delegate;
}
@property (nonatomic, assign) NotAtHomeHouseViewController *delegate;
@end
@implementation NotAtHomeHouseViewCellController
@synthesize delegate;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}
@end


/******************************************************************
 *
 *   NAHHouseNameCellController
 *
 ******************************************************************/
#pragma mark NAHHouseNameCellController

@interface NAHHouseNameCellController : NotAtHomeHouseViewCellController<UITableViewMultiTextFieldCellDelegate>
{
	UITextField *textField1;
	UITextField *textField2;
}
@property (nonatomic, retain) UITextField *textField1;
@property (nonatomic, retain) UITextField *textField2;
@end
@implementation NAHHouseNameCellController
@synthesize textField1;
@synthesize textField2;

- (void)dealloc
{
	if(self.textField1)
	{
		[self.delegate.allTextFields removeObject:self.textField1];
		self.textField1 = nil;
	}
	if(self.textField2)
	{
		[self.delegate.allTextFields removeObject:self.textField2];
		self.textField2 = nil;
	}
	
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
	NSString *commonIdentifier = @"HouseApartmentCell";
	if(self.textField1)
	{
		[self.delegate.allTextFields removeObject:self.textField1];
		self.textField1 = nil;
	}
	if(self.textField2)
	{
		[self.delegate.allTextFields removeObject:self.textField2];
		self.textField2 = nil;
	}
	UITableViewMultiTextFieldCell *cell = (UITableViewMultiTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewMultiTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier textFieldCount:2] autorelease];
		cell.widths = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.55], [NSNumber numberWithFloat:.45], nil];
		cell.delegate = self;
		UITextField *streetTextField = [cell textFieldAtIndex:0];
		UITextField *apartmentTextField = [cell textFieldAtIndex:1];

		streetTextField.placeholder = NSLocalizedString(@"House Number", @"House Number");
		streetTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
		streetTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		streetTextField.returnKeyType = UIReturnKeyNext;
		streetTextField.clearButtonMode = UITextFieldViewModeAlways;
		
		apartmentTextField.placeholder = NSLocalizedString(@"Apt/Floor", @"Apartment/Floor Number");
		apartmentTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
		apartmentTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		apartmentTextField.returnKeyType = UIReturnKeyDone;
		apartmentTextField.clearButtonMode = UITextFieldViewModeAlways;
	}
	UITextField *streetTextField = [cell textFieldAtIndex:0];
	UITextField *apartmentTextField = [cell textFieldAtIndex:1];
	self.textField1 = streetTextField;
	[self.delegate.allTextFields addObject:self.textField1];
	self.textField2 = apartmentTextField;
	[self.delegate.allTextFields addObject:self.textField2];

	NSString *houseNumber = self.delegate.house.number;
	NSString *apartment = self.delegate.house.apartment;
	
	streetTextField.text = houseNumber;
	apartmentTextField.text = apartment;
	cell.delegate = self;
	if(self.delegate.obtainFocus)
	{
		[streetTextField performSelector:@selector(becomeFirstResponder)
							 withObject:nil
							 afterDelay:0.0000001];
		self.delegate.obtainFocus = NO;
	}
	
	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[(UITableViewMultiTextFieldCell *)[tableView cellForRowAtIndexPath:indexPath] textFieldAtIndex:0] becomeFirstResponder];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableViewMultiTextFieldCell:(UITableViewMultiTextFieldCell *)cell textField:(UITextField *)textField selected:(BOOL)selected
{
}

- (BOOL)tableViewMultiTextFieldCellShouldClear:(UITableViewMultiTextFieldCell *)cell textField:(UITextField *)textField
{
	UITextField *streetTextField = [cell textFieldAtIndex:0];
	UITextField *apartmentTextField = [cell textFieldAtIndex:1];
	
	if(textField == streetTextField)
	{
		self.delegate.house.number = @"";
	}
	else if(textField == apartmentTextField)
	{
		self.delegate.house.apartment = @"";
	}
	
	if(!self.delegate.newHouse)
	{
		self.delegate.title = [MTCall topLineOfAddressWithHouseNumber:self.delegate.house.number 
													  apartmentNumber:self.delegate.house.apartment 
															   street:nil];
	}

	// save the data
	NSError *error = nil;
	if(![self.delegate.house.managedObjectContext save:&error])
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:self.delegate.navigationController error:error];
	}
	
	return YES;
}

- (BOOL)tableViewMultiTextFieldCell:(UITableViewMultiTextFieldCell *)cell textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	UITextField *streetTextField = [cell textFieldAtIndex:0];
	UITextField *apartmentTextField = [cell textFieldAtIndex:1];
	MTTerritoryHouse *house = self.delegate.house;
	if(textField == streetTextField)
	{
		house.number = [textField.text stringByReplacingCharactersInRange:range withString:string];
	}
	else if(textField == apartmentTextField)
	{
		house.apartment = [textField.text stringByReplacingCharactersInRange:range withString:string];
	}
	
	if(!self.delegate.newHouse)
	{
		self.delegate.title = [MTCall topLineOfAddressWithHouseNumber:self.delegate.house.number 
													  apartmentNumber:self.delegate.house.apartment 
															   street:nil];
	}
	// save the data
	NSError *error = nil;
	if(![self.delegate.house.managedObjectContext save:&error])
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:self.delegate.navigationController error:error];
	}
	
	return YES;
}

@end


/******************************************************************
 *
 *   NAHHouseAttemptCellController
 *
 ******************************************************************/
#pragma mark NAHHouseAttemptCellController

@interface NAHHouseAttemptCellController : NotAtHomeHouseViewCellController <DatePickerViewControllerDelegate>
{
	MTTerritoryHouseAttempt *attempt;
}
@property (nonatomic, retain) MTTerritoryHouseAttempt *attempt;
@end
@implementation NAHHouseAttemptCellController
@synthesize attempt;

- (void)dealloc
{
	self.attempt = nil;
	[super dealloc];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"AttemptCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}

	NSDate *date = attempt.date;	
	// create dictionary entry for This Return Visit
	[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
	{
		[dateFormatter setDateFormat:@"EEE, d/M/yyy h:mma"];
	}
	else
	{
		[dateFormatter setDateFormat:NSLocalizedString(@"EEE, M/d/yyy h:mma", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.text = [dateFormatter stringFromDate:date];

	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	DatePickerViewController *controller = [[DatePickerViewController alloc] initWithDate:attempt.date];
	controller.delegate = self;
	controller.tag = indexPath.row;
	[self.delegate.navigationController pushViewController:controller animated:YES];
	[self.delegate retainObject:self whileViewControllerIsManaged:controller];
	[controller release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		DEBUG(NSLog(@"deleteReturnVisitAtIndex: %@", indexPath);)
		
		[self.attempt.managedObjectContext deleteObject:self.attempt];
		
		// save the data
		NSError *error = nil;
		if(![self.delegate.house.managedObjectContext save:&error])
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:self.delegate.navigationController error:error];
		}
		
		[[self retain] autorelease];
		[self.delegate deleteDisplayRowAtIndexPath:indexPath];
	}
}

- (void)datePickerViewControllerDone:(DatePickerViewController *)datePickerViewController
{
	self.attempt.date = datePickerViewController.date;

	// save the data
	NSError *error = nil;
	if(![self.delegate.house.managedObjectContext save:&error])
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:self.delegate.navigationController error:error];
	}
	
	[[self retain] autorelease];
	
	[self.delegate updateAndReload];
	[[self.delegate navigationController] popViewControllerAnimated:YES];
}
@end


/******************************************************************
 *
 *   NAHHouseAddAttemptCellController
 *
 ******************************************************************/
#pragma mark NAHHouseAddAttemptCellController

@interface NAHHouseAddAttemptCellController : NotAtHomeHouseViewCellController <DatePickerViewControllerDelegate>
{
@private	
}
@end
@implementation NAHHouseAddAttemptCellController

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleInsert;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"NewAttemptCell";
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	[cell setValue:NSLocalizedString(@"Add Attempt", @"button to add streets to the list of not at home streets")];
	return cell;
}

- (void)notAtHomeDetailCanceled
{
	[self.delegate dismissModalViewControllerAnimated:YES];
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.delegate resignAllFirstResponders];
	DatePickerViewController *controller = [[[DatePickerViewController alloc] init] autorelease];
	controller.delegate = self;
	
	// push the element view controller onto the navigation stack to display it
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
	
	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");
	
	controller.title = NSLocalizedString(@"Add Attempt", @"Title for the a new house in the Not At Home view");
	[self.delegate presentModalViewController:navigationController animated:YES];
	[temporaryBarButtonItem setAction:@selector(notAtHomeDetailCanceled)];
	[temporaryBarButtonItem setTarget:self];
	controller.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
	
	[self.delegate retainObject:self whileViewControllerIsManaged:controller];
}

- (void)datePickerViewControllerDone:(DatePickerViewController *)datePickerViewController
{
	MTTerritoryHouseAttempt *attempt = [MTTerritoryHouseAttempt insertInManagedObjectContext:self.delegate.house.managedObjectContext];
	attempt.date = datePickerViewController.date;
	attempt.house = self.delegate.house;
	// save the data
	NSError *error = nil;
	if(![self.delegate.house.managedObjectContext save:&error])
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:self.delegate.navigationController error:error];
	}
	
	[[self retain] autorelease];
	
	[self.delegate updateAndReload];
	[self.delegate dismissModalViewControllerAnimated:YES];
}

@end

/******************************************************************
 *
 *   NAHHouseConvertToCallCellController
 *
 ******************************************************************/
#pragma mark NAHHouseConvertToCallCellController

@interface NAHHouseConvertToCallCellController : NotAtHomeHouseViewCellController <CallViewControllerDelegate>
{
@private	
	MTCall *temporaryCall;
}
@property (nonatomic, retain) MTCall *temporaryCall;
@end
@implementation NAHHouseConvertToCallCellController
@synthesize temporaryCall;

- (void)dealloc
{
	self.temporaryCall = nil;
	[super dealloc];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"NewAttemptCell";
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	[cell setValue:NSLocalizedString(@"Convert to call", @"button to convert a not at home territpry house into a regular call")];
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (void)notAtHomeDetailCanceled
{
	[self.delegate dismissModalViewControllerAnimated:YES];
	[self.temporaryCall.managedObjectContext deleteObject:self.temporaryCall];
}

- (void)delegateLater
{
	// remove this house, pop view controller to the street
	if(self.delegate.delegate && [self.delegate.delegate respondsToSelector:@selector(notAtHomeHouseViewControllerDeleteHouse:)])
	{
		[self.delegate.delegate notAtHomeHouseViewControllerDeleteHouse:self.delegate];
	}
	[self autorelease];
}

- (void)callViewController:(CallViewController *)callViewController newCallDone:(MTCall *)call
{
	// save the new call
	NSError *error = nil;
	if(![self.delegate.house.managedObjectContext save:&error])
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:self.delegate.navigationController error:error];
	}
	
	if(![call.locationLookupType isEqualToString:CallLocationTypeManual])
	{
		[[Geocache sharedInstance] lookupCall:call];
	}
	
	// get outfrom underneeth the call
	[self retain];
	[self performSelector:@selector(delegateLater) withObject:nil afterDelay:0];

	[self.delegate dismissModalViewControllerAnimated:YES];	
}


// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.delegate resignAllFirstResponders];
	// setup the address from the not at home information
	MTTerritoryHouse *house = self.delegate.house;
	MTTerritoryStreet *street = house.street;
	MTTerritory *territory = street.territory;
	self.temporaryCall = [MTCall insertInManagedObjectContext:house.managedObjectContext];
	[self.temporaryCall initializeNewCall];
	self.temporaryCall.state = territory.state;
	self.temporaryCall.city = territory.city;
	self.temporaryCall.street = street.name;
	self.temporaryCall.houseNumber = house.number;
	self.temporaryCall.apartmentNumber = house.apartment;
	self.temporaryCall.user = territory.user;
	
	CallViewController *controller = [[[CallViewController alloc] initWithCall:self.temporaryCall newCall:YES] autorelease];
	controller.delegate = self;
		
	// push the element view controller onto the navigation stack to display it
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
	
	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");
	
	controller.title = controller.title;
	[self.delegate presentModalViewController:navigationController animated:YES];
	[temporaryBarButtonItem setAction:@selector(notAtHomeDetailCanceled)];
	[temporaryBarButtonItem setTarget:self];
	controller.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
	
	[self.delegate retainObject:self whileViewControllerIsManaged:controller];
}

@end

@implementation NotAtHomeHouseViewController
@synthesize house;
@synthesize delegate;
@synthesize tag;
@synthesize newHouse;
@synthesize obtainFocus;
@synthesize allTextFields;
	 
- (void)navigationControlDone:(id)sender 
{
	VERBOSE(NSLog(@"navigationControlDone:");)
	[self resignAllFirstResponders];
	if(delegate)
	{
		[delegate notAtHomeHouseViewControllerDone:self];
	}
}

- (void)navigationControlAction:(id)sender 
{
}

- (id)initWithHouse:(MTTerritoryHouse *)theHouse newHouse:(BOOL)isNewHouse
{
	if( (self = [super initWithStyle:UITableViewStyleGrouped]))
	{
		self.navigationItem.hidesBackButton = YES;
		self.allTextFields = [NSMutableArray array];
		newHouse = isNewHouse;
		self.obtainFocus = isNewHouse;
		self.house = theHouse;

		if(!isNewHouse)
		{
			self.title = [MTCall topLineOfAddressWithHouseNumber:self.house.number 
												 apartmentNumber:self.house.apartment 
														  street:nil];
		}
		self.hidesBottomBarWhenPushed = YES;
		self.editing = YES;
	}
	return self;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];	
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)dealloc
{
	self.house = nil;
	
	[super dealloc];
}

- (void)resignAllFirstResponders
{
	for(UITextField *textField in self.allTextFields)
	{
		[textField resignFirstResponder];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self resignAllFirstResponders];
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];

	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];

		{
			// House Name
			NAHHouseNameCellController *cellController = [[NAHHouseNameCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		{
			// House Notes
			PSTextViewCellController *cellController = [[[PSTextViewCellController alloc] init] autorelease];
			cellController.model = self.house;
			cellController.modelPath = @"notes";
			cellController.indentWhileEditing = NO;
			cellController.placeholder = NSLocalizedString(@"Add Notes", @"Placeholder for adding notes in the Not At Home views");
			cellController.title = NSLocalizedString(@"Notes", @"Not At Homes notes view title");
			[self addCellController:cellController toSection:sectionController];
		}
	}

	if(!newHouse)
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		{
			// Convert to call
			NAHHouseConvertToCallCellController *cellController = [[NAHHouseConvertToCallCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
	}
	
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		sectionController.editingTitle = NSLocalizedString(@"Attempts", @"Title of the section in the Not-At-Homes house view that allows you to add/edit attempts for the house");
		[sectionController release];

		NSArray *attempts = [self.house.managedObjectContext fetchObjectsForEntityName:[MTTerritoryHouseAttempt entityName]
																	 propertiesToFetch:nil 
																   withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:NO], nil]
																		 withPredicate:@"house == %@", self.house];
		for(MTTerritoryHouseAttempt *attempt in attempts)
		{
			// House
			NAHHouseAttemptCellController *cellController = [[NAHHouseAttemptCellController alloc] init];
			cellController.delegate = self;
			cellController.attempt = attempt;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		{
			// Add Attempt
			NAHHouseAddAttemptCellController *cellController = [[NAHHouseAddAttemptCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
	}
}


@end
