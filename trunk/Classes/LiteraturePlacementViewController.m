//
//  LiteraturePlacementViewController.m
//  MyTime
//
//  Created by Brent Priddy on 8/15/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "LiteraturePlacementViewController.h"
#import "UITableViewTitleAndValueCell.h"
#import "DatePickerViewController.h"
#import "PublicationViewController.h"
#import "PublicationTypeViewController.h"
#import "PSDateCellController.h"
#import "MTPublication.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSLocalization.h"

/* NSMutableArray bulkLiterature
 *     NSMutableDictionary
 *            NSCalendarDate date
 *            NSArray literature
 *                   NSMutableDictionary
 *                          NSIteger count
 *							NSString title
 *							NSString name
 *							NSInteger year
 *							NSInteger month
 *							NSInteger day
 * these are the standard names for the elements in the Call NSMutableDictionary
 */

/******************************************************************
 *
 *   PUBLICATION
 *
 ******************************************************************/
#pragma mark BulkPlacementPublicationCellController

@interface BulkPlacementPublicationCellController : NSObject<TableViewCellController, PublicationViewControllerDelegate, PublicationTypeViewControllerDelegate>
{
	LiteraturePlacementViewController *delegate;
	MTPublication *publication;
	NSIndexPath *selectedIndexPath;
}
@property (nonatomic, retain) MTPublication *publication;
@property (nonatomic, assign) LiteraturePlacementViewController *delegate;
@property (nonatomic, copy) NSIndexPath *selectedIndexPath;
@end

@implementation BulkPlacementPublicationCellController
@synthesize publication;
@synthesize delegate;
@synthesize selectedIndexPath;

