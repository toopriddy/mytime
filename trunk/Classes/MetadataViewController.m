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

@interface MetadataCellController : NSObject<TableViewCellController, MetadataCustomViewControllerDelegate>
{
	MetadataViewController *delegate;
	NSIndexPath *_indexPath;
}
@property (nonatomic, assign) MetadataViewController *delegate;
@property (nonatomic, retain) NSIndexPath *indexPath;
@end
@implementation MetadataCellController
@synthesize delegate;
@synthesize indexPath = _indexPath;

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
		cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:commonIdentifier];
	}
	NSMutableArray *metadata = [[[Settings sharedInstance] userSettings] objectForKey:(indexPath.section == 0 ? SettingsPreferredMetadata : SettingsOtherMetadata)];

	cell.textLabel.text = [[metadata objectAtIndex:indexPath.row] objectForKey:SettingsMetadataName];

	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	return cell;
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		NSMutableArray *metadata = [[[Settings sharedInstance] userSettings] objectForKey:(indexPath.section == 0 ? SettingsPreferredMetadata : SettingsOtherMetadata)];
		int row = [indexPath row];
		DEBUG(NSLog(@"tableView: editingStyleForRowAtIndexPath section=%d row=%d", indexPath.section, row);)

		if(indexPath.section == 0)
		{
			// remove something from shown metadata
#warning fix me			
		}
		
		[metadata removeObjectAtIndex:row];
		[[Settings sharedInstance] saveData];

		[self.delegate deleteDisplayRowAtIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)metadataCustomViewControllerDone:(MetadataCustomViewController *)metadataCustomViewController
{
	NSMutableArray *metadata = [[[Settings sharedInstance] userSettings] objectForKey:(self.indexPath.section == 0 ? SettingsPreferredMetadata : SettingsOtherMetadata)];
	NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:metadataCustomViewController.name.text, SettingsMetadataName,
								  [NSNumber numberWithInt:metadataCustomViewController.type], SettingsMetadataType, nil];
	[metadata replaceObjectAtIndex:self.indexPath.row withObject:entry];
	[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView.editing)
	{
		NSMutableArray *metadata = [[[Settings sharedInstance] userSettings] objectForKey:(indexPath.section == 0 ? SettingsPreferredMetadata : SettingsOtherMetadata)];
		self.indexPath = [[indexPath copy] autorelease];
		int row = indexPath.row;
		MetadataCustomViewController *p = [[[MetadataCustomViewController alloc] initWithName:[[metadata objectAtIndex:row] objectForKey:SettingsMetadataName] 
																						 type:[[[metadata objectAtIndex:row] objectForKey:SettingsMetadataType] intValue]] autorelease];
		p.delegate = self;
		[[self.delegate navigationController] pushViewController:p animated:YES];		
	}
	else
	{
		MetadataInformation localMetadata;
		
		NSMutableArray *metadata = [[[Settings sharedInstance] userSettings] objectForKey:(indexPath.section == 0 ? SettingsPreferredMetadata : SettingsOtherMetadata)];
		int row = indexPath.row;
		localMetadata.name = [[metadata objectAtIndex:row] objectForKey:SettingsMetadataName];
		localMetadata.type = [[[metadata objectAtIndex:row] objectForKey:SettingsMetadataType] intValue];
		
		if(self.delegate.delegate)
		{
			[self.delegate.delegate metadataViewControllerAdd:self.delegate metadataInformation:&localMetadata];
		}
		[[self.delegate navigationController] popViewControllerAnimated:YES];
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	NSMutableArray *fromMetadata;
	NSMutableArray *toMetadata;
	// move the row
	fromMetadata = [[[Settings sharedInstance] userSettings] objectForKey:(fromIndexPath.section == 0 ? SettingsPreferredMetadata : SettingsOtherMetadata)];
	toMetadata = [[[Settings sharedInstance] userSettings] objectForKey:(toIndexPath.section == 0 ? SettingsPreferredMetadata : SettingsOtherMetadata)];
	NSMutableDictionary *entry = [[fromMetadata objectAtIndex:fromIndexPath.row] retain];
	[fromMetadata removeObjectAtIndex:fromIndexPath.row];
	[toMetadata insertObject:entry atIndex:toIndexPath.row];

	if(fromIndexPath.section != toIndexPath.section)
	{
		if(toIndexPath.section == 0)
		{
			// adding something to shown metadata
#warning fix me			
		}
		else
		{
			// remove something from shown metadata
#warning fix me			
		}
	}
	
	[entry release];
	[[Settings sharedInstance] saveData];																	
	
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
		cell = [[[UITableViewTitleAndValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:commonIdentifier] autorelease];
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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)metadataCustomViewControllerDone:(MetadataCustomViewController *)metadataCustomViewController
{
	NSMutableArray *metadata = [[[Settings sharedInstance] userSettings] objectForKey:(self.indexPath.section == 0 ? SettingsPreferredMetadata : SettingsOtherMetadata)];
	NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:metadataCustomViewController.name.text, SettingsMetadataName,
	         							                                           [NSNumber numberWithInt:metadataCustomViewController.type], SettingsMetadataType, nil];
	[metadata addObject:entry];
	[[Settings sharedInstance] saveData];																	
	
	MetadataCellController *cellController = [[MetadataCellController alloc] init];
	cellController.delegate = self.delegate;

	GenericTableViewSectionController *sectionController = [self.delegate.sectionControllers objectAtIndex:self.indexPath.section];
	[sectionController.cellControllers insertObject:cellController atIndex:(sectionController.cellControllers.count - 1)];
	[self.delegate updateWithoutReload];
}


// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// open up the custom metadata type
	self.indexPath = [[indexPath copy] autorelease];
	MetadataCustomViewController *p = [[[MetadataCustomViewController alloc] init] autorelease];
	p.delegate = self;
	
	[[self.delegate navigationController] pushViewController:p animated:YES];		
	return;
}


@end



@implementation MetadataViewController

@synthesize delegate;

+ (void)fixMetadata
{
	NSMutableArray *preferredMetadata = [[[Settings sharedInstance] userSettings] objectForKey:SettingsPreferredMetadata];
#warning so I goofed and sent out a beta build that had SettingsPreferredMetadata redefined and should have renamed it.... remove me after release
	if([preferredMetadata isKindOfClass:[NSString class]])
	{
		[[[Settings sharedInstance] userSettings] setObject:preferredMetadata forKey:SettingsSortedByMetadata];
		preferredMetadata = nil;
	}
// end remove	
	NSMutableArray *otherMetadata = [[[Settings sharedInstance] userSettings] objectForKey:SettingsOtherMetadata];
	NSMutableArray *metadata = [[[Settings sharedInstance] userSettings] objectForKey:SettingsMetadata];
	if(metadata != nil || otherMetadata == nil)
	{
		otherMetadata = [NSMutableArray array];
		for(int i = 0; i < ARRAY_SIZE(commonInformation); i++)
		{
			[otherMetadata addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:commonInformation[i].name, SettingsMetadataName, 
									  [NSNumber numberWithInt:commonInformation[i].type], SettingsMetadataType,
									  nil]];
		}
		[[[Settings sharedInstance] userSettings] setObject:otherMetadata forKey:SettingsOtherMetadata];
		[[[Settings sharedInstance] userSettings] removeObjectForKey:SettingsMetadata];
	}
	if(preferredMetadata == nil)
	{
		preferredMetadata = [NSMutableArray array];
		[[[Settings sharedInstance] userSettings] setObject:preferredMetadata forKey:SettingsPreferredMetadata];
	}
}

+ (NSArray *)metadataNames
{
	[[self class] fixMetadata];
	NSMutableArray *array = [NSMutableArray array];
	NSMutableArray *metadata = [[[Settings sharedInstance] userSettings] objectForKey:SettingsPreferredMetadata];
	[array addObjectsFromArray:[metadata valueForKey:SettingsMetadataName]];
	metadata = [[[Settings sharedInstance] userSettings] objectForKey:SettingsOtherMetadata];
	[array addObjectsFromArray:[metadata valueForKey:SettingsMetadataName]];
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

- (void)dealloc 
{
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
	
	self.tableView = nil;
	
	[super dealloc];
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

- (void)constructSectionControllers
{
	[[self class] fixMetadata];

	// we have to convert from the old style Metadata to the new one
	NSMutableArray *preferredMetadata = [[[Settings sharedInstance] userSettings] objectForKey:SettingsPreferredMetadata];
	NSMutableArray *otherMetadata = [[[Settings sharedInstance] userSettings] objectForKey:SettingsOtherMetadata];
	
	GenericTableViewSectionController *sectionController;
	self.sectionControllers = [NSMutableArray array];

	// preferred Metadata
	sectionController = [[GenericTableViewSectionController alloc] init];
	sectionController.title = NSLocalizedString(@"Information Always Shown", @"Title in the 'Additional Information' for the entries that will always show in every call");
	[self.sectionControllers addObject:sectionController];
	[sectionController release];

	for(NSMutableDictionary *entry in preferredMetadata)
	{
		MetadataCellController *cellController = [[MetadataCellController alloc] init];
		cellController.delegate = self;
		[sectionController.cellControllers addObject:cellController];
		[cellController release];
	}
	
	// other Metadata
	sectionController = [[GenericTableViewSectionController alloc] init];
	sectionController.title = NSLocalizedString(@"Other Information", @"Title in the 'Additional Information' for the entries that can be added per call");
	[self.sectionControllers addObject:sectionController];
	[sectionController release];

	for(NSMutableDictionary *entry in otherMetadata)
	{
		MetadataCellController *cellController = [[MetadataCellController alloc] init];
		cellController.delegate = self;
		[sectionController.cellControllers addObject:cellController];
		[cellController release];
	}
	// add the "Add Additional User" cell at the end
	AddMetadataCellController *addCellController = [[AddMetadataCellController alloc] init];
	addCellController.delegate = self;
	[sectionController.cellControllers addObject:addCellController];
	[addCellController release];
}



- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s respondsToSelector: %s", __FILE__, selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s methodSignatureForSelector: %s", __FILE__, selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"%s forwardInvocation: %s", __FILE__, [invocation selector]);)
    [super forwardInvocation:invocation];
}
@end
