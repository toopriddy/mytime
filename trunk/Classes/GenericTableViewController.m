//
//  GenericTableViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/11/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "GenericTableViewController.h"
#import "TableViewCellController.h"

#if __DEBUGGING__
#define DEBUG(a) a
#else
#define DEBUG(a)
#endif

/******************************************************************
 *
 *   NSObjectViewControllerAssociation
 *
 ******************************************************************/
#pragma mark NSObjectViewControllerAssociation
@interface NSObjectViewControllerAssociation : NSObject
{
	NSObject *retainee;
	UIViewController *viewController;
}
@property (nonatomic, retain) NSObject *retainee;
@property (nonatomic, assign) UIViewController *viewController;
- (NSObjectViewControllerAssociation *)initWithRetainee:(NSObject *)object viewController:(UIViewController *)theViewController;
@end
@implementation NSObjectViewControllerAssociation
@synthesize retainee;
@synthesize viewController;
- (NSObjectViewControllerAssociation *)initWithRetainee:(NSObject *)object viewController:(UIViewController *)theViewController
{
	if( (self = [super init]) )
	{
		self.retainee = object;
		self.viewController = theViewController;
	}
	return self;
}

- (void)dealloc
{
	[retainee release];
	
	[super dealloc];
}
@end


/******************************************************************
 *
 *   URLCellController
 *
 ******************************************************************/
#pragma mark URLCellController
@implementation URLCellController
@synthesize url = ps_url;
@synthesize title = ps_title;

- (id)initWithTitle:(NSString *)title
{
	return [self initWithTitle:title URL:nil];
}

- (id)initWithTitle:(NSString *)title URL:(NSURL *)url
{
	if( (self = [super init]) )
	{
		self.title = title;
		self.url = url;
	}
	return self;
}

