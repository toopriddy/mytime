//
//  NotAtHomeStreetDetailViewController.m
//  MyTime
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "NotAtHomeStreetViewController.h"
#import "UITableViewTextFieldCell.h"
#import "NotesViewController.h"
#import "DatePickerViewController.h"
#import "UITableViewTitleAndValueCell.h"
#import "UITableViewMultilineTextCell.h"
#import "NotAtHomeHouseCell.h"
#import "NotAtHomeHouseViewController.h"
#import "Settings.h"
#import <AddressBookUI/AddressBookUI.h>
#import "PSLocalization.h"

@interface NotAtHomeStreetViewCellController : NSObject<TableViewCellController>
{
	NotAtHomeStreetViewController *delegate;
}
@property (nonatomic, assign) NotAtHomeStreetViewController *delegate;
@end
@implementation NotAtHomeStreetViewCellController
@synthesize delegate;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}
@end


/******************************************************************
 *
 *   NAHStreetNameCellController
 *
 ******************************************************************/
#pragma mark NAHStreetNameCellController

@interface NAHStreetNameCellController : NotAtHomeStreetViewCellController<UITableViewTextFieldCellDelegate>
{
	UITextField *textField;
}
@property (nonatomic, retain) UITextField *textField;
@end
@implementation NAHStreetNameCellController
@synthesize textField;

- (void)dealloc
{
	if(self.textField)
	{
		[self.delegate.allTextFields removeObject:self.textField];
		self.textField = nil;
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
	if(self.textField)
	{
		[self.delegate.allTextFields removeObject:self.textField];
		self.textField = nil;
	}
	NSString *commonIdentifier = @"StreetNameCell";
	UITableViewTextFieldCell *cell = (UITableViewTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
		cell.textField.placeholder = NSLocalizedString(@"Street Name", @"This is the territory idetifier that is on the Not At Home->New/edit territory");
		cell.textField.returnKeyType = UIReturnKeyDone;
		cell.textField.clearButtonMode = UITextFieldViewModeAlways;
		cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	}
	NSMutableString *name = [self.delegate.street objectForKey:NotAtHomeTerritoryStreetName];
	if(name == nil)
	{
		name = [[NSMutableString alloc] init];
		[self.delegate.street setObject:name forKey:NotAtHomeTerritoryStreetName];
		[name release];
	}
	self.textField = cell.textField;
	[self.delegate.allTextFields addObject:self.textField];
	cell.textField.text = name;
	cell.delegate = self;
	if(self.delegate.obtainFocus)
	{
		[cell.textField performSelector:@selector(becomeFirstResponder)
							 withObject:nil
							 afterDelay:0.0000001];
		self.delegate.obtainFocus = NO;
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
	NSMutableString *name = [self.delegate.street objectForKey:NotAtHomeTerritoryStreetName];
	[name replaceCharactersInRange:range withString:string];
	if(!self.delegate.newStreet)
		self.delegate.title = name;
	return YES;
}

@end


/******************************************************************
 *
 *   NAHStreetDateCellController
 *
 ******************************************************************/
#pragma mark NAHStreetDateCellController

@interface NAHStreetDateCellController : NotAtHomeStreetViewCellController<DatePickerViewControllerDelegate>
{
}
@end
@implementation NAHStreetDateCellController

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
	NSString *identifier = @"ChangeDateCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	NSDate *date = [self.delegate.street objectForKey:NotAtHomeTerritoryStreetDate];	
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
	DEBUG(NSLog(@"changeDateOfReturnVisitAtIndex: %d", index);)
	
	// make the new call view 
	DatePickerViewController *p = [[[DatePickerViewController alloc] initWithDate:[self.delegate.street objectForKey:NotAtHomeTerritoryStreetDate]] autorelease];
	p.delegate = self;
	[[self.delegate navigationController] pushViewController:p animated:YES];		
	[self.delegate retainObject:self whileViewControllerIsManaged:p];
}

- (void)datePickerViewControllerDone:(DatePickerViewController *)datePickerViewController
{
    [self.delegate.street setObject:[datePickerViewController date] forKey:NotAtHomeTerritoryStreetDate];
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
	[[self.delegate navigationController] popViewControllerAnimated:YES];
}

@end

/******************************************************************
 *
 *   NAHStreetNotesCellController
 *
 ******************************************************************/
#pragma mark NAHStreetNotesCellController

@interface NAHStreetNotesCellController : NotAtHomeStreetViewCellController<NotesViewControllerDelegate>
{
}
@end
@implementation NAHStreetNotesCellController

- (void)notesViewControllerDone:(NotesViewController *)notesViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
    [self.delegate.street setObject:[notesViewController notes] forKey:NotAtHomeTerritoryStreetNotes];
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
	return [UITableViewMultilineTextCell heightForWidth:(tableView.bounds.size.width - 90) withText:[self.delegate.street objectForKey:NotAtHomeTerritoryStreetNotes]];
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
	
	NSMutableString *notes = [self.delegate.street objectForKey:NotAtHomeTerritoryStreetNotes];
	
	if([notes length] == 0)
		[cell setText:NSLocalizedString(@"Add Notes", @"Placeholder for adding notes in the Not At Home views")];
	else
		[cell setText:notes];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *notes = [self.delegate.street objectForKey:NotAtHomeTerritoryStreetNotes];
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
*   NAHStreetHouseCellController
*
******************************************************************/
#pragma mark NAHStreetHouseCellController

@interface NAHStreetHouseCellController : UIViewController<TableViewCellController, NotAtHomeHouseCellDelegate, NotAtHomeHouseViewControllerDelegate>
{
	NotAtHomeStreetViewController *delegate;
	NSMutableDictionary *house;
}
@property (nonatomic, assign) NotAtHomeStreetViewController *delegate;
@property (nonatomic, retain) NSMutableDictionary *house;
@end
@implementation NAHStreetHouseCellController
@synthesize delegate;
@synthesize house;

- (void)dealloc
{
	self.house = nil;
	
	[super dealloc];
}

- (void)notAtHomeHouseCellAttemptsChanged:(NotAtHomeHouseCell *)cell
{
	NSMutableArray *attempts = [self.house objectForKey:NotAtHomeTerritoryHouseAttempts];
	if(attempts.count > cell.attempts)
	{
		[attempts removeLastObject];
	}
	else
	{
		[attempts addObject:[NSDate date]];
	}

	[[Settings sharedInstance] saveData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"NotAtHomeHouseCell";
	NotAtHomeHouseCell *cell = (NotAtHomeHouseCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		// Create a temporary UIViewController to instantiate the custom cell.
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"NotAtHomeHouseCell" bundle:nil];
		// Grab a pointer to the custom cell.
        cell = (NotAtHomeHouseCell *)temporaryController.view;
		// Release the temporary UIViewController.
        [temporaryController autorelease];
	}
	else
	{
		NSLog(@"got here");
	}

	
	self.house = [[self.delegate.street objectForKey:NotAtHomeTerritoryHouses] objectAtIndex:indexPath.row];
	
	cell.delegate = self;
	cell.attempts = [[self.house objectForKey:NotAtHomeTerritoryHouseAttempts] count];
	NSMutableString *string = [[NSMutableString alloc] init];
	[Settings formatStreetNumber:[self.house objectForKey:NotAtHomeTerritoryHouseNumber] 
					   apartment:[self.house objectForKey:NotAtHomeTerritoryHouseApartment] 
						 topLine:string];
	cell.houseLabel.text = string;
	[string release];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NotAtHomeHouseViewController *controller = [[NotAtHomeHouseViewController alloc] initWithHouse:[[self.delegate.street objectForKey:NotAtHomeTerritoryHouses] objectAtIndex:indexPath.row]];
	controller.delegate = self;
	[self.delegate.navigationController pushViewController:controller animated:YES];
	[self.delegate retainObject:self whileViewControllerIsManaged:controller];
	[controller release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		DEBUG(NSLog(@"deleteReturnVisitAtIndex: %@", indexPath);)
		
		[[self.delegate.street objectForKey:NotAtHomeTerritoryHouses] removeObjectAtIndex:indexPath.row];
		
		// save the data
		[[Settings sharedInstance] saveData];
		
		[[self retain] autorelease];
		[self.delegate deleteDisplayRowAtIndexPath:indexPath];
	}
}

- (void)notAtHomeHouseViewControllerDone:(NotAtHomeHouseViewController *)notAtHomeHouseViewController
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
@end

/******************************************************************
 *
 *   NAHStreetAddHouseCellController
 *
 ******************************************************************/
#pragma mark NAHStreetAddHouseCellController

@interface NAHStreetAddHouseCellController : NotAtHomeStreetViewCellController <NotAtHomeHouseViewControllerDelegate>
{
@private	
	int section;
}
@end
@implementation NAHStreetAddHouseCellController

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleInsert;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"AddHouseCell";
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	[cell setValue:NSLocalizedString(@"Add House", @"button to add streets to the list of not at home streets")];
	return cell;
}

