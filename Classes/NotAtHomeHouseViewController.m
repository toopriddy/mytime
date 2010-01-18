//
//  NotAtHomeStreetDetailViewController.m
//  MyTime
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "NotAtHomeHouseViewController.h"
#import "UITableViewTextFieldCell.h"
#import "NotesViewController.h"
#import "DatePickerViewController.h"
#import "UITableViewMultiTextFieldCell.h"
#import "UITableViewMultilineTextCell.h"
#import "UITableViewTitleAndValueCell.h"
#import "Settings.h"
#import <AddressBookUI/AddressBookUI.h>
#import "PSLocalization.h"

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

	NSMutableString *houseNumber = [self.delegate.house objectForKey:NotAtHomeTerritoryHouseNumber];
	NSMutableString *apartment = [self.delegate.house objectForKey:NotAtHomeTerritoryHouseApartment];
	if(houseNumber == nil)
	{
		[self.delegate.house setObject:(houseNumber = [NSMutableString string]) forKey:NotAtHomeTerritoryHouseNumber];
	}
	if(apartment == nil)
	{
		[self.delegate.house setObject:(apartment = [NSMutableString string]) forKey:NotAtHomeTerritoryHouseApartment];
	}
	
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
	NSMutableString *houseNumber = [self.delegate.house objectForKey:NotAtHomeTerritoryHouseNumber];
	NSMutableString *apartment = [self.delegate.house objectForKey:NotAtHomeTerritoryHouseApartment];
	
	if(textField == streetTextField)
	{
		[houseNumber setString:@""];
	}
	else if(textField == apartmentTextField)
	{
		[apartment setString:@""];
	}
	
	if(!self.delegate.newHouse)
	{
		NSMutableString *string = [[NSMutableString alloc] init];
		[Settings formatStreetNumber:houseNumber
						   apartment:apartment
							 topLine:string];
		self.delegate.title = string;
		[string release];
	}
	
	return YES;
}

- (BOOL)tableViewMultiTextFieldCell:(UITableViewMultiTextFieldCell *)cell textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	UITextField *streetTextField = [cell textFieldAtIndex:0];
	UITextField *apartmentTextField = [cell textFieldAtIndex:1];
	NSMutableString *houseNumber = [self.delegate.house objectForKey:NotAtHomeTerritoryHouseNumber];
	NSMutableString *apartment = [self.delegate.house objectForKey:NotAtHomeTerritoryHouseApartment];

	if(textField == streetTextField)
	{
		[houseNumber replaceCharactersInRange:range withString:string];
	}
	else if(textField == apartmentTextField)
	{
		[apartment replaceCharactersInRange:range withString:string];
	}
	
	if(!self.delegate.newHouse)
	{
		NSMutableString *string = [[NSMutableString alloc] init];
		[Settings formatStreetNumber:houseNumber
						   apartment:apartment
							 topLine:string];
		self.delegate.title = string;
		[string release];
	}
	return YES;
}

@end

/******************************************************************
 *
 *   NAHHouseNotesCellController
 *
 ******************************************************************/
#pragma mark NAHHouseNotesCellController

@interface NAHHouseNotesCellController : NotAtHomeHouseViewCellController<NotesViewControllerDelegate>
{
}
@end
@implementation NAHHouseNotesCellController

