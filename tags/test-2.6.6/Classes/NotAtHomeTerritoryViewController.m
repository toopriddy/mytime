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
#import "UITableViewMultilineTextCell.h"
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
	SelectRowNextResponder *nextRowResponder;
	UITextField *textField;
}
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) SelectRowNextResponder *nextRowResponder;
@end
@implementation NAHTerritoryNameCellController
@synthesize nextRowResponder;
@synthesize textField;

- (void)dealloc
{
	self.nextRowResponder = nil;
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
	NSString *commonIdentifier = @"NameCell";
	UITableViewTextFieldCell *cell = (UITableViewTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(self.nextRowResponder == nil)
	{
		self.nextRowResponder = [[[SelectRowNextResponder alloc] initWithTable:tableView indexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section]] autorelease];
	}
	if(cell == nil)
	{
		cell = [[[UITableViewTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
		cell.textField.placeholder = NSLocalizedString(@"Territory Name/Number", @"This is the territory idetifier that is on the Not At Home->New/edit territory");
		cell.nextKeyboardResponder = self.nextRowResponder;
		cell.textField.returnKeyType = UIReturnKeyNext;
		cell.textField.clearButtonMode = UITextFieldViewModeAlways;
		cell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	}
	NSMutableString *name = [self.delegate.territory objectForKey:NotAtHomeTerritoryName];
	if(name == nil)
	{
		name = [[NSMutableString alloc] init];
		[self.delegate.territory setObject:name forKey:NotAtHomeTerritoryName];
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
	UITextField *textField;
}
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) SelectRowNextResponder *nextRowResponder;
@end
@implementation NAHTerritoryCityCellController
@synthesize nextRowResponder;
@synthesize textField;

- (void)dealloc
{
	self.nextRowResponder = nil;
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
	NSString *commonIdentifier = @"CityCell";
	if(self.textField)
	{
		[self.delegate.allTextFields removeObject:self.textField];
		self.textField = nil;
	}
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
	self.textField = cell.textField;
	[self.delegate.allTextFields addObject:self.textField];
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
	UITextField *textField;
}
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) SelectRowNextResponder *nextRowResponder;
@end
@implementation NAHTerritoryStateCellController
@synthesize nextRowResponder;
@synthesize textField;

- (void)dealloc
{
	self.nextRowResponder = nil;
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
	NSString *commonIdentifier = @"StateCell";
	if(self.textField)
	{
		[self.delegate.allTextFields removeObject:self.textField];
		self.textField = nil;
	}
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

		// if the localization does not capitalize the state, then just leave it default to capitalize the first letter
		if([NSLocalizedStringWithDefaultValue(@"State in all caps", @"", [NSBundle mainBundle], @"1", @"Set this to 1 if your country abbreviates the state in all capital letters, otherwise set this to 0") isEqualToString:@"1"])
		{
			cell.textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
			cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
		}
	}
	self.textField = cell.textField;
	[self.delegate.allTextFields addObject:self.textField];
	
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
 *   NAHTerritoryNotesCellController
 *
 ******************************************************************/
#pragma mark NAHTerritoryNotesCellController

@interface NAHTerritoryNotesCellController : NotAtHomeTerritoryViewCellController<NotesViewControllerDelegate>
{
}
@end
@implementation NAHTerritoryNotesCellController

- (void)notesViewControllerDone:(NotesViewController *)notesViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
    [self.delegate.territory setObject:[notesViewController notes] forKey:NotAtHomeTerritoryNotes];
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
	return [UITableViewMultilineTextCell heightForWidth:(tableView.bounds.size.width - 90) withText:[self.delegate.territory objectForKey:NotAtHomeTerritoryNotes]];
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
	
	NSMutableString *notes = [self.delegate.territory objectForKey:NotAtHomeTerritoryNotes];
	
	if([notes length] == 0)
		[cell setText:NSLocalizedString(@"Add Notes", @"Placeholder for adding notes in the Not At Home views")];
	else
		[cell setText:notes];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *notes = [self.delegate.territory objectForKey:NotAtHomeTerritoryNotes];
	// make the new call view 
	NotesViewController *p = [[[NotesViewController alloc] initWithNotes:notes] autorelease];
	p.title = NSLocalizedString(@"Notes", @"Not At Homes notes view title");
	p.delegate = self;
	[[self.delegate navigationController] pushViewController:p animated:YES];		
	[self.delegate retainObject:self whileViewControllerIsManaged:p];
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
}
@end
@implementation NAHTerritoryAddStreetCellController

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleInsert;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"NewStreetCell";
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	[cell setValue:NSLocalizedString(@"Add Street", @"button to add streets to the list of not at home streets")];
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

	section = indexPath.section;

	// push the element view controller onto the navigation stack to display it
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
	
	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");
	
	controller.title = NSLocalizedString(@"Add Street", @"Title for the a new street in the Not At Home view");
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
	[cellController release];
	
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
@synthesize allTextFields;
@synthesize obtainFocus;

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
		
		[self.allTextFields addObject:owner];
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

/******************************************************************
 *
 *   ACTION SHEET DELEGATE FUNCTIONS
 *
 ******************************************************************/
#pragma mark ActionSheet Delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
	if(deleteAfterEmailing && result != MFMailComposeResultCancelled)
	{
		[delegate notAtHomeTerritoryViewController:self deleteTerritory:self.territory];
		[self.navigationController popViewControllerAnimated:YES];
	}
}