- (void)notAtHomeDetailCanceled
{
	[self.delegate dismissModalViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NotAtHomeHouseViewController *controller = [[[NotAtHomeHouseViewController alloc] init] autorelease];
	controller.delegate = self;

	section = indexPath.section;
	
	// push the element view controller onto the navigation stack to display it
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];

	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");

	controller.title = NSLocalizedString(@"Add House", @"Title for the a new house in the Not At Home view");
	[self.delegate presentModalViewController:navigationController animated:YES];
	[temporaryBarButtonItem setAction:@selector(notAtHomeDetailCanceled)];
	[temporaryBarButtonItem setTarget:self];
	controller.navigationItem.leftBarButtonItem = temporaryBarButtonItem;

	[self.delegate retainObject:self whileViewControllerIsManaged:controller];
}

- (void)notAtHomeHouseViewControllerDone:(NotAtHomeHouseViewController *)notAtHomeHouseViewController
{
	NSMutableArray *houses = [self.delegate.street objectForKey:NotAtHomeTerritoryHouses];
	if(houses == nil)
	{
		houses = [[NSMutableArray alloc] init];
		[self.delegate.street setObject:houses forKey:NotAtHomeTerritoryHouses];
		[houses release];
	}
	[houses addObject:notAtHomeHouseViewController.house];
	[[Settings sharedInstance] saveData];
	
	NAHStreetHouseCellController *cellController = [[NAHStreetHouseCellController alloc] init];
	cellController.delegate = self.delegate;
	[[[self.delegate.sectionControllers objectAtIndex:section] cellControllers] insertObject:cellController atIndex:([houses count] - 1)];
	[cellController release];
	
	[self.delegate dismissModalViewControllerAnimated:YES];
	[self.delegate updateWithoutReload];
}	
@end


@implementation NotAtHomeStreetViewController
@synthesize street;
@synthesize delegate;
@synthesize tag;
@synthesize newStreet;
@synthesize allTextFields;
@synthesize obtainFocus;

- (void)navigationControlDone:(id)sender 
{
	VERBOSE(NSLog(@"navigationControlDone:");)
	if(delegate)
	{
		[delegate notAtHomeStreetViewControllerDone:self];
	}
}

- (void)navigationControlAction:(id)sender 
{
}

- (id)initWithStreet:(NSMutableDictionary *)theStreet
{
	if( (self = [super initWithStyle:UITableViewStyleGrouped]))
	{
		self.navigationItem.hidesBackButton = YES;
		self.obtainFocus = YES;
		self.allTextFields = [NSMutableArray array];
		if(theStreet == nil)
		{
			newStreet = YES;
			theStreet = [[[NSMutableDictionary alloc] init] autorelease];
			[theStreet setObject:[NSDate date] forKey:NotAtHomeTerritoryStreetDate];
		}
		self.street = theStreet;
		if(!newStreet)
		{
			self.title = [theStreet objectForKey:NotAtHomeTerritoryName];
		}
		self.hidesBottomBarWhenPushed = YES;
		self.editing = YES;
	}
	return self;
}

- (id)init
{
	return [self initWithStreet:nil];
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
	self.street = nil;
	self.allTextFields = nil;
	
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
			// Street Name
			NAHStreetNameCellController *cellController = [[NAHStreetNameCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		{
			// Street Date
			NAHStreetDateCellController *cellController = [[NAHStreetDateCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}

		{
			// Street Notes
			NAHStreetNotesCellController *cellController = [[NAHStreetNotesCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
	}

	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		sectionController.title = NSLocalizedString(@"Houses", @"Title of the section in the Not-At-Homes street view that allows you to add/edit houses in the street");
		[sectionController release];

		for(NSDictionary *house in [self.street objectForKey:NotAtHomeTerritoryHouses])
		{
			// House
			NAHStreetHouseCellController *cellController = [[NAHStreetHouseCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		{
			// Add House
			NAHStreetAddHouseCellController *cellController = [[NAHStreetAddHouseCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
	}
}


@end
