//
//  MetadataViewController.m
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

#import "MetadataViewController.h"
#import "PublicationViewController.h"
#import "Settings.h"
#import "MTAdditionalInformation.h"
#import "MTAdditionalInformationType.h"
#import "MTCall.h"
#import "MTUser.h"
#import "MTMultipleChoice.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSLocalization.h"

#include "PSRemoveLocalizedString.h"
static MetadataInformation commonInformation[] = {
	{NSLocalizedString(@"Email", @"Call Metadata"), EMAIL}
,	{NSLocalizedString(@"Phone", @"Call Metadata"), PHONE}
,	{NSLocalizedString(@"Mobile Phone", @"Call Metadata"), PHONE}
,	{NSLocalizedString(@"Notes", @"Call Metadata"), NOTES}
};
#include "PSAddLocalizedString.h"

#define ARRAY_SIZE(a) (sizeof(a)/sizeof(a[0]))

#import "TableViewCellController.h"
#import "Settings.h"
#import "UITableViewTitleAndValueCell.h"
#import "GenericTableViewSectionController.h"
#import "MetadataEditorViewController.h"
#import "MetadataCustomViewController.h"

@interface MetadataCellController : NSObject<TableViewCellController, MetadataCustomViewControllerDelegate, UIAlertViewDelegate>
{
	MTAdditionalInformationType *_additionalInformationType;
	MetadataViewController *delegate;
	NSIndexPath *_indexPath;
	BOOL alertViewDeletingOldValues;
	BOOL alertViewNotAlwaysShown;
	BOOL alertViewDeleting;
}
@property (nonatomic, retain) MTAdditionalInformationType *additionalInformationType;
@property (nonatomic, assign) MetadataViewController *delegate;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, retain) MetadataCustomViewController *pendingMetadataCustomViewController;
- (void)deleteAllAdditionalInformation;

@end
@implementation MetadataCellController
@synthesize delegate;
@synthesize indexPath = _indexPath;
@synthesize additionalInformationType = _additionalInformationType;
@synthesize pendingMetadataCustomViewController;

- (void)dealloc
{
	self.indexPath = nil;
	[super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"MetadataCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	cell.textLabel.text = self.additionalInformationType.name;

	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	return cell;
}

- (void)deleteAdditionalInformationType
{
	// delete all additional information associated with this type
	[self deleteAllAdditionalInformation];
	
	// remove the Type
	[self.additionalInformationType.managedObjectContext deleteObject:self.additionalInformationType];
	NSError *error = nil;
	if(![self.additionalInformationType.managedObjectContext save:&error])
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	[self.delegate deleteDisplayRowAtIndexPath:self.indexPath];
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		int row = [indexPath row];
		DEBUG(NSLog(@"tableView: editingStyleForRowAtIndexPath section=%d row=%d", indexPath.section, row);)

		// remove the metadata
		// ask them if they want to remove all instances of the metadata from the calls			
		BOOL used = NO;
		for(MTAdditionalInformation *info in self.additionalInformationType.additionalInformation)
		{
			if(info.value.length != 0)
			{
				used = YES;
				break;
			}
		}
		self.indexPath = indexPath;
		
		if(used)
		{
			// lets leave this type hidden till we know what the user wants to do with it
			alertViewDeleting = YES;
	
			UIAlertView *alertSheet = [[[UIAlertView alloc] initWithTitle:@""
																  message:NSLocalizedString(@"This Additional Information was added to some of your calls. Do you want to remove it from your calls?", @"This message is presented when the user deletes an \"Additional Information\" that was added to at least one call and actually used") 
																 delegate:self 
														cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel Button") 
														otherButtonTitles:NSLocalizedString(@"Delete From All Calls", @"Button used to delete \"Additional Information\" from all calls with the message: This Additional Information was added to some of your calls. Do you want to remove it from your calls?"), nil] autorelease];
			[alertSheet show];
			return;
		}
		else
		{
			[self deleteAdditionalInformationType];
		}
	}
}