- (void)dealloc
{
	self.selectedIndexPath = nil;
	self.publication = nil;
	[super dealloc];
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		// this is the entry that we need to delete
		[self.publication.managedObjectContext deleteObject:self.publication];
		
		// save the data
		NSError *error = nil;
		if(![self.publication.managedObjectContext save:&error])
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		
		[[self retain] autorelease];
		[self.delegate deleteDisplayRowAtIndexPath:indexPath];
	}
	else if(editingStyle == UITableViewCellEditingStyleInsert)
	{
		[self tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}


- (void)publicationViewControllerDone:(PublicationViewController *)publicationViewController
{
	MTPublication *editedPublication = self.publication;
	bool newPublication = (editedPublication == nil);
    if(newPublication)
    {
        // if we are adding a publication then create the NSDictionary and add it to the end
        // of the publications array
		editedPublication = [MTPublication createPublicationForBulkPlacement:self.delegate.bulkPlacement];
    }
	PublicationPickerView *picker = [publicationViewController publicationPicker];
	
    editedPublication.name = [picker publication];
    editedPublication.title = [picker publicationTitle];
    editedPublication.type = [picker publicationType];
    editedPublication.yearValue = [picker year];
    editedPublication.monthValue = [picker month];
    editedPublication.dayValue =  [picker day];
    editedPublication.countValue =  [publicationViewController count];
	
	// save the data
	NSError *error = nil;
	if(![editedPublication.managedObjectContext save:&error])
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	
	if(newPublication)
	{
		// PUBLICATION
		BulkPlacementPublicationCellController *cellController = [[[BulkPlacementPublicationCellController alloc] init] autorelease];
		cellController.delegate = self.delegate;
		cellController.publication = editedPublication;
		[[[self.delegate.displaySectionControllers objectAtIndex:self.selectedIndexPath.section] cellControllers] insertObject:cellController atIndex:self.selectedIndexPath.row];
		
		[self.delegate updateWithoutReload];
	}
	else
	{
		
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
	}		
	[[self.delegate navigationController] popToViewController:self.delegate animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.publication != nil ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleInsert;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.publication)
	{
		UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:@"PublicationCell"];
		if(cell == nil)
		{
			cell = [[[UITableViewTitleAndValueCell alloc ] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PublicationCell"] autorelease];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.allowSelectionWhenNotEditing = NO;
		}
		
		NSString *name = self.publication.title;
		name = [[PSLocalization localizationBundle] localizedStringForKey:name value:name table:@""];
		int count = [self.publication.count intValue];
		NSString *type = self.publication.type;
		type = [[PSLocalization localizationBundle] localizedStringForKey:type value:type table:@""];
		if([type isEqualToString:NSLocalizedString(@"Magazine", @"Publication Type name")] ||
		   [type isEqualToString:NSLocalizedString(@"TwoMagazine", @"Publication Type name")])
		{
			[cell setTitle:[NSString stringWithFormat:NSLocalizedString(@"%d: %@", @"Short form of Bulk Magazine Placements for the Watchtower and Awake '%d: %@'"), count, name]];
		}
		else
		{
			if(count == 1)
			{
				[cell setTitle:[NSString stringWithFormat:NSLocalizedString(@"%d %@: %@", @"Singular form of '1 Brochure: The Trinity' with the format '%d %@: %@', the %@ represents the Magazine, Book, or Brochure type and the %d represents the count of publications"), count, type, name]];
			}
			else
			{	
				[cell setTitle:[NSString stringWithFormat:NSLocalizedString(@"%d %@s: %@", @"Plural form of '2 Brochures: The Trinity' with the format '%d %@s: %@' notice the 's' in the middle for the plural form, the %@ represents the Magazine, Book, or Brochure type and the %d represents the count of publications"), count, type, name]];
			}
		}
		
		return cell;
	}
	else
	{
		
		UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:@"AddPublicationCell"];
		if(cell == nil)
		{
			cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddPublicationCell"] autorelease];
			cell.editingAccessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			[cell setValue:NSLocalizedString(@"Add placed publications", @"Action Button in the Day's Bulk Literature Placement View called 'Add placed publications'")];
		}
		return cell;
	}
}


// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.selectedIndexPath = [[indexPath copy] autorelease];
	if(self.publication)
	{
		// make the new call view 
		PublicationViewController *p = [[[PublicationViewController alloc] initWithPublication:self.publication.name
																						  year:self.publication.yearValue
																						 month:self.publication.monthValue
																						   day:self.publication.dayValue
																					 showCount:YES
																						number:self.publication.countValue] autorelease];
		
		p.delegate = self;
		[[self.delegate navigationController] pushViewController:p animated:YES];
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
	else
	{
		// make the new call view 
		PublicationTypeViewController *p = [[[PublicationTypeViewController alloc] initShowingCount:YES] autorelease];
		p.delegate = self;
		
		[[self.delegate navigationController] pushViewController:p animated:YES];		
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
}

@end




@implementation LiteraturePlacementViewController
@synthesize delegate;
@synthesize selectedIndexPath;
@synthesize bulkPlacement;

- (id)initWithBulkPlacement:(MTBulkPlacement *)theBulkPlacement;
{
	if ([super initWithStyle:UITableViewStyleGrouped]) 
	{
		self.hidesBottomBarWhenPushed = YES;
		self.bulkPlacement = theBulkPlacement;
		
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Placements", @"View Title and ButtonBar Title for the Day's Bulk Placed Publications");
	}
	return self;
}


- (void)dealloc 
{
	self.selectedIndexPath = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)navigationControlDone:(id)sender 
{
	NSLog(@"navigationControlDone:");
	if(delegate)
	{
		[delegate literaturePlacementViewControllerDone:self];
	}
}

- (void)loadView 
{
	[super loadView];
	
	self.editing = YES;
	self.tableView.allowsSelectionDuringEditing = YES;
	
	// add + button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];
	self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
	[self.tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	// force the tableview to load
	[tableView reloadData];
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];
	
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		{
			// Street Date
			PSDateCellController *cellController = [[[PSDateCellController alloc] init] autorelease];
			cellController.model = self.bulkPlacement;
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
	}
	
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		sectionController.editingTitle = NSLocalizedString(@"Placements:", @"Placements Group title for the Day's Bulk Literature Placements");
		[sectionController release];
		
		NSArray *publications = [self.bulkPlacement.managedObjectContext fetchObjectsForEntityName:[MTPublication entityName]
															  propertiesToFetch:nil 
															withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES] ]
																  withPredicate:@"bulkPlacement == %@", self.bulkPlacement];
		for(MTPublication *publication in publications)
		{
			// Add Territory Street
			BulkPlacementPublicationCellController *cellController = [[BulkPlacementPublicationCellController alloc] init];
			cellController.delegate = self;
			cellController.publication = publication;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
		{
			// Add Territory Street
			BulkPlacementPublicationCellController *cellController = [[BulkPlacementPublicationCellController alloc] init];
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
		
	}
}






@end