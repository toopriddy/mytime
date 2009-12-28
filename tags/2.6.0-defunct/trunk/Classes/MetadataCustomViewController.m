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
#import "Settings.h"
#import "UITableViewTextFieldCell.h"
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

#define ARRAY_SIZE(a) (sizeof(a)/sizeof(a[0]))

@interface MetadataCustomViewController ()
@property (nonatomic, assign) BOOL nameNeedsFocus;
@property (nonatomic, assign) int selected;
@property (nonatomic, assign) int startedWithSelected;
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
	NSString *value;
	NSMutableArray *data;
	NSObject<MultipleChoiceMetadataValueCellControllerDelegate> *metadataDelegate;
}
@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) NSMutableArray *data;
@property (nonatomic, assign) NSObject<MultipleChoiceMetadataValueCellControllerDelegate> *metadataDelegate;
@end
@implementation MultipleChoiceMetadataValueCellController
@synthesize value;
@synthesize data;
@synthesize metadataDelegate;

- (void)dealloc
{
	self.data = nil;
	[super dealloc];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	// move the row
	
	NSString *fromString = [[self.data objectAtIndex:fromIndexPath.row] retain];
	[self.data removeObjectAtIndex:fromIndexPath.row];
	[self.data insertObject:fromString atIndex:toIndexPath.row];
	[fromString release];
	
	[[Settings sharedInstance] saveData];																	
	
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
	cell.textLabel.text = self.value;
	if(self.metadataDelegate && [self.metadataDelegate respondsToSelector:@selector(selectedMetadataValue)])
	{
		cell.accessoryType = [self.value isEqualToString:[self.metadataDelegate selectedMetadataValue]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	}
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)metadataEditorViewControllerDone:(MetadataEditorViewController *)metadataEditorViewController
{
	self.value = metadataEditorViewController.value;
	[self.data replaceObjectAtIndex:metadataEditorViewController.tag withObject:self.value];
	
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
			
		MetadataEditorViewController *p = [[[MetadataEditorViewController alloc] initWithName:name type:STRING data:self.value value:self.value] autorelease];
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
			[self.metadataDelegate tableView:tableView didSelectValue:self.value atIndexPath:indexPath];
		}
	}

}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self.data removeObjectAtIndex:indexPath.row];
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
	NSMutableArray *data;
	NSObject<MultipleChoiceMetadataValueCellControllerDelegate> *metadataDelegate;
}
@property (nonatomic, retain) NSMutableArray *data;
@property (nonatomic, assign) NSObject<MultipleChoiceMetadataValueCellControllerDelegate> *metadataDelegate;
@end
@implementation AddMultipleChoiceMetadataCellController
@synthesize data;
@synthesize metadataDelegate;

