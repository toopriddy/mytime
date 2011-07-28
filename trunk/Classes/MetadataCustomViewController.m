//
//  MetadataCustomViewController.m
//  MyTime
//
//  Created by Brent Priddy on 10/22/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "MetadataCustomViewController.h"
#import "MetadataEditorViewController.h"
#import "UITableViewTextFieldCell.h"
#import "PublicationViewController.h"
#import "UITableViewTextFieldCell.h"
#import "MTMultipleChoice.h"
#import "MTAdditionalInformation.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "MyTimeAppDelegate.h"
#import "MTSorter.h"
#import "PSLocalization.h"

#include "PSRemoveLocalizedString.h"
static MetadataInformation commonInformation[] = {
	{NSLocalizedString(@"Email", @"Call Metadata"), EMAIL}
,	{NSLocalizedString(@"Phone", @"Call Metadata"), PHONE}
,	{NSLocalizedString(@"Multiple Choice", @"Call Metadata"), CHOICE}
,	{NSLocalizedString(@"String", @"Call Metadata"), STRING}
,	{NSLocalizedString(@"Notes", @"Call Metadata"), NOTES}
,	{NSLocalizedString(@"Number", @"Call Metadata"), NUMBER}
,	{NSLocalizedString(@"Date/Time", @"Call Metadata"), DATE}
,	{NSLocalizedString(@"YES/NO Switch", @"Call Metadata"), SWITCH}
,	{NSLocalizedString(@"URL", @"Call Metadata"), URL}
};
#include "PSAddLocalizedString.h"


NSString *localizedNameForMetadataType(MetadataType type)
{
	for(int i = 0; i < LAST_METADATA_TYPE; i++)
	{
		if(commonInformation[i].type == type)
		{
			return [[NSBundle mainBundle] localizedStringForKey:commonInformation[i].name value:commonInformation[i].name table:nil];
		}
	}
	return nil;		   
}


@interface MetadataCustomViewController ()
@property (nonatomic, assign) BOOL nameNeedsFocus;
@property (nonatomic, assign) int selected;
@property (nonatomic, assign) int startedWithSelected;
- (void)save;
@end


@interface MetadataCustomViewCellController : NSObject<TableViewCellController>
{
	MetadataCustomViewController *delegate;
}
@property (nonatomic, assign) MetadataCustomViewController *delegate;
@end
@implementation MetadataCustomViewCellController
@synthesize delegate;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}
@end

@interface MetadataGenericTableViewCellController : NSObject<TableViewCellController>
{
	GenericTableViewController *delegate;
}
@property (nonatomic, assign) GenericTableViewController *delegate;
@end
@implementation MetadataGenericTableViewCellController
@synthesize delegate;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}
@end


/******************************************************************
 *
 *   NAME
 *
 ******************************************************************/
#pragma mark MetadataNameCellController
@interface MetadataNameCellController : MetadataCustomViewCellController<UITableViewTextFieldCellDelegate>
{
	NSMutableString *name;
}
@property (nonatomic, retain) NSMutableString *name;
@end
@implementation MetadataNameCellController
@synthesize name;

- (void)dealloc
{
	self.name = nil;
	
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
	UITableViewTextFieldCell *cell = (UITableViewTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:@"NameCell"];
	if(cell == nil)
	{
		UITextField *textField = [[[UITextField alloc] init] autorelease];
		cell = [[[UITableViewTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault textField:textField reuseIdentifier:@"NameCell"] autorelease];
		textField.placeholder = NSLocalizedString(@"Enter Name Here", @"Custom Information Placeholder before the user enters in what they want to call this field, like 'Son's name' or whatever");
		textField.keyboardType = UIKeyboardTypeDefault;
		textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	}
	cell.textField.text = self.name;
	cell.delegate = self;
	cell.observeEditing = YES;
	
	if(self.delegate.nameNeedsFocus)
	{
		self.delegate.nameNeedsFocus = NO;
		[cell.textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];
	}

	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewTextFieldCell *cell = (UITableViewTextFieldCell *)[tableView cellForRowAtIndexPath:indexPath];
	[cell.textField becomeFirstResponder];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)tableViewTextFieldCell:(UITableViewTextFieldCell *)cell shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	[self.name replaceCharactersInRange:range withString:string];
	self.delegate.name = self.name;

	self.delegate.navigationItem.rightBarButtonItem.enabled = self.delegate.selected >= 0 && self.name.length;
	return YES;
}

@end

/******************************************************************
 *
 *   CHOICE SECTION
 *
 ******************************************************************/
#pragma mark MultipleChoiceMetadataSectionController
@interface MultipleChoiceMetadataSectionController : GenericTableViewSectionController
{
	MetadataCustomViewController *delegate;
}
@property (nonatomic, assign) MetadataCustomViewController *delegate;
@end
@implementation MultipleChoiceMetadataSectionController
@synthesize delegate;

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return NSLocalizedString(@"Multiple Choice", @"title that appears in the Call->Edit->Add Additional Information->Edit->Add Custom->Multiple Choice type section");
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return NSLocalizedString(@"Enter the multiple choice values here", @"text that appears in the Call->Edit->Add Additional Information->Edit->Add Custom->Multiple Choice type area so that you can add values to your multiple choice type");
}

- (BOOL)isViewableWhenEditing
{
	return self.delegate.selected >= 0 && commonInformation[self.delegate.selected].type == CHOICE;
}

@end





/******************************************************************
 *
 *   CHOICE
 *
 ******************************************************************/
#pragma mark MultipleChoiceMetadataValueCellController
@interface MultipleChoiceMetadataValueCellController : MetadataGenericTableViewCellController <MetadataEditorViewControllerDelegate>
{
	MTMultipleChoice *choice;
	MTAdditionalInformationType *type;
	NSObject<MultipleChoiceMetadataValueCellControllerDelegate> *metadataDelegate;
}
@property (nonatomic, retain) MTMultipleChoice *choice;
@property (nonatomic, retain) MTAdditionalInformationType *type;
@property (nonatomic, assign) NSObject<MultipleChoiceMetadataValueCellControllerDelegate> *metadataDelegate;
@end
@implementation MultipleChoiceMetadataValueCellController
@synthesize choice;
@synthesize type;
@synthesize metadataDelegate;