- (void)notesViewControllerDone:(NotesViewController *)notesViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
    [self.delegate.house setObject:[notesViewController notes] forKey:NotAtHomeTerritoryHouseNotes];
	[[Settings sharedInstance] saveData];
	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		self.delegate.forceReload = YES;
	}
	
	[self.delegate.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [UITableViewMultilineTextCell heightForWidth:(tableView.bounds.size.width - 90) withText:[self.delegate.house objectForKey:NotAtHomeTerritoryHouseNotes]];
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
	UITableViewMultilineTextCell *cell = (UITableViewMultilineTextCell *)[tableView dequeueReusableCellWithIdentifier:@"NotesCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewMultilineTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotesCell"] autorelease];
	}
	
	NSMutableString *notes = [self.delegate.house objectForKey:NotAtHomeTerritoryHouseNotes];
	
	if([notes length] == 0)
		[cell setText:NSLocalizedString(@"Add Notes", @"Placeholder for adding notes in the Not At Home views")];
	else
		[cell setText:notes];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *notes = [self.delegate.house objectForKey:NotAtHomeTerritoryHouseNotes];
	// make the new call view 
	NotesViewController *p = [[[NotesViewController alloc] initWithNotes:notes] autorelease];
	p.delegate = self;
	p.title = NSLocalizedString(@"Notes", @"Not At Homes notes view title");
	[[self.delegate navigationController] pushViewController:p animated:YES];		
	[self.delegate retainObject:self whileViewControllerIsManaged:p];
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
}
@end
@implementation NAHHouseAttemptCellController

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

	NSDate *date = [[self.delegate.house objectForKey:NotAtHomeTerritoryHouseAttempts] objectAtIndex:indexPath.row];	
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
	DatePickerViewController *controller = [[DatePickerViewController alloc] initWithDate:[[self.delegate.house objectForKey:NotAtHomeTerritoryHouseAttempts] objectAtIndex:indexPath.row]];
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
		
		[[self.delegate.house objectForKey:NotAtHomeTerritoryHouseAttempts] removeObjectAtIndex:indexPath.row];
		
		// save the data
		// save the data
		[[Settings sharedInstance] saveData];
		
		[[self retain] autorelease];
		[self.delegate deleteDisplayRowAtIndexPath:indexPath];
	}
}

- (void)datePickerViewControllerDone:(DatePickerViewController *)datePickerViewController
{
	[[self.delegate.house objectForKey:NotAtHomeTerritoryHouseAttempts] replaceObjectAtIndex:datePickerViewController.tag withObject:datePickerViewController.date];
	[[Settings sharedInstance] saveData];
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
    [[self.delegate.house objectForKey:NotAtHomeTerritoryHouseAttempts] addObject:[datePickerViewController date]];
	[[Settings sharedInstance] saveData];
	[[self retain] autorelease];
	
	[self.delegate updateAndReload];
	[self.delegate dismissModalViewControllerAnimated:YES];
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
	if(delegate)
	{
		[delegate notAtHomeHouseViewControllerDone:self];
	}
}

- (void)navigationControlAction:(id)sender 
{
}

- (id)initWithHouse:(NSMutableDictionary *)theHouse
{
	if( (self = [super initWithStyle:UITableViewStyleGrouped]))
	{
		self.navigationItem.hidesBackButton = YES;
		self.allTextFields = [NSMutableArray array];
		if(theHouse == nil)
		{
			newHouse = YES;
			theHouse = [[[NSMutableDictionary alloc] init] autorelease];
			[theHouse setObject:[NSMutableArray arrayWithObject:[NSDate date]] forKey:NotAtHomeTerritoryHouseAttempts];
		}
		self.obtainFocus = newHouse;
		self.house = theHouse;
		if(!newHouse)
		{
			NSMutableString *houseNumber = [self.house objectForKey:NotAtHomeTerritoryHouseNumber];
			NSMutableString *apartment = [self.house objectForKey:NotAtHomeTerritoryHouseApartment];
			NSMutableString *string = [[NSMutableString alloc] init];
			[Settings formatStreetNumber:houseNumber
							   apartment:apartment
								 topLine:string];
			self.title = string;
			[string release];
		}
		self.hidesBottomBarWhenPushed = YES;
		self.editing = YES;
	}
	return self;
}

- (id)init
{
	return [self initWithHouse:nil];
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	for(UITextField *textField in self.allTextFields)
	{
		[textField resignFirstResponder];
	}
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
			NAHHouseNotesCellController *cellController = [[NAHHouseNotesCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	}

	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		sectionController.title = NSLocalizedString(@"Attempts", @"Title of the section in the Not-At-Homes house view that allows you to add/edit attempts for the house");
		[sectionController release];

		for(NSDictionary *attempt in [self.house objectForKey:NotAtHomeTerritoryHouseAttempts])
		{
			// House
			NAHHouseAttemptCellController *cellController = [[NAHHouseAttemptCellController alloc] init];
			cellController.delegate = self;
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