- (void)setAdditionalInformationType:(MTAdditionalInformationType *)type forMetadataCustomViewController:(MetadataCustomViewController *)metadataCustomViewController
{
	if(self.additionalInformationType.typeValue == CHOICE)
	{
#warning fix me
		self.additionalInformationType.multipleChoices = metadataCustomViewController.multipleChoices;
	}
	else
	{
		self.additionalInformationType.multipleChoices = nil;
	}
	self.additionalInformationType.typeValue = metadataCustomViewController.type;
	self.additionalInformationType.name = metadataCustomViewController.name;
	
	[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)deleteAllUnusedAdditionalInformation
{
	BOOL found = NO;
	for(MTAdditionalInformation *info in self.additionalInformationType.additionalInformation)
	{
		if(info.value.length == 0)
		{
			found = YES;
			[info.managedObjectContext deleteObject:info];
		}
	}
	if(self.delegate.delegate && [self.delegate.delegate respondsToSelector:@selector(metadataViewControllerRemoveMetadata:metadata:)])
	{
		[self.delegate.delegate metadataViewControllerRemoveMetadata:self.delegate metadata:self.additionalInformationType];
	}
	
	if(found)
	{
		NSError *error = nil;
		if(![self.additionalInformationType.managedObjectContext save:&error])
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
	}
}


- (void)deleteAllAdditionalInformation
{
	for(MTAdditionalInformation *info in self.additionalInformationType.additionalInformation)
	{
		[info.managedObjectContext deleteObject:info];
	}
	if(self.delegate.delegate && [self.delegate.delegate respondsToSelector:@selector(metadataViewControllerRemoveMetadata:metadata:)])
	{
		[self.delegate.delegate metadataViewControllerRemoveMetadata:self.delegate metadata:self.additionalInformationType];
	}
	
	NSError *error = nil;
	if(![self.additionalInformationType.managedObjectContext save:&error])
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(alertViewDeletingOldValues)
	{
		alertViewDeletingOldValues = NO;
		if(buttonIndex == 0)
		{
			for(MTAdditionalInformation *info in self.additionalInformationType.additionalInformation)
			{
				info.booleanValue = NO;
				info.date = nil;
				info.value = @"";
				info.number = nil;
			}
			[self setAdditionalInformationType:self.additionalInformationType forMetadataCustomViewController:self.pendingMetadataCustomViewController];
			[self.delegate.navigationController popViewControllerAnimated:YES];
		}
		else
		{
			// do nothing, and dont pop the view controller
		}
	}
	else if(alertViewNotAlwaysShown)
	{
		alertViewNotAlwaysShown = NO;
		switch(buttonIndex)
		{
			case 0:
				[self deleteAllUnusedAdditionalInformation];
				break;
			case 1:
				[self deleteAllAdditionalInformation];
				break;
			default:
				break;
		}
	}
	else if(alertViewDeleting)
	{
		if(buttonIndex == 0)
		{
			[self deleteAdditionalInformationType];
		}
		else
		{
			[self.delegate updateAndReload];
		}
	}
}

- (void)metadataCustomViewControllerDone:(MetadataCustomViewController *)metadataCustomViewController
{
	if(self.additionalInformationType.typeValue != metadataCustomViewController.type)
	{
		// they changed the type of this particular additional information
		// make sure that we fix the incompatible versions
		switch(metadataCustomViewController.type)
		{
			case DATE:
			case NUMBER:
			case SWITCH:
			{
				alertViewDeletingOldValues = YES;
				self.pendingMetadataCustomViewController = metadataCustomViewController;
				// need to kick off a question to the user if they really want to delete all of the information in previously used AdditionalInformation
				UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
				alertSheet.delegate = self;
				[alertSheet addButtonWithTitle:NSLocalizedString(@"YES", @"YES button")];
				[alertSheet addButtonWithTitle:NSLocalizedString(@"NO", @"NO button")];
				alertSheet.title = NSLocalizedString(@"You have changed the type of the Additional Information, this will reset any values you are currently using in any of your calls.  Are you sure you want to do this?", @"This message is presented when the user has changed an \"Additional Information\" type from one type to an incompatible type like a \"String\" to a \"Date\"");
				[alertSheet show];
				return;	
			}
			default:
				// we can let the others go and just have their values replaced with the other applicable data
				break;
		}
	}
	
	[self setAdditionalInformationType:self.additionalInformationType forMetadataCustomViewController:metadataCustomViewController];
	
	[self.delegate.navigationController popViewControllerAnimated:YES];

}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView.editing)
	{
		self.indexPath = [[indexPath copy] autorelease];
		MTAdditionalInformationType *type = self.additionalInformationType;
		MetadataCustomViewController *p = [[[MetadataCustomViewController alloc] initWithName:type.name
																						 type:type.typeValue
																			  multipleChoices:type.multipleChoices] autorelease];
		p.delegate = self;
		[[self.delegate navigationController] pushViewController:p animated:YES];
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
	else
	{
		if(self.delegate.delegate)
		{
			[self.delegate.delegate metadataViewControllerAdd:self.delegate metadata:self.additionalInformationType];
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	// move the row
	self.additionalInformationType.alwaysShownValue = toIndexPath.section == 0;

	if(fromIndexPath.section != toIndexPath.section)
	{
		if(toIndexPath.section == 0)
		{
			NSManagedObjectContext *moc = self.additionalInformationType.managedObjectContext;
			MTAdditionalInformationType *type = self.additionalInformationType;
			for(MTCall *call in [moc fetchObjectsForEntityName:[MTCall entityName] 
											 propertiesToFetch:[NSArray arrayWithObject:@"name"]
												 withPredicate:@"(user == %@) AND (additionalInformation.@count == 0 || (additionalInformation.@count > 0 && (NONE additionalInformation.type == %@)))", type.user, type])
			{
				MTAdditionalInformation *info = [MTAdditionalInformation insertInManagedObjectContext:moc];
				info.type = type;
				info.call = call;
			}
			
			NSError *error = nil;
			if(![self.additionalInformationType.managedObjectContext save:&error])
			{
				[NSManagedObjectContext presentErrorDialog:error];
			}
			
			// add the metadata to all of the calls
			if(self.delegate.delegate && [self.delegate.delegate respondsToSelector:@selector(metadataViewControllerAddPreferredMetadata:metadata:)])
			{
				[self.delegate.delegate metadataViewControllerAddPreferredMetadata:self.delegate metadata:self.additionalInformationType];
			}
		}
		else
		{
			// remove the metadata
			// ask them if they want to remove all instances of the metadata from the calls			
			BOOL used = NO;
			for(MTAdditionalInformation *info in self.additionalInformationType.additionalInformation)
			{
				if(info.value.length != 0)
				{
					used = YES;
					break;
				}
			}
			
			if(used)
			{
				alertViewNotAlwaysShown = YES;
				UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
				alertSheet.delegate = self;
				[alertSheet addButtonWithTitle:NSLocalizedString(@"Remove Unused", @"Button used in the Alert View that is presented for:This Additional Information was added to all of your calls, do you want to remove it from all of your calls, or just remove the unused values from your calls?")];
				[alertSheet addButtonWithTitle:NSLocalizedString(@"Remove All", @"Button used in the Alert View that is presented for:This Additional Information was added to all of your calls, do you want to remove it from all of your calls, or just remove the unused values from your calls?")];
				[alertSheet addButtonWithTitle:NSLocalizedString(@"Leave All", @"Button used in the Alert View that is presented for:This Additional Information was added to all of your calls, do you want to remove it from all of your calls, or just remove the unused values from your calls?")];
				alertSheet.title = NSLocalizedString(@"This Additional Information was added to all of your calls, do you want to remove it from all of your calls, or just remove the unused values from your calls?", @"If the user has added this \"Additional Information\" to the \"Always Shown\" section then MyTime adds this additional information to all of the calls, so when the user wants to remove this particular \"Additional Information\" from the always shown section they have a choice to remove all of the additional information from their calls or just the additional information that has not already been filled out in their calls");
				[alertSheet show];
			}
			else
			{
				[self deleteAllAdditionalInformation];
			}
		}
	}
	
	// move the cellController
	GenericTableViewSectionController *fromSectionController = [self.delegate.sectionControllers objectAtIndex:fromIndexPath.section];
	GenericTableViewSectionController *toSectionController = [self.delegate.sectionControllers objectAtIndex:toIndexPath.section];
	NSObject *cellController = [[fromSectionController.cellControllers objectAtIndex:fromIndexPath.row] retain];
	[fromSectionController.cellControllers removeObjectAtIndex:fromIndexPath.row];
	[toSectionController.cellControllers insertObject:cellController atIndex:toIndexPath.row];
	[cellController release];
	
	// move the cellController in the displayList (the main list and the display list are the same)
	cellController = [[fromSectionController.displayCellControllers objectAtIndex:fromIndexPath.row] retain];
	[fromSectionController.displayCellControllers removeObjectAtIndex:fromIndexPath.row];
	[toSectionController.displayCellControllers insertObject:cellController atIndex:toIndexPath.row];
	[cellController release];

	// now to reorder the AdditionalInformationTypes
	int i = 0; 
	for(MetadataCellController *cell in fromSectionController.displayCellControllers)
	{
		if([cell isKindOfClass:[MetadataCellController class]])
		{
			cell.additionalInformationType.orderValue = i++;
		}
	}
	// now rearrange the toSectionController if it was modified
	if(fromSectionController != toSectionController)
	{
		i = 0;
		for(MetadataCellController *cell in toSectionController.displayCellControllers)
		{
			if([cell isKindOfClass:[MetadataCellController class]])
			{
				cell.additionalInformationType.orderValue = i++;
			}
		}
	}
	
	NSError *error = nil;
	if(![self.additionalInformationType.managedObjectContext save:&error])
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
}
@end



@interface AddMetadataCellController : NSObject<TableViewCellController, MetadataCustomViewControllerDelegate>
{
	MetadataViewController *delegate;
	NSIndexPath *_indexPath;
}
@property (nonatomic, assign) MetadataViewController *delegate;
@property (nonatomic, retain) NSIndexPath *indexPath;
@end
@implementation AddMetadataCellController
@synthesize delegate;
@synthesize indexPath = _indexPath;

- (void)dealloc
{
	self.indexPath = nil;
	[super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"AddAdditionalInfo";
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	[cell setValue:NSLocalizedString(@"Add Custom Information", @"Button to click to add an 'Additional Information' to calls")];
	return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleInsert;
}

- (BOOL)isViewableWhenNotEditing
{
	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)metadataCustomViewControllerDone:(MetadataCustomViewController *)metadataCustomViewController
{
	MTUser *currentUser = [MTUser currentUser];
	MTAdditionalInformationType *type = [MTAdditionalInformationType insertAdditionalInformationType:metadataCustomViewController.type 
																								name:metadataCustomViewController.name 
																								user:currentUser];
	type.alwaysShownValue = self.indexPath.section == 0;
	type.hidden = NO;
	NSError *error = nil;
	if(![type.managedObjectContext save:&error])
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	
	MetadataCellController *cellController = [[[MetadataCellController alloc] init] autorelease];
	cellController.delegate = self.delegate;
	cellController.additionalInformationType = type;

	GenericTableViewSectionController *sectionController = [self.delegate.sectionControllers objectAtIndex:self.indexPath.section];
	[sectionController.cellControllers insertObject:cellController atIndex:(sectionController.cellControllers.count - 1)];
	[self.delegate updateWithoutReload];
	[self.delegate.navigationController popViewControllerAnimated:YES];
}


// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// open up the custom metadata type
	self.indexPath = [[indexPath copy] autorelease];
	MetadataCustomViewController *p = [[[MetadataCustomViewController alloc] init] autorelease];
	p.delegate = self;
	
	[[self.delegate navigationController] pushViewController:p animated:YES];		
	[self.delegate retainObject:self whileViewControllerIsManaged:p];
	return;
}


@end

@interface AlwaysShownSectionController : GenericTableViewSectionController
{
}
@end
@implementation AlwaysShownSectionController

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if(tableView.editing)
		return self.footer;
	else
		return nil;
}
@end


@implementation MetadataViewController

@synthesize delegate;

+ (void)fixMetadataForUser:(NSMutableDictionary *)user
{
	NSMutableArray *preferredMetadata = [user objectForKey:SettingsPreferredMetadata];
	// so I goofed and sent out a beta build that had SettingsPreferredMetadata redefined and should have renamed it.... remove me after release
	if([preferredMetadata isKindOfClass:[NSString class]])
	{
		[(NSMutableDictionary *)user setObject:preferredMetadata forKey:SettingsSortedByMetadata];
		preferredMetadata = nil;
	}
	// end remove	
	NSMutableArray *otherMetadata = [user objectForKey:SettingsOtherMetadata];
	NSMutableArray *metadata = [user objectForKey:SettingsMetadata];
	if(metadata != nil || otherMetadata == nil)
	{
		otherMetadata = [NSMutableArray array];
		for(int i = 0; i < ARRAY_SIZE(commonInformation); i++)
		{
			[otherMetadata addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[PSLocalization localizationBundle] localizedStringForKey:commonInformation[i].name value:commonInformation[i].name table:@""], SettingsMetadataName, 
									  [NSNumber numberWithInt:commonInformation[i].type], SettingsMetadataType,
									  nil]];
		}
		[(NSMutableDictionary *)user setObject:otherMetadata forKey:SettingsOtherMetadata];
		[(NSMutableDictionary *)user removeObjectForKey:SettingsMetadata];
	}
	if(preferredMetadata == nil)
	{
		preferredMetadata = [NSMutableArray array];
		[(NSMutableDictionary *)user setObject:preferredMetadata forKey:SettingsPreferredMetadata];
	}
}