- (void)dealloc
{
	self.title = nil;
	self.url = nil;
	[super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"URLCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textLabel.text = self.title;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[UIApplication sharedApplication] openURL:self.url];
}
@end

/******************************************************************
 *
 *   TitleValueCellController
 *
 ******************************************************************/
#pragma mark TitleValueCellController
@implementation TitleValueCellController
@synthesize value = ps_value;
@synthesize title = ps_title;

- (id)initWithTitle:(NSString *)title
{
	return [self initWithTitle:title value:@""];
}

- (id)initWithTitle:(NSString *)title value:(NSString *)value
{
	if( (self = [super init]) )
	{
		self.title = title;
		self.value = value;
	}
	return self;
}

- (void)dealloc
{
	self.title = nil;
	self.value = nil;
	[super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"TitleAndValueCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	cell.textLabel.text = self.title;
	cell.detailTextLabel.text = self.value;
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}
@end


/******************************************************************
 *
 *   GenericTableViewController
 *
 ******************************************************************/
#pragma mark GenericTableViewController
@interface GenericTableViewController ()
@property (nonatomic, retain) NSMutableArray *displaySectionControllers;
@property (nonatomic, retain) NSMutableArray *retainedObjectsAndViewControllers;
- (void)updateTableViewWithEditing:(BOOL)editing;
- (void)updateSectionController:(GenericTableViewSectionController *)sectionController insertRows:(BOOL)insertRows insertAnimation:(UITableViewRowAnimation)insertAnimation sectionNumber:(int)sectionNumber;
@end

@implementation GenericTableViewController
@synthesize sectionControllers = _sectionControllers;
@synthesize displaySectionControllers = _displaySectionControllers;
@synthesize forceReload = _forceReload;
@synthesize retainedObjectsAndViewControllers = _retainedObjectsAndViewControllers;

// Creates/updates cell data. This method should only be invoked directly if
// a "reloadData" needs to be avoided. Otherwise, updateAndReload should be used.
- (void)constructSectionControllers
{
	self.sectionControllers = [NSMutableArray array];
	self.displaySectionControllers = nil;
}

// make sure that if anyone tries to get these that these are initalized
- (NSMutableArray *)sectionControllers
{
	if(_sectionControllers == nil)
	{
		[self constructSectionControllers];
	}
	return [[_sectionControllers retain] autorelease];
}

- (void)constructDisplaySectionControllers
{
	[self constructSectionControllers];
	self.displaySectionControllers = [NSMutableArray array];
	SEL isViewableSelector = self.tableView.editing ? @selector(isViewableWhenEditing) : @selector(isViewableWhenNotEditing);
	
	for(GenericTableViewSectionController *sectionController in self.sectionControllers)
	{
		if([sectionController performSelector:isViewableSelector])
		{
			[self.displaySectionControllers addObject:sectionController];
			
			sectionController.displayCellControllers = [NSMutableArray array];
			for(NSObject<TableViewCellController> *cellController in sectionController.cellControllers)
			{
				if(![cellController respondsToSelector:isViewableSelector] || 
				   [cellController performSelector:isViewableSelector])
				{
					[sectionController.displayCellControllers addObject:cellController];
				}
			}
		}
	}
}

- (void)deleteDisplayRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"deleteDisplayRowAtIndexPath:%@", indexPath));
	GenericTableViewSectionController *sectionController = [self.displaySectionControllers objectAtIndex:indexPath.section];
	NSObject<TableViewCellController> *cellController = [sectionController.displayCellControllers objectAtIndex:indexPath.row];
	// remove the row from the list of all CellControllers
	[sectionController.cellControllers removeObjectIdenticalTo:cellController];
	// remove the row from the list of displayed CellControllers
	[sectionController.displayCellControllers removeObjectAtIndex:indexPath.row];
	
	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)deleteDisplaySectionAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"deleteDisplaySectionAtIndexPath:%@", indexPath));
	GenericTableViewSectionController *sectionController = [self.displaySectionControllers objectAtIndex:indexPath.section];
	// remove the row from the list of all SectionControllers
	[self.sectionControllers removeObjectIdenticalTo:sectionController];
	// remove the row from the list of displayed SectionControllers
	[self.displaySectionControllers removeObjectAtIndex:indexPath.section];
	
	[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)replaceDisplaySectionAtIndexPath:(NSIndexPath *)indexPath withSection:(GenericTableViewSectionController *)newSectionController
{
	DEBUG(NSLog(@"replaceDisplaySectionAtIndexPath:%@ withSection:%@", indexPath, newSectionController.title));
	GenericTableViewSectionController *sectionController = [self.displaySectionControllers objectAtIndex:indexPath.section];
	// remove the row from the list of all SectionControllers
	int section = [self.sectionControllers indexOfObjectIdenticalTo:sectionController];
	[self.sectionControllers removeObjectAtIndex:section];
	// put the new one in its place.
	[self.sectionControllers insertObject:newSectionController atIndex:section];

	// remove the row from the list of displayed SectionControllers
	[self.displaySectionControllers removeObjectAtIndex:indexPath.section];

	// now to deal with the animations.
	[self.tableView beginUpdates];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];

		if((newSectionController.isViewableWhenEditing && self.tableView.editing) ||
		   (newSectionController.isViewableWhenNotEditing && !self.tableView.editing))
		{
			// put the new one in its place.
			[self.displaySectionControllers insertObject:newSectionController atIndex:indexPath.section];
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationRight];
			[self updateSectionController:newSectionController insertRows:NO insertAnimation:UITableViewRowAnimationRight sectionNumber:section];
		}
	[self.tableView endUpdates];
}

- (void)addSectionAfterSection:(GenericTableViewSectionController *)sectionController newSection:(GenericTableViewSectionController *)newSectionController
{
	DEBUG(NSLog(@"addSectionAfterSection:%@ withSection:%@", sectionController.title, newSectionController.title));
	int index = [self.displaySectionControllers indexOfObject:sectionController] + 1;
	
	// remove the row from the list of all SectionControllers
	int section = [self.sectionControllers indexOfObjectIdenticalTo:sectionController] + 1;
	
	// put the new one in its place.
	[self.sectionControllers insertObject:newSectionController atIndex:section];
	
	// now to deal with the animations.
	[self.tableView beginUpdates];
	if((newSectionController.isViewableWhenEditing && self.tableView.editing) ||
	   (newSectionController.isViewableWhenNotEditing && !self.tableView.editing))
	{
		// put the new one in its place.
		[self.displaySectionControllers insertObject:newSectionController atIndex:index];
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationRight];
		[self updateSectionController:newSectionController insertRows:NO insertAnimation:UITableViewRowAnimationRight sectionNumber:section];
	}
	[self.tableView endUpdates];
}