- (void)dealloc
{
	self.choice = nil;
	self.type = nil;
	[super dealloc];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	// move the row
	NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[type.multipleChoices sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES]]]];
	MTMultipleChoice *movedChoice = [[sortedArray objectAtIndex:fromIndexPath.row] retain];
	[sortedArray removeObjectAtIndex:fromIndexPath.row];
	[sortedArray insertObject:movedChoice atIndex:toIndexPath.row];
	[movedChoice release];
	
	int i = 0;
	for(MTMultipleChoice *entry in sortedArray)
	{
		entry.orderValue = i++;
	}
	[self.type.managedObjectContext processPendingChanges];
	
	// move the cellController
	GenericTableViewSectionController *fromSectionController = [self.delegate.displaySectionControllers objectAtIndex:fromIndexPath.section];
	GenericTableViewSectionController *toSectionController = [self.delegate.displaySectionControllers objectAtIndex:toIndexPath.section];
	NSObject *cellController = [[fromSectionController.displayCellControllers objectAtIndex:fromIndexPath.row] retain];
	[fromSectionController.displayCellControllers removeObjectAtIndex:fromIndexPath.row];
	[toSectionController.displayCellControllers insertObject:cellController atIndex:toIndexPath.row];
	[cellController release];
	
	// move the cellController in the displayList (the main list and the display list are the same)
	cellController = [[fromSectionController.cellControllers objectAtIndex:fromIndexPath.row] retain];
	[fromSectionController.cellControllers removeObjectAtIndex:fromIndexPath.row];
	[toSectionController.cellControllers insertObject:cellController atIndex:toIndexPath.row];
	[cellController release];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"MultipleChoiceMetadataValueCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	cell.textLabel.text = self.choice.name;
	if(self.metadataDelegate && [self.metadataDelegate respondsToSelector:@selector(selectedMetadataValue)])
	{
		cell.accessoryType = [self.choice.name isEqualToString:[self.metadataDelegate selectedMetadataValue]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	}
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)metadataEditorViewControllerDone:(MetadataEditorViewController *)metadataEditorViewController
{
	self.choice.name = metadataEditorViewController.value;
	[self.type.managedObjectContext processPendingChanges];

	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		self.delegate.forceReload = YES;
	}

	[metadataEditorViewController.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView.editing)
	{
		NSString *name = nil;
		if(self.delegate && [self.delegate respondsToSelector:@selector(name)])
		{
			name = [(id)self.delegate name];
		}
		if(name == nil || [name length] == 0)
		{
			name = NSLocalizedString(@"Choice Name", @"The title used in the Settings->Multiple Users screen");
		}
			
		MetadataEditorViewController *p = [[[MetadataEditorViewController alloc] initWithName:name type:STRING data:self.choice.name value:self.choice.name] autorelease];
		[p setPlaceholder:NSLocalizedString(@"Enter the multiple choice value", @"multiple choice value placeholder text")];
		[p setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		p.delegate = self;
		p.tag = indexPath.row;
		[[self.delegate navigationController] pushViewController:p animated:YES];
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
	else 
	{
		if(self.metadataDelegate && [self.metadataDelegate respondsToSelector:@selector(tableView:didSelectValue:atIndexPath:)])
		{
			[self.metadataDelegate tableView:tableView didSelectValue:self.choice.name atIndexPath:indexPath];
		}
	}

}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self.choice.managedObjectContext deleteObject:self.choice];
		[self.choice.managedObjectContext processPendingChanges];
		[self.delegate deleteDisplayRowAtIndexPath:indexPath];
	}
}

@end


/******************************************************************
 *
 *   ADD CHOICE
 *
 ******************************************************************/
#pragma mark AddMultipleChoiceMetadataCellController
@interface AddMultipleChoiceMetadataCellController : MetadataGenericTableViewCellController <MetadataEditorViewControllerDelegate>
{
	int row;
	int section;
	MTAdditionalInformationType *type;
	NSObject<MultipleChoiceMetadataValueCellControllerDelegate> *metadataDelegate;
}
@property (nonatomic, retain) MTAdditionalInformationType *type;
@property (nonatomic, assign) NSObject<MultipleChoiceMetadataValueCellControllerDelegate> *metadataDelegate;
@end
@implementation AddMultipleChoiceMetadataCellController
@synthesize type;
@synthesize metadataDelegate;

- (void)dealloc
{
	self.type = nil;
	[super dealloc];
}

- (BOOL)isViewableWhenNotEditing
{
	return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"AddQuickNotesCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = NSLocalizedString(@"Add New Choice", @"button to press when you are in the Multiple Choice view, this button lets the user add another choice to a multiple choice type");
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *name = nil;
	if(self.delegate && [self.delegate respondsToSelector:@selector(name)])
	{
		name = [(id)self.delegate name];
	}
	if(name == nil || [name length] == 0)
	{
		name = NSLocalizedString(@"Choice Name", @"The title used in the Settings->Multiple Users screen");
	}
	MetadataEditorViewController *p = [[[MetadataEditorViewController alloc] initWithName:name type:STRING data:@"" value:@""] autorelease];
	[p setPlaceholder:NSLocalizedString(@"Enter the multiple choice value", @"multiple choice value placeholder text")];
	[p setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	p.delegate = self;
	section = indexPath.section;
	p.tag = indexPath.row;
	[[self.delegate navigationController] pushViewController:p animated:YES];
	[self.delegate retainObject:self whileViewControllerIsManaged:p];
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)metadataEditorViewControllerDone:(MetadataEditorViewController *)metadataEditorViewController
{
	int position = [self.type.multipleChoices count];

	MTMultipleChoice *choice = [MTMultipleChoice createMultipleChoiceForAdditionalInformationType:self.type];
	choice.name = metadataEditorViewController.value;
	choice.type = self.type;
	
	MultipleChoiceMetadataValueCellController *cellController = [[[MultipleChoiceMetadataValueCellController alloc] init] autorelease];
	cellController.choice = choice;
	cellController.type = self.type;
	cellController.delegate = self.delegate;
	cellController.metadataDelegate = self.metadataDelegate;
	[[[self.delegate.sectionControllers objectAtIndex:section] cellControllers] insertObject:cellController atIndex:position];

	[self.type.managedObjectContext processPendingChanges];
	
	// reload the table
	[self.delegate updateWithoutReload];
	
	[metadataEditorViewController.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleInsert;
}


@end


/******************************************************************
 *
 *   TYPE
 *
 ******************************************************************/
#pragma mark MetadataTypeCellController
@interface MetadataTypeCellController : MetadataCustomViewCellController
{
	int index;
}
@property (nonatomic, assign) int index;

@end
@implementation MetadataTypeCellController
@synthesize index;

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"MetadataTypeCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	if(self.delegate.startedWithSelected >= 0 && 
	   commonInformation[self.delegate.startedWithSelected].type == STRING && 
	   commonInformation[index].type == CHOICE)
	{
		cell.textLabel.text = NSLocalizedString(@"Convert to Multiple Choice", @"When making a new additional information if you previsouly had a 'String' type and you want to change it to a multiple choice, this is the text used, because I go through all of the values of the 'String' and automatically set those up as choices");
	}
	else 
	{
		cell.textLabel.text = [[PSLocalization localizationBundle] localizedStringForKey:commonInformation[index].name value:commonInformation[index].name table:@""];
	}
	cell.editingAccessoryType = (self.delegate.selected == index) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int prevSelected = self.delegate.selected;
	self.delegate.selected = index;
	MTAdditionalInformationType *type = self.delegate.type;
	
	if(self.delegate.startedWithSelected >= 0 && 
	   commonInformation[self.delegate.startedWithSelected].type == STRING && 
	   commonInformation[index].type == CHOICE &&
	   type.multipleChoices == nil)
	{
		// go through all of the calls and add the values as options for this particular metadata
		for(NSString *value in [type.additionalInformation valueForKeyPath:@"@distinctUnionOfObjects.value"])
		{
			MTMultipleChoice *choice = [MTMultipleChoice createMultipleChoiceForAdditionalInformationType:type];
			choice.type = type;
			choice.name = value;
		}
		[type.managedObjectContext processPendingChanges];
		[self.delegate updateAndReload];
	}
	else
	{
		if(prevSelected >= 0)
		{
			[[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:prevSelected inSection:indexPath.section]] setEditingAccessoryType:UITableViewCellAccessoryNone];
		}
		[[tableView cellForRowAtIndexPath:indexPath] setEditingAccessoryType:UITableViewCellAccessoryCheckmark];
		
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}


@end

@implementation MetadataCustomViewController

@synthesize delegate;
@synthesize name;
@synthesize nameNeedsFocus;
@synthesize selected;
@synthesize startedWithSelected;
@synthesize type = type_;
@synthesize newType;

- (void)setAdditionalInformationType
{
	self.type.typeValue = commonInformation[selected].type;
	if(self.type.typeValue != CHOICE)
	{
		for(MTMultipleChoice *choice in self.type.multipleChoices)
		{
			[self.type.managedObjectContext deleteObject:choice];
		}
	}
	self.type.name = self.name;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:MTNotificationAdditionalInformationTypeChanged object:self.type];
	[MTSorter updateSortersForAdditionalInformationType:self.type];
	
	[self save];
	
	if(delegate && selected >= 0)
	{
		[delegate metadataCustomViewControllerDone:self];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 0)
	{
		for(MTAdditionalInformation *info in self.type.additionalInformation)
		{
			info.booleanValue = NO;
			info.date = nil;
			info.value = @"";
			info.number = nil;
		}
		[self setAdditionalInformationType];
	}
	else
	{
		// do nothing, and dont pop the view controller
	}
}

- (void)navigationControlCancel:(id)sender
{
	if(delegate)
	{
		[delegate metadataCustomViewControllerCancel:self];
	}
}

- (void)navigationControlDone:(id)sender
{
	// dont save the info if the selection is not Multiple Choice
	if(selected >= 0)
	{
		self.type.name = self.name;

		if(!self.newType && commonInformation[selected].type !=  self.type.typeValue)
		{
			// TODO: need to update all of the things
			BOOL used = NO;
			for(MTAdditionalInformation *info in self.type.additionalInformation)
			{
				if(info.value.length != 0)
				{
					used = YES;
					break;
				}
			}
			
			//		if(used)
			{
				// they changed the type of this particular additional information
				// make sure that we fix the incompatible versions
				switch(commonInformation[selected].type)
				{
					case DATE:
					case NUMBER:
					case SWITCH:
					{
						// need to kick off a question to the user if they really want to delete all of the information in previously used AdditionalInformation
						UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"You have changed the type of an Additional Information which is currently being used, this will reset any values you are currently using in any of your calls. \nAre you sure you want to do this?", @"This message is presented when the user has changed an \"Additional Information\" type from one type to an incompatible type like a \"String\" to a \"Date\"")
																				  delegate:self 
																		 cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel Button") 
																	destructiveButtonTitle:NSLocalizedString(@"Yes change and reset data", @"YES button to change the type of additional information from the dialog: You have changed the type of the Additional Information, this will reset any values you are currently using in any of your calls.  Are you sure you want to do this?")
																		 otherButtonTitles:nil] autorelease];
						[actionSheet showInView:[[MyTimeAppDelegate sharedInstance] window]];
						return;	
					}
					default:
						// we can let the others go and just have their values replaced with the other applicable data
						break;
				}
			}
			
		}
		[self setAdditionalInformationType];
	}
}

- (void)dealloc
{
	self.name = nil;
	
	[super dealloc];
}

- (id) init
{
	assert(NO);
}

- (void)save
{
	NSError *error = nil;
	if(![self.type.managedObjectContext save:&error])
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:self.navigationController error:error];
	}
}

- (id)initWithAdditionalInformationType:(MTAdditionalInformationType *)type;
{
	if ([super initWithStyle:UITableViewStyleGrouped]) 
	{
		self.type = type;
		self.name = [NSMutableString stringWithString:type.name ? type.name : @""];
		selected = -1;
		nameNeedsFocus = YES;
		for(int i = 0; i < ARRAY_SIZE(commonInformation); i++)
		{
			if(self.type.typeValue == commonInformation[i].type)
			{
				nameNeedsFocus = NO;
				selected = i;
				break;
			}
		}
		startedWithSelected = selected;
		
		// set the title, and tab bar images from the dataSource
		self.title = NSLocalizedString(@"Custom", @"Title for field in the Additional Information for the user to create their own additional information field");
	}
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)loadView 
{
	[super loadView];
	
	self.editing = YES;
	
	// add DONE button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];
	
	self.navigationItem.rightBarButtonItem.enabled = selected >= 0 && name.length;

	if(self.newType)
	{
		button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																target:self
																action:@selector(navigationControlCancel:)] autorelease];
		[self.navigationItem setLeftBarButtonItem:button animated:NO];
	}
	else
	{
		[self.navigationItem hidesBackButton];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//	[super scrollViewDidScroll:scrollView];
	[[(UITableViewTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] textField] resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int prevSelected = selected;
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];

	if((prevSelected >= 0 && commonInformation[prevSelected].type == CHOICE) ||
	   (selected >= 0 && commonInformation[selected].type == CHOICE))
	{
		[self updateWithoutReload];
	}
	
	if(indexPath.row != 0 || indexPath.section != 0)
	{
		[[(UITableViewTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] textField] resignFirstResponder];
	}
	self.navigationItem.rightBarButtonItem.enabled = selected >= 0 && name.length;
}


- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath 
{
	GenericTableViewSectionController *sectionController = [self.displaySectionControllers objectAtIndex:proposedDestinationIndexPath.section];
	// check to see if they are moving it beyond the "Add custom information", the last entry and there are no entries in the list
	if(proposedDestinationIndexPath.section < sourceIndexPath.section)
		return [NSIndexPath indexPathForRow:0 inSection:sourceIndexPath.section];
	
	if(proposedDestinationIndexPath.section > sourceIndexPath.section) // have to put it before the "add new" row
		return [NSIndexPath indexPathForRow:([[[self.displaySectionControllers objectAtIndex:sourceIndexPath.section] displayCellControllers] count] - 2) inSection:sourceIndexPath.section];
	
	if((sectionController.displayCellControllers.count - 1) == proposedDestinationIndexPath.row &&
	   sectionController.displayCellControllers.count > 1)
	{
		// only subtract 1 off of the row if the source row is in the same section (cause the row count is not increasing just getting shuffled)
		int offset = proposedDestinationIndexPath.section == sourceIndexPath.section ? 1 : 0;
		// if there is only one section controller in this section then put the entry 
		return [NSIndexPath indexPathForRow:(proposedDestinationIndexPath.row - offset) inSection:proposedDestinationIndexPath.section];
	}
    // Allow the proposed destination.
    return proposedDestinationIndexPath;
}

+ (void)addCellMultipleChoiceCellControllersToSectionController:(GenericTableViewSectionController *)sectionController tableController:(GenericTableViewController *)viewController fromType:(MTAdditionalInformationType *)type metadataDelegate:(NSObject<MultipleChoiceMetadataValueCellControllerDelegate> *)metadataDelegate
{
	NSArray *sortedArray = [[type.multipleChoices allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES]]];
	
	for(MTMultipleChoice *choice in sortedArray)
	{
		MultipleChoiceMetadataValueCellController *cellController = [[MultipleChoiceMetadataValueCellController alloc] init];
		cellController.delegate = viewController;
		cellController.metadataDelegate = metadataDelegate;
		cellController.choice = choice;
		cellController.type = type;
		[sectionController.cellControllers addObject:cellController];
		[cellController release];
	}

	// add the "Add Additional User" cell at the end
	AddMultipleChoiceMetadataCellController *addCellController = [[AddMultipleChoiceMetadataCellController alloc] init];
	addCellController.delegate = viewController;
	addCellController.metadataDelegate = metadataDelegate;
	addCellController.type = type;
	[sectionController.cellControllers addObject:addCellController];
	[addCellController release];
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];
	
	// Name Section
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		MetadataNameCellController *cellController = [[MetadataNameCellController alloc] init];
		cellController.delegate = self;
		cellController.name = self.name;
		[sectionController.cellControllers addObject:cellController];
		[cellController release];
	}
	
	// Multiple Choice section
	{
		MultipleChoiceMetadataSectionController *sectionController = [[MultipleChoiceMetadataSectionController alloc] init];
		sectionController.delegate = self;
		[self.sectionControllers addObject:sectionController];
		[sectionController release];


		[MetadataCustomViewController addCellMultipleChoiceCellControllersToSectionController:sectionController tableController:self fromType:self.type metadataDelegate:nil];
	}
	// Type Section
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		sectionController.editingTitle = NSLocalizedString(@"Type", @"type of Additional Information, used as a title to the section Call->Edit->Add Additional Information->Edit->Add Custom");
		[self.sectionControllers addObject:sectionController];
		[sectionController release];

		for(int i = 0; i < ARRAY_SIZE(commonInformation); ++i)
		{
			MetadataTypeCellController *cellController = [[MetadataTypeCellController alloc] init];
			cellController.delegate = self;
			cellController.index = i;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	}
}

@end