+ (void)fixMetadata
{
	[MetadataViewController fixMetadataForUser:[[Settings sharedInstance] userSettings]];
}

+ (NSArray *)metadataNames
{
	MTUser *currentUser = [MTUser currentUser];
	NSManagedObjectContext *moc = currentUser.managedObjectContext;
	NSArray *array = [[moc fetchObjectsForEntityName:[MTAdditionalInformationType entityName]
								   propertiesToFetch:nil 
								 withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO]]
									   withPredicate:@"user == %@ && hidden == NO ", currentUser] valueForKey:@"name"];
	return array;
}

- (id) init;
{
	if ([super initWithStyle:UITableViewStyleGrouped]) 
	{
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Add Info", @"Add Information title");
		
		self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)navigationControlEdit:(id)sender 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	[self.tableView flashScrollIndicators];
	
	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	
	self.navigationItem.hidesBackButton = YES;
	
	self.editing = YES;
}	

- (void)navigationControlDone:(id)sender 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	[self.tableView flashScrollIndicators];
	
	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																			 target:self
																			 action:@selector(navigationControlEdit:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	
	self.navigationItem.hidesBackButton = NO;
	
	self.editing = NO;
}	

- (void)loadView 
{
	[super loadView];
	
	[self updateAndReload];
	
	[self navigationControlDone:nil];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath 
{
	GenericTableViewSectionController *sectionController = [self.displaySectionControllers objectAtIndex:proposedDestinationIndexPath.section];
	NSLog(@"exitsint = %@ proposed = %@", sourceIndexPath, proposedDestinationIndexPath);
	// check to see if they are moving it beyond the "Add custom information", the last entry and there are no entries in the list
	if(proposedDestinationIndexPath.section == 1 && 
	   (sectionController.displayCellControllers.count - 1) == proposedDestinationIndexPath.row &&
		sectionController.displayCellControllers.count > 1)
	{
		// only subtract 1 off of the row if the source row is in the same section (cause the row count is not increasing just getting shuffled)
		int offset = proposedDestinationIndexPath.section == sourceIndexPath.section ? 1 : 0;
		// if there is only one section controller in this section then put the entry 
		return [NSIndexPath indexPathForRow:(proposedDestinationIndexPath.row - offset) inSection:1];
	}
    // Allow the proposed destination.
    return proposedDestinationIndexPath;
}


- (void)constructSectionControllers
{
	[super constructSectionControllers];

	MTUser *currentUser = [MTUser currentUser];
	NSManagedObjectContext *moc = currentUser.managedObjectContext;
	
	GenericTableViewSectionController *sectionController;

	// preferred Metadata
	sectionController = [[AlwaysShownSectionController alloc] init];
	sectionController.title = NSLocalizedString(@"Information Always Shown", @"Title in the 'Additional Information' for the entries that will always show in every call");
	sectionController.footer = NSLocalizedString(@"Any rows below that you move up here will always show up in your calls", @"Footer in the 'Additional Information' for the entries that will always show in every call");
	[self.sectionControllers addObject:sectionController];
	[sectionController release];

	for(MTAdditionalInformationType *entry in [moc fetchObjectsForEntityName:[MTAdditionalInformationType entityName]
														   propertiesToFetch:nil 
														 withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]
															   withPredicate:@"user == %@ && alwaysShown == YES && hidden == NO ", currentUser])
	{
		MetadataCellController *cellController = [[MetadataCellController alloc] init];
		cellController.delegate = self;
		cellController.additionalInformationType = entry;
		[sectionController.cellControllers addObject:cellController];
		[cellController release];
	}
	
	// other Metadata
	sectionController = [[GenericTableViewSectionController alloc] init];
	sectionController.title = NSLocalizedString(@"Other Information", @"Title in the 'Additional Information' for the entries that can be added per call");
	[self.sectionControllers addObject:sectionController];
	[sectionController release];

	for(MTAdditionalInformationType *entry in [moc fetchObjectsForEntityName:[MTAdditionalInformationType entityName]
														   propertiesToFetch:nil 
														 withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]
															   withPredicate:@"user == %@ && alwaysShown == NO && hidden == NO ", currentUser])
	{
		MetadataCellController *cellController = [[MetadataCellController alloc] init];
		cellController.delegate = self;
		cellController.additionalInformationType = entry;
		[sectionController.cellControllers addObject:cellController];
		[cellController release];
	}
	
	// add the "Add Additional User" cell at the end
	AddMetadataCellController *addCellController = [[AddMetadataCellController alloc] init];
	addCellController.delegate = self;
	[sectionController.cellControllers addObject:addCellController];
	[addCellController release];
}
@end
