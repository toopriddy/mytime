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
@private	
	BOOL obtainFocus;
}
@property (nonatomic, assign) BOOL obtainFocus;
@end
@implementation NAHStreetNameCellController
@synthesize obtainFocus;

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
	if(cell == nil)
	{
		cell = [[[UITableViewTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
		cell.textField.placeholder = NSLocalizedString(@"Street Name", @"This is the territory idetifier that is on the Not At Home->New/edit territory");
		cell.textField.returnKeyType = UIReturnKeyDone;
		cell.textField.clearButtonMode = UITextFieldViewModeAlways;
		cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	}
	NSMutableString *name = [self.delegate.street objectForKey:NotAtHomeTerritoryName];
	if(name == nil)
	{
		name = [[NSMutableString alloc] init];
		[self.delegate.street setObject:name forKey:NotAtHomeTerritoryStreetName];
		[name release];
	}
	cell.textField.text = [self.delegate.street objectForKey:NotAtHomeTerritoryStreetName];
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
}

@end


/******************************************************************
*
*   NAHStreetHouseCellController
*
******************************************************************/
#pragma mark NAHStreetHouseCellController

@interface NAHStreetHouseCellController : NotAtHomeStreetViewCellController
{
@private	
}
@end
@implementation NAHStreetHouseCellController

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
	cell.textLabel.text = [[self.delegate.street objectForKey:NotAtHomeTerritoryStreets] objectAtIndex:indexPath.row];
	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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

@end

/******************************************************************
 *
 *   NAHStreetAddHouseCellController
 *
 ******************************************************************/
#pragma mark NAHStreetAddHouseCellController

@interface NAHStreetAddHouseCellController : NotAtHomeStreetViewCellController
{
@private	
}
@end
@implementation NAHStreetAddHouseCellController

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
	[cell setValue:NSLocalizedString(@"Add House", @"button to add streets to the list of not at home streets")];
	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end


@implementation NotAtHomeStreetViewController
@synthesize street;
@synthesize delegate;
@synthesize tag;
@synthesize newStreet;

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


- (void)dealloc
{
	self.street = nil;
	
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
			// Street Name
			NAHStreetNameCellController *cellController = [[NAHStreetNameCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		{
			// Territory Date
			NAHStreetDateCellController *cellController = [[NAHStreetDateCellController alloc] init];
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

		for(NSDictionary *street in [self.street objectForKey:NotAtHomeTerritoryStreets])
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