// updateAndReload
- (void)updateAndReload
{
	[self constructSectionControllers];
	[self.tableView reloadData];
}

- (void)updateWithoutReload
{
	[self updateTableViewWithEditing:self.tableView.editing];
}


- (BOOL)editing
{
	return self.tableView.editing;
}

- (void)setEditing:(BOOL)editing
{
	BOOL wasEditing = self.tableView.editing;
	
	if(editing == wasEditing)
		return;

	[self updateTableViewWithEditing:editing];
}

- (void)updateSectionController:(GenericTableViewSectionController *)sectionController insertRows:(BOOL)insertRows insertAnimation:(UITableViewRowAnimation)insertAnimation sectionNumber:(int)sectionNumber
{
	SEL isViewableSelector = _editing ? @selector(isViewableWhenEditing) : @selector(isViewableWhenNotEditing);
	
	NSMutableArray *viewableRows = [[NSMutableArray alloc] initWithCapacity:self.displaySectionControllers.count];
	int rowNumber = 0;
	NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:self.displaySectionControllers.count];
	NSEnumerator *currentDisplayCellEnumerator = [sectionController.displayCellControllers objectEnumerator];
	NSObject<TableViewCellController> *currentDisplayCellController = [currentDisplayCellEnumerator nextObject];
	// just check to see if any of the rows need to be inserted
	for(NSObject<TableViewCellController> *cellController in sectionController.cellControllers)
	{
		// If this is not a row currently displayed check, otherwise just move onto the next one
		if(![cellController isEqual:currentDisplayCellController])
		{
			if(![cellController respondsToSelector:isViewableSelector] ||
			   [cellController performSelector:isViewableSelector])
			{
				DEBUG(NSLog(@"Row #%d in Section#%d %@ added", rowNumber, sectionNumber, sectionController.title));
				[insertIndexPaths addObject:[NSIndexPath indexPathForRow:rowNumber inSection:sectionNumber]];
				[viewableRows addObject:cellController];
				rowNumber++;
			}
		}
		else
		{
			currentDisplayCellController = [currentDisplayCellEnumerator nextObject];
			[viewableRows addObject:cellController];
			rowNumber++;
		}
	}
	if(insertIndexPaths.count && insertRows)
	{
		[self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:insertAnimation];
	}
	sectionController.displayCellControllers = viewableRows;
	[viewableRows release];
	
}

