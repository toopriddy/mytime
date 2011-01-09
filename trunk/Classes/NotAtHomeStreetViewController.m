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

#import "NotAtHomeStreetViewController.h"
#import "UITableViewTextFieldCell.h"
#import "NotesViewController.h"
#import "DatePickerViewController.h"
#import "UITableViewTitleAndValueCell.h"
#import "UITableViewMultilineTextCell.h"
#import "NotAtHomeHouseCell.h"
#import "NotAtHomeHouseViewController.h"
#import "MTTerritoryHouse.h"
#import <AddressBookUI/AddressBookUI.h>
#import "PSTextFieldCellController.h"
#import "PSDateCellController.h"
#import "PSTextViewCellController.h"
#import "MTTerritoryHouseAttempt.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "MTCall.h"
#import "PSLocalization.h"

@interface NotAtHomeStreetViewController ()
- (void)resignAllFirstResponders;
@end

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
*   NAHStreetHouseCellController
*
******************************************************************/
#pragma mark NAHStreetHouseCellController

@interface NAHStreetHouseCellController : UIViewController<TableViewCellController, NotAtHomeHouseCellDelegate, NotAtHomeHouseViewControllerDelegate>
{
	NotAtHomeStreetViewController *delegate;
	MTTerritoryHouse *house;
	NSIndexPath *savedIndexPath;
}
@property (nonatomic, assign) NotAtHomeStreetViewController *delegate;
@property (nonatomic, retain) MTTerritoryHouse *house;
@property (nonatomic, copy) NSIndexPath *savedIndexPath;
@end
@implementation NAHStreetHouseCellController
@synthesize delegate;
@synthesize house;
@synthesize savedIndexPath;

- (void)dealloc
{
	self.house = nil;
	self.savedIndexPath = nil;
	
	[super dealloc];
}

- (void)notAtHomeHouseCellAttemptsChanged:(NotAtHomeHouseCell *)cell
{
	int count = [self.house.attempts count];
	if(count > cell.attempts)
	{
		MTTerritoryHouseAttempt *attempt = [[self.house.managedObjectContext fetchObjectsForEntityName:[MTTerritoryHouseAttempt entityName]
																					 propertiesToFetch:nil 
																				   withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:YES], nil]
																						 withPredicate:@"house == %@", self.house] lastObject];
		if(attempt)
		{
			[attempt.managedObjectContext deleteObject:attempt];
		}
	}
	else
	{
		MTTerritoryHouseAttempt *attempt = [MTTerritoryHouseAttempt insertInManagedObjectContext:self.house.managedObjectContext];
		attempt.house = self.house;
	}
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

	
	cell.delegate = self;
	cell.attempts = self.house.attempts.count;
	cell.houseLabel.text = [MTCall topLineOfAddressWithHouseNumber:self.house.number apartmentNumber:self.house.apartment street:nil];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.delegate resignAllFirstResponders];

	NotAtHomeHouseViewController *controller = [[NotAtHomeHouseViewController alloc] initWithHouse:self.house newHouse:NO];
	controller.delegate = self;
	self.savedIndexPath = indexPath;
	[self.delegate.navigationController pushViewController:controller animated:YES];
	[self.delegate retainObject:self whileViewControllerIsManaged:controller];
	[controller release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		DEBUG(NSLog(@"deleteReturnVisitAtIndex: %@", indexPath);)
		
		[self.house.managedObjectContext deleteObject:self.house];
		NSError *error = nil;
		if(![self.delegate.street.managedObjectContext save:&error])
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		
		[[self retain] autorelease];
		[self.delegate deleteDisplayRowAtIndexPath:indexPath];
	}
}

- (void)notAtHomeHouseViewControllerDeleteHouse:(NotAtHomeHouseViewController *)notAtHomeHouseViewController
{
	[self.house.managedObjectContext deleteObject:self.house];
	
	// save the data
	NSError *error = nil;
	if(![self.delegate.street.managedObjectContext save:&error])
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	
	[[self retain] autorelease];
	[self.delegate deleteDisplayRowAtIndexPath:self.savedIndexPath];
	[self.delegate.navigationController popToViewController:self.delegate animated:YES];
}

- (void)notAtHomeHouseViewControllerDone:(NotAtHomeHouseViewController *)notAtHomeHouseViewController
{
	NSError *error = nil;
	if(![self.delegate.street.managedObjectContext save:&error])
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}

	[self.delegate.navigationController popViewControllerAnimated:YES];
	[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.savedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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
	MTTerritoryHouse *temporaryHouse;
	NSIndexPath *savedIndexPath;
}
@property (nonatomic, retain) MTTerritoryHouse *temporaryHouse;
@property (nonatomic, copy) NSIndexPath *savedIndexPath;
@end
@implementation NAHStreetAddHouseCellController
@synthesize temporaryHouse;
@synthesize savedIndexPath;