- (void)dealloc
{
	self.data = nil;
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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
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
	MultipleChoiceMetadataValueCellController *cellController = [[[MultipleChoiceMetadataValueCellController alloc] init] autorelease];
	cellController.value = metadataEditorViewController.value;
	cellController.data = self.data;
	cellController.delegate = self.delegate;
	cellController.metadataDelegate = self.metadataDelegate;
	[[[self.delegate.sectionControllers objectAtIndex:section] cellControllers] insertObject:cellController atIndex:[self.data count]];
	
	// now store the data and save it
	[self.data addObject:[NSString stringWithString:metadataEditorViewController.value]];
	[[Settings sharedInstance] saveData];
	
	// reload the table
	[self.delegate updateWithoutReload];
	
	[self.delegate.navigationController popToViewController:self.delegate animated:YES];
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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
	}
	if(self.delegate.startedWithSelected >= 0 && 
	   commonInformation[self.delegate.startedWithSelected].type == STRING && 
	   commonInformation[index].type == CHOICE)
	{
		cell.textLabel.text = NSLocalizedString(@"Convert to Multiple Choice", @"When making a new additional information if you previsouly had a 'String' type and you want to change it to a multiple choice, this is the text used, because I go through all of the values of the 'String' and automatically set those up as choices");
	}
	else 
	{
		cell.textLabel.text = commonInformation[index].name;
	}
	cell.editingAccessoryType = (self.delegate.selected == index) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int prevSelected = self.delegate.selected;
	self.delegate.selected = index;

	if(self.delegate.startedWithSelected >= 0 && 
	   commonInformation[self.delegate.startedWithSelected].type == STRING && 
	   commonInformation[index].type == CHOICE)
	{
		NSMutableDictionary *values = [NSMutableDictionary dictionary];
		// go through all of the calls and add the values as options for this particular metadata
		for(NSDictionary *call in [[[Settings sharedInstance] userSettings] objectForKey:SettingsCalls])
		{
			for(NSDictionary *metadata in [call objectForKey:CallMetadata])
			{
				if([self.delegate.name isEqualToString:[metadata objectForKey:CallMetadataName]] && 
				   [[metadata objectForKey:CallMetadataType] intValue] == STRING)
				{
					NSString *value = [metadata objectForKey:CallMetadataValue];
					[values setObject:value forKey:value];
				}
			}
		}
		NSArray *keys = [values allKeys];
		[self.delegate.data addObjectsFromArray:keys];
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
@synthesize data;

- (void)navigationControlDone:(id)sender
{
	// dont save the info if the selection is not Multiple Choice
	if(commonInformation[selected].type != CHOICE)
	{
		self.data = nil;
	}
	if(delegate && selected >= 0)
	{
		[delegate metadataCustomViewControllerDone:self];
	}
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)dealloc
{
	self.name = nil;
	self.data = nil;
	
	[super dealloc];
}

- (id) init
{
	return [self initWithName:nil type:-1 data:nil];
}

- (id) initWithName:(NSString *)theName type:(MetadataType)type data:(NSMutableArray *)theData
{
	if ([super initWithStyle:UITableViewStyleGrouped]) 
	{
		self.data = theData;
		if(self.data == nil)
		{
			self.data = [NSMutableArray array];
		}
		
		self.name = [NSMutableString stringWithString:theName ? theName : @""];
		selected = -1;
		nameNeedsFocus = YES;
		for(int i = 0; i < ARRAY_SIZE(commonInformation); i++)
		{
			if(type == commonInformation[i].type)
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
	if(proposedDestinationIndexPath.section == sourceIndexPath.section && 
	   (sectionController.displayCellControllers.count - 1) == proposedDestinationIndexPath.row &&
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

+ (void)addCellMultipleChoiceCellControllersToSectionController:(GenericTableViewSectionController *)sectionController tableController:(GenericTableViewController *)viewController choices:(NSMutableArray *)data metadataDelegate:(NSObject<MultipleChoiceMetadataValueCellControllerDelegate> *)metadataDelegate
{
	for(NSString *entry in data)
	{
		MultipleChoiceMetadataValueCellController *cellController = [[MultipleChoiceMetadataValueCellController alloc] init];
		cellController.delegate = viewController;
		cellController.metadataDelegate = metadataDelegate;
		cellController.value = entry;
		cellController.data = data;
		[sectionController.cellControllers addObject:cellController];
		[cellController release];
	}

	// add the "Add Additional User" cell at the end
	AddMultipleChoiceMetadataCellController *addCellController = [[AddMultipleChoiceMetadataCellController alloc] init];
	addCellController.delegate = viewController;
	addCellController.metadataDelegate = metadataDelegate;
	addCellController.data = data;
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


		[MetadataCustomViewController addCellMultipleChoiceCellControllersToSectionController:sectionController tableController:self choices:self.data metadataDelegate:nil];
	}
	// Type Section
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		sectionController.title = NSLocalizedString(@"Type", @"type of Additional Information, used as a title to the section Call->Edit->Add Additional Information->Edit->Add Custom");
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


- (MetadataType)type
{
	int index = selected >= 0 ? selected : 0;
	return commonInformation[index].type;
}

@end