- (void)updateTableViewInsideUpdateBlockWithDeleteRowAnimation:(UITableViewRowAnimation)deleteAnimation insertAnimation:(UITableViewRowAnimation)insertAnimation
{
	DEBUG(NSLog(@"updateTableViewInsideUpdateBlockWithDeleteRowAnimation:"));
	NSMutableArray *stillViewableSections = [NSMutableArray arrayWithCapacity:self.sectionControllers.count];
	
	DEBUG(NSLog(@"Displaying %d sections out of %d possible sections", self.displaySectionControllers.count, self.sectionControllers.count));
	SEL isViewableSelector = _editing ? @selector(isViewableWhenEditing) : @selector(isViewableWhenNotEditing);
	int rowNumber;
	int sectionNumber = self.displaySectionControllers.count;
	// go through in reverse order DELETING sections and rows
	for(GenericTableViewSectionController *sectionController in [self.displaySectionControllers reverseObjectEnumerator])
	{
		--sectionNumber;
		// we first blow away any sections that need to be deleted, we dont need to 
		// bother deleting the rows from these
		if(![sectionController performSelector:isViewableSelector])
		{
			DEBUG(NSLog(@"Section #%d %@ removed", sectionNumber, sectionController.title));
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionNumber] withRowAnimation:deleteAnimation];
			continue;
		}
		// since we are going through in reverse order, put it at the beginning 
		[stillViewableSections insertObject:sectionController atIndex:0];
		
		NSMutableArray *stillViewableRows = [[NSMutableArray alloc] initWithCapacity:self.displaySectionControllers.count];
		rowNumber = sectionController.displayCellControllers.count;
		NSMutableArray *deleteIndexPaths = [NSMutableArray arrayWithCapacity:self.displaySectionControllers.count];
		// now lets go through the rows in this section in reverse order to remove those that dont want to be shown
		for(NSObject<TableViewCellController> *cellController in [sectionController.displayCellControllers reverseObjectEnumerator])
		{
			--rowNumber;
			if([cellController respondsToSelector:isViewableSelector] && 
			   ![cellController performSelector:isViewableSelector])
			{
				DEBUG(NSLog(@"Row #%d in Section#%d %@ removed", rowNumber, sectionNumber, sectionController.title));
				[deleteIndexPaths addObject:[NSIndexPath indexPathForRow:rowNumber inSection:sectionNumber]];
			}
			else
			{
				// since we are going through in reverse order, put it at the beginning 
				[stillViewableRows insertObject:cellController atIndex:0];
			}
		}
		if(deleteIndexPaths.count)
			[self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:deleteAnimation];
		sectionController.displayCellControllers = stillViewableRows;
		[stillViewableRows release];
	}
	
	NSMutableArray *viewableSections = [NSMutableArray arrayWithCapacity:self.sectionControllers.count];
	
	// go through in forward order ADDING sections and rows
	sectionNumber = 0;
	NSEnumerator *currentDisplaySectionEnumerator = [stillViewableSections objectEnumerator];
	GenericTableViewSectionController *currentDisplaySectionController = [currentDisplaySectionEnumerator nextObject];
	for(GenericTableViewSectionController *sectionController in self.sectionControllers)
	{
		// if this is a new section, see if it needs to be added, otherwise see what has changed
		if(![sectionController isEqual:currentDisplaySectionController])
		{
			if([sectionController performSelector:isViewableSelector])
			{
				DEBUG(NSLog(@"Section #%d %@ added", sectionNumber, sectionController.title));
				[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionNumber] withRowAnimation:insertAnimation];
				// since we are adding this new section, update its displayCellControllers
				[self updateSectionController:sectionController insertRows:NO insertAnimation:insertAnimation sectionNumber:sectionNumber];
				[viewableSections addObject:sectionController];
				sectionNumber++;
			}
		}
		else
		{
			[viewableSections addObject:sectionController];
			
			[self updateSectionController:sectionController insertRows:YES insertAnimation:insertAnimation sectionNumber:sectionNumber];
			
			currentDisplaySectionController = [currentDisplaySectionEnumerator nextObject];
			sectionNumber++;
		}		
	}		
	self.displaySectionControllers = viewableSections;
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)updateTableViewWithEditing:(BOOL)editing
{
	DEBUG(NSLog(@"updateTableViewWithEditing:(BOOL)editing = %d", editing));

	[self.tableView beginUpdates];
	if(self.tableView.editing != editing)
	{
		_editing = editing;
		self.tableView.editing = editing;		
	}
	
	[self updateTableViewInsideUpdateBlockWithDeleteRowAnimation:UITableViewRowAnimationFade insertAnimation:UITableViewRowAnimationFade];
	
	[self.tableView endUpdates];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	DEBUG(NSLog(@"tableView: titleForHeaderInSection:%d", section));

	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	NSObject<TableViewSectionController> *sectionController = [self.displaySectionControllers objectAtIndex:section];
	return [sectionController tableView:tableView titleForHeaderInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	DEBUG(NSLog(@"tableView: titleForFooterInSection:%d", section));

	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	NSObject<TableViewSectionController> *sectionController = [self.displaySectionControllers objectAtIndex:section];
	return [sectionController tableView:tableView titleForFooterInSection:section];
}

//////////////////////////////////
// UITableViewDataSource functions
//////////////////////////////////


// Return the number of sections for the table.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if(!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	int count = [self.displaySectionControllers count];
	if(count == 0)
		count = 1;
	DEBUG(NSLog(@"tableView: numberOfSectionsInTableView: = %d", count));
	return count;
}