- (BOOL)sendEmail
{
	MFMailComposeViewController *mailView = [[[MFMailComposeViewController alloc] init] autorelease];
	[mailView setSubject:NSLocalizedString(@"MyTime Not At Home Territory, open this on your iPhone/iTouch", @"Subject text for the email that is sent for sending the details of a call to another witness")];
	
	NSMutableString *string = [[NSMutableString alloc] initWithString:@"<html><body>"];
	[string appendString:NSLocalizedString(@"This not at home territory has been turned over to you, here are the details.  If you are a MyTime user, please view this email on your iPhone/iTouch and scroll all the way down to the end of the email and click on the link to import this not at home territory into MyTime.<br><br>", @"This is the first part of the body of the email message that is sent to a user when you click on a Not At Home Territory and then click on the action button in the upper left corner and select transfer or email details")];
	[string appendString:emailFormattedStringForNotAtHomeTerritory(self.territory)];
	[string appendString:NSLocalizedString(@"You are able to import this not at home territory into MyTime if you click on the link below while viewing this email from your iPhone/iTouch.  Please make sure that at the end of this email there is a \"VERIFICATION CHECK:\" right after the link, it verifies that all data is contained within this email<br>", @"This is the second part of the body of the email message that is sent to a user when you click on a Not At Home Territory and then click on the action button in the upper left corner and select transfer or email details")];
	
	// now add the url that will allow importing
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.territory];
	[string appendString:@"<a href=\"mytime://mytime/addNotAtHomeTerritory?"];
	int length = data.length;
	unsigned char *bytes = (unsigned char *)data.bytes;
	for(int i = 0; i < length; ++i)
	{
		[string appendFormat:@"%02X", *bytes++];
	}
	[string appendString:@"\">"];
	[string appendString:NSLocalizedString(@"Click on this link from your iPhone/iTouch", @"This is the text that appears in the link of the email when you are transferring a not at home territory to another witness.  this is the link that they press to open MyTime")];
	[string appendString:@"</a><br><br>"];
	[string appendString:NSLocalizedString(@"VERIFICATION CHECK: all data was contained in this email", @"This is a very important message that is at the end of the email used to transfer a not at home territory to another witness or if you are just emailing a backup to yourself, it verifies that all of the data is contained in the email, if it is not there then all of the data is not in the email and something bad happened :(")];
	
	[string appendString:@"</body></html>"];
	[mailView setMessageBody:string isHTML:YES];
	[string release];
	mailView.mailComposeDelegate = self;

	NSString *emailAddress = [self ownerEmailAddress];
	if(emailAddress && emailAddress.length)
	{
		[mailView setToRecipients:[emailAddress componentsSeparatedByString:@" "]];
	}
	
	[self.navigationController presentModalViewController:mailView animated:YES];
	
	return [MFMailComposeViewController canSendMail];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{
	VERBOSE(NSLog(@"alertSheet: button:%d", button);)
	//	[sheet dismissAnimated:YES];
	deleteAfterEmailing = NO;
	switch(button)
	{
			//transfer
		case 0:
		{
			deleteAfterEmailing = YES;
			[self sendEmail];
			break;
		}
			// email
		case 1:
		{
			[self sendEmail];
			break;
		}
	}
}


- (void)navigationControlAction:(id)sender 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"You can transfer this not at home territory to someone else. Transferring will delete this territory from your data or just emailing the details will keep the data. The witness who gets this email will be able to click on a link in the email and add the territory to MyTime.", @"This message is displayed when the user clicks on a territory and clicks on the \"Action\" button at the top left of the screen")
															 delegate:self
												    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
											   destructiveButtonTitle:NSLocalizedString(@"Transfer, and Delete", @"Transferr this not at home territory to another MyTime user and delete it off of this iphone, but keep the data")
												    otherButtonTitles:NSLocalizedString(@"Email Details", @"Email the not at home territory details to another MyTime user"), nil] autorelease];
	
	alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[alertSheet showInView:self.view];
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
		self.obtainFocus = newTerritory;
		self.allTextFields = [NSMutableArray array];
		
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
	self.allTextFields = nil;
	self.owner = nil;
	self.territory = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
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
			// Territory Notes
			NAHTerritoryNotesCellController *cellController = [[NAHTerritoryNotesCellController alloc] init];
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