- (void)dealloc
{
	self.temporaryHouse = nil;
	self.savedIndexPath = nil;
	[super dealloc];
}

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
	self.temporaryHouse = nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.delegate resignAllFirstResponders];

	MTTerritoryHouse *house = [MTTerritoryHouse insertInManagedObjectContext:self.delegate.street.managedObjectContext];
	house.street = self.delegate.street;
	self.temporaryHouse = house;
	self.savedIndexPath = indexPath;
	// add an attempt now
	[house addAttemptsObject:[MTTerritoryHouseAttempt insertInManagedObjectContext:house.managedObjectContext]];
	
	NotAtHomeHouseViewController *controller = [[[NotAtHomeHouseViewController alloc] initWithHouse:house newHouse:YES] autorelease];
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
#warning fix me
	NSError *error = nil;
	if(![self.delegate.street.managedObjectContext save:&error])
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
#if 0
	NAHStreetHouseCellController *cellController = [[NAHStreetHouseCellController alloc] init];
	cellController.delegate = self.delegate;
	[[[self.delegate.sectionControllers objectAtIndex:section] cellControllers] insertObject:cellController atIndex:([houses count] - 1)];
	[cellController release];
#endif	
	[self.delegate dismissModalViewControllerAnimated:YES];
	[self.delegate updateAndReload];
}	

- (void)notAtHomeHouseViewControllerDeleteHouse:(NotAtHomeHouseViewController *)notAtHomeHouseViewController
{
	NSError *error = nil;
	if(![self.delegate.street.managedObjectContext save:&error])
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	[self.delegate dismissModalViewControllerAnimated:YES];
}

@end


@implementation NotAtHomeStreetViewController
@synthesize street;
@synthesize delegate;
@synthesize tag;
@synthesize newStreet = newStreet_;
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

- (id)initWithStreet:(MTTerritoryStreet *)theStreet newStreet:(BOOL)newStreet
{
	if( (self = [super initWithStyle:UITableViewStyleGrouped]))
	{
		self.navigationItem.hidesBackButton = YES;
		self.allTextFields = [NSMutableSet set];
		self.street = theStreet;
		self.obtainFocus = newStreet;
		if(!newStreet)
		{
			self.title = self.street.name;
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
	self.street = nil;
	self.allTextFields = nil;
	
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
			// Street Name
			PSTextFieldCellController *cellController = [[[PSTextFieldCellController alloc] init] autorelease];
			cellController.model = self.street;
			cellController.modelPath = @"name";
			cellController.placeholder = NSLocalizedString(@"Street Name", @"This is the territory idetifier that is on the Territories->New/edit territory");
			cellController.returnKeyType = UIReturnKeyDone;
			cellController.clearButtonMode = UITextFieldViewModeAlways;
			cellController.autocapitalizationType = UITextAutocapitalizationTypeWords;
			cellController.selectionStyle = UITableViewCellSelectionStyleNone;
			cellController.selectNextRowResponderIncrement = 1;
			cellController.obtainFocus = self.obtainFocus;
			cellController.allTextFields = self.allTextFields;
			self.obtainFocus = NO;
			[sectionController.cellControllers addObject:cellController];
		}
		
		{
			// Street Date
			PSDateCellController *cellController = [[[PSDateCellController alloc] init] autorelease];
			cellController.model = self.street;
			cellController.modelPath = @"date";
			if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
			{
				[cellController setDateFormat:@"EEE, d/M/yyy h:mma"];
			}
			else
			{
				[cellController setDateFormat:NSLocalizedString(@"EEE, M/d/yyy h:mma", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
			}
			
			[self addCellController:cellController toSection:sectionController];
		}

		{
			// Street Notes
			PSTextViewCellController *cellController = [[[PSTextViewCellController alloc] init] autorelease];
			cellController.model = self.street;
			cellController.modelPath = @"notes";
			cellController.placeholder = NSLocalizedString(@"Add Notes", @"Placeholder for adding notes in the Not At Home views");
			cellController.title = NSLocalizedString(@"Notes", @"Not At Homes notes view title");
			[self addCellController:cellController toSection:sectionController];
		}
		
	}

	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		sectionController.title = NSLocalizedString(@"Houses", @"Title of the section in the Not-At-Homes street view that allows you to add/edit houses in the street");
		[sectionController release];

		NSArray *houses = [street.managedObjectContext fetchObjectsForEntityName:[MTTerritoryHouse entityName]
															   propertiesToFetch:[NSArray arrayWithObjects:@"number", @"apartment", @"date", nil] 
															 withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:YES], nil]
																   withPredicate:@"street == %@", street];
		for(MTTerritoryHouse *house in houses)
		{
			// House
			NAHStreetHouseCellController *cellController = [[NAHStreetHouseCellController alloc] init];
			cellController.delegate = self;
			cellController.house = house;
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