// Returns the number of rows in a given section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	DEBUG(NSLog(@"tableView: numberOfRowsInSection:%d", section));
	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	int count = [[self.displaySectionControllers objectAtIndex:section] tableView:tableView numberOfRowsInSection:section];
	
	DEBUG(NSLog(@"tableView: numberOfRowsInSection:%d = %u", section, count));
	return count;
}


// Returns the cell for a given indexPath.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"tableView: cellForRowAtIndexPath:%@", indexPath));
	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	return [[[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath] tableView:tableView cellForRowAtIndexPath:indexPath];
}

// Editing

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"tableView: canEditRowAtIndexPath:%@", indexPath));
	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)])
	{
		return [cellData tableView:tableView canEditRowAtIndexPath:indexPath];
	}
	
	// default is YES
	return YES;
}

// Moving/reordering

// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"tableView: canMoveRowAtIndexPath:%@", indexPath));
	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)])
	{
		return [cellData tableView:tableView canMoveRowAtIndexPath:indexPath];
	}

	// default is NO
	return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	DEBUG(NSLog(@"tableView: cellForRowAtIndexPath:%@ toIndexPath:%@", fromIndexPath, toIndexPath));
	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:fromIndexPath.section] tableView:tableView cellControllerAtIndexPath:fromIndexPath];
	if ([cellData respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)])
	{
		return [cellData tableView:tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
	}
}


// Data manipulation - insert and delete support

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"tableView: commitEditingStyle: forRowAtIndexPath:%@", indexPath));
	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)])
	{
		[cellData tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
	}
}


////////////////////////////////
// UITableViewDelegate functions
////////////////////////////////

// Display customization

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"tableView: willDisplayCell: forRowAtIndexPath:%@", indexPath));
	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:willDisplayCell:forRowAtIndexPath:)])
	{
		[cellData tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
	}
}

// Variable height support

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"tableView: heightForRowAtIndexPath:%@", indexPath));
	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
	{
		return [cellData tableView:tableView heightForRowAtIndexPath:indexPath];
	}
	return tableView.rowHeight;
}

// Accessories (disclosures). 

// When the editing state changes, these methods will be called again to allow the accessory to be hidden when editing, if required.
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"tableView: accessoryButtonTappedForRowWithIndexPath:%@", indexPath));
	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)])
	{
		[cellData tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
	}
#if 0	
	else if ([cellData respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
	{
		// go ahead and make the default behaviour of the accessory click be like you clicked the row
		[cellData tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
#endif
}

// Selection

// Called before the user changes the selection. Returning a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"tableView: willSelectRowAtIndexPath:%@", indexPath));
	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)])
	{
		return [cellData tableView:tableView willSelectRowAtIndexPath:indexPath];
	}
	
	return indexPath;
}

//
// tableView:didSelectRowAtIndexPath:
//
// Called after the user changes the selection.
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"tableView: didSelectRowAtIndexPath:%@", indexPath));
	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
	{
		[cellData tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}

// Editing

// Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"tableView: editingStyleForRowAtIndexPath:%@", indexPath));
	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)])
	{
		return [cellData tableView:tableView editingStyleForRowAtIndexPath:indexPath];
	}
	
	if(tableView.editing)
		return UITableViewCellEditingStyleDelete;

	return UITableViewCellEditingStyleNone;
}

// Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"tableView: shouldIndentWhileEditingRowAtIndexPath:%@", indexPath));
	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)])
	{
		return [cellData tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
	}
	
	return YES;
}

// The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"tableView: willBeginEditingRowAtIndexPath:%@", indexPath));
	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:willBeginEditingRowAtIndexPath:)])
	{
		[cellData tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"tableView: didEndEditingRowAtIndexPath:%@", indexPath));
	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:didEndEditingRowAtIndexPath:)])
	{
		[cellData tableView:tableView didEndEditingRowAtIndexPath:indexPath];
	}
}

// Indentation

// return 'depth' of row for hierarchies
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"tableView: indentationLevelForRowAtIndexPath:%@", indexPath));
	if (!self.displaySectionControllers)
	{
		[self constructDisplaySectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:indentationLevelForRowAtIndexPath:)])
	{
		return [cellData tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
	}
	
	return 0;
}

- (void)setTableView:(UITableView *)tableView
{
	tableView.delegate = self;
	tableView.dataSource = self;
	[super setTableView:tableView];
}

//
// didReceiveMemoryWarning
//
// Release any cache data.
//
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)setForceReload:(BOOL)enable
{
	_forceReload = enable;
	if(_forceReload && _displaySectionControllers)
	{
		[self updateAndReload];
	}
}

- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}	

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];

	if(self.forceReload)
	{
		self.forceReload = NO;
		[self updateAndReload];
	}
}	

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self updateWithoutReload];
}

- (void)loadView 
{
	[super loadView];
	self.tableView.editing = _editing;
	self.tableView.allowsSelectionDuringEditing = YES;
	
	// set the autoresizing mask so that the table will always fill the view
	self.tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	// set the tableview as the controller view
	//	self.view = self.tableView;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	if( (self = [super initWithStyle:style]) )
	{
		_editing = NO;
	}
	return self;
}

- (NSMutableArray *)retainedObjectsAndViewControllers
{
	if(_retainedObjectsAndViewControllers)
		return _retainedObjectsAndViewControllers;

	_retainedObjectsAndViewControllers = [[NSMutableArray alloc] init];
	
	return _retainedObjectsAndViewControllers;
}

- (void)checkRetainedObjects
{
	// see if we need to continue checking
	if([self.retainedObjectsAndViewControllers count] == 0)
	{
		self.retainedObjectsAndViewControllers = nil;
		_viewControllerCheckerRunning = NO;
		return;
	}
	
	// go through all of the currently visible view controllers and see if we still need to keep a reference count
	NSArray *viewControllers = [self.navigationController viewControllers];
	NSMutableArray *removeArray = nil;
	for(NSObjectViewControllerAssociation *association in self.retainedObjectsAndViewControllers)
	{
		BOOL found = NO;
		UIViewController *test = association.viewController;
		for(UIViewController *viewController in viewControllers)
		{
			if(viewController == test)
			{
				found = YES;
				break;
			}
		}
		if(!found)
		{
			if(removeArray == nil)
			{
				removeArray = [NSMutableArray array];
			}
			[removeArray addObject:association];
		}
	}
	
	if(removeArray)
	{
		[self.retainedObjectsAndViewControllers removeObjectsInArray:removeArray];
	}
	[self performSelector:@selector(checkRetainedObjects) withObject:nil afterDelay:1.0];
}

- (void)retainObject:(NSObject *)object whileViewControllerIsManaged:(UIViewController *)viewController
{
	NSObjectViewControllerAssociation *obj = [[NSObjectViewControllerAssociation alloc] initWithRetainee:object viewController:viewController];
	[self.retainedObjectsAndViewControllers addObject:obj];
	[obj release];
	if(!_viewControllerCheckerRunning)
	{
		_viewControllerCheckerRunning = YES;
		[self performSelector:@selector(checkRetainedObjects) withObject:nil afterDelay:1.0];
	}
}

//
// dealloc
//
// Release instance memory
//
- (void)dealloc
{
	self.sectionControllers = nil;
	self.displaySectionControllers = nil;
	self.retainedObjectsAndViewControllers = nil;
	
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;	
	self.tableView = nil;
	
	[super dealloc];
}

@end

