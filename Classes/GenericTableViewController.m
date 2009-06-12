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
#import "GenericTableViewSectionController.h"
#import "TableViewCellController.h"

@interface GenericTableViewController ()
@property (nonatomic, retain) NSMutableArray *displaySectionControllers;
@end

@implementation GenericTableViewController
@synthesize sectionControllers = _sectionControllers;
@synthesize displaySectionControllers = _displaySectionControllers;

// Creates/updates cell data. This method should only be invoked directly if
// a "reloadData" needs to be avoided. Otherwise, updateAndReload should be used.
- (void)constructSectionControllers
{
	self.sectionControllers = [NSMutableArray array];
}

// updateAndReload
- (void)updateAndReload
{
	self.sectionControllers = nil;
	[self constructSectionControllers];
	[self.tableView reloadData];
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

	NSMutableArray *stillViewableSections = [NSMutableArray arrayWithCapacity:self.sectionControllers.count];
	NSMutableArray *deleteIndexPaths = [NSMutableArray arrayWithCapacity:self.displaySectionControllers.count];

	[self.tableView beginUpdates];
	
	SEL isViewableSelector = editing ? @selector(isViewableWhenEditing) : @selector(isViewableWhenNotEditing);
	int rowNumber;
	int sectionNumber = self.displaySectionControllers.count;
	// go through in reverse order DELETING sections and rows
	for(GenericTableViewSectionController *sectionController in [self.displaySectionControllers reverseObjectEnumerator])
	{
		--sectionNumber;
		// we first blow away any sections that need to be deleted, we dont need to 
		// bother deleting the rows from these
		if([sectionController respondsToSelector:isViewableSelector] && 
		   [sectionController performSelector:isViewableSelector])
		{
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionNumber] withRowAnimation:UITableViewRowAnimationFade];
			continue;
		}
		[stillViewableSections addObject:sectionController];

		NSMutableArray *stillViewableRows = [[NSMutableArray alloc] initWithCapacity:self.displaySectionControllers.count];
		rowNumber = sectionController.displayCellControllers.count;
		// now lets go through the rows in this section in reverse order to remove those that dont want to be shown
		for(NSObject<TableViewCellController> *cellController in [sectionController.displayCellControllers reverseObjectEnumerator])
		{
			--rowNumber;
			if([sectionController respondsToSelector:isViewableSelector] && 
			   [sectionController performSelector:isViewableSelector])
			{
				[deleteIndexPaths addObject:[NSIndexPath indexPathForRow:rowNumber inSection:sectionNumber]];
			}
			else
			{
				[stillViewableRows addObject:cellController];
			}
		}
		[self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
		sectionController.displayCellControllers = stillViewableRows;
		[stillViewableRows release];
		[deleteIndexPaths removeAllObjects];
	}

	NSMutableArray *insertIndexPaths = deleteIndexPaths; // reuse memory
	NSMutableArray *viewableSections = [NSMutableArray arrayWithCapacity:self.sectionControllers.count];
	
	// go through in forward order ADDING sections and rows
	sectionNumber = 0;
	NSEnumerator *currentDisplaySectionEnumerator = [stillViewableSections objectEnumerator];
	GenericTableViewSectionController *currentDisplaySectionController = [currentDisplaySectionEnumerator nextObject];
	for(GenericTableViewSectionController *sectionController in self.sectionControllers)
	{
		// if this is a new section, see if it needs to be added, otherwise see what has changed
		if(![sectionController isEqualTo:currentDisplaySectionController])
		{
			if([sectionController respondsToSelector:isViewableSelector] && 
			   [sectionController performSelector:isViewableSelector])
			{
				[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionNumber] withRowAnimation:UITableViewRowAnimationFade];
				[viewableSections addObject:sectionController];
				sectionNumber++;
			}
		}
		else
		{
			[viewableSections addObject:sectionController];

			NSMutableArray *viewableRows = [[NSMutableArray alloc] initWithCapacity:self.displaySectionControllers.count];
			rowNumber = 0;
			// just check to see if any of the rows need to be inserted
			for(NSObject<TableViewCellController> *cellController in sectionController.cellControllers)
			{
				// If this is not a row currently displayed check, otherwise just move onto the next one
				if(![sectionController isEqualTo:currentDisplaySectionController])
				{
					if([sectionController respondsToSelector:isViewableSelector] && 
					   [sectionController performSelector:isViewableSelector])
					{
						[insertIndexPaths addObject:[NSIndexPath indexPathForRow:rowNumber inSection:sectionNumber]];
						[viewableRows addObject:cellController];
						rowNumber++;
					}
				}
				else
				{
					[viewableRows addObject:cellController];
					rowNumber++;
				}
			}
			[self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
			sectionController.displayCellControllers = viewableRows;
			[viewableRows release];
			[insertIndexPaths removeAllObjects];
			
			sectionNumber++;
		}
	}		
	self.displaySectionControllers = viewableSections;
	
	self.tableView.editing = editing;		
	
	[self.tableView endUpdates];
}

//////////////////////////////////
// UITableViewDataSource functions
//////////////////////////////////


// Return the number of sections for the table.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if(!self.sectionControllers)
	{
		[self constructSectionControllers];
	}
	int count = [self.sectionControllers count];
	if(count == 0)
		count = 1;
	return count;
}

// Returns the number of rows in a given section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (!self.sectionControllers)
	{
		[self constructSectionControllers];
	}
	
	return [[self.sectionControllers objectAtIndex:section] count];
}


// Returns the cell for a given indexPath.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!self.sectionControllers)
	{
		[self constructSectionControllers];
	}
	
	return [[[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath] tableView:tableView cellForRowAtIndexPath:indexPath];
}

// Editing

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!self.sectionControllers)
	{
		[self constructSectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)])
	{
		return [cellData tableView:tableView canEditRowAtIndexPath:indexPath];
	}
	
	// default is NO
	return NO;
}

// Moving/reordering

// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!self.sectionControllers)
	{
		[self constructSectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:canMoveRowAtIndexPath:)])
	{
		return [cellData tableView:tableView canMoveRowAtIndexPath:indexPath];
	}

	// default is NO
	return NO;
}

// Data manipulation - insert and delete support

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!self.sectionControllers)
	{
		[self constructSectionControllers];
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
	if (!self.sectionControllers)
	{
		[self constructSectionControllers];
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
	if (!self.sectionControllers)
	{
		[self constructSectionControllers];
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
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	if (!self.sectionControllers)
	{
		[self constructSectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:accessoryTypeForRowWithIndexPath:)])
	{
		return [cellData tableView:tableView accessoryTypeForRowWithIndexPath:indexPath];
	}
	
	return UITableViewCellAccessoryNone;
}


// When the editing state changes, these methods will be called again to allow the accessory to be hidden when editing, if required.
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	if (!self.sectionControllers)
	{
		[self constructSectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)])
	{
		[cellData tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
	}
}

// Selection

// Called before the user changes the selection. Returning a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!self.sectionControllers)
	{
		[self constructSectionControllers];
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
	if (!self.sectionControllers)
	{
		[self constructSectionControllers];
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
	if (!self.sectionControllers)
	{
		[self constructSectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:editingStyleForRowAtIndexPath:)])
	{
		return [cellData tableView:tableView editingStyleForRowAtIndexPath:indexPath];
	}
	
	if([tableView cellForRowAtIndexPath:indexPath].editing)
		return UITableViewCellEditingStyleDelete;

	return UITableViewCellEditingStyleNone;
}

// Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!self.sectionControllers)
	{
		[self constructSectionControllers];
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
	if (!self.sectionControllers)
	{
		[self constructSectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:willBeginEditingRowAtIndexPath:)])
	{
		[cellData tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
	}
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!self.sectionControllers)
	{
		[self constructSectionControllers];
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
	if (!self.sectionControllers)
	{
		[self constructSectionControllers];
	}
	
	NSObject<TableViewCellController> *cellData = [[self.displaySectionControllers objectAtIndex:indexPath.section] tableView:tableView cellControllerAtIndexPath:indexPath];
	if ([cellData respondsToSelector:@selector(tableView:indentationLevelForRowAtIndexPath:)])
	{
		return [cellData tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
	}
	
	return 0;
}




//
// didReceiveMemoryWarning
//
// Release any cache data.
//
- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	
	self.sectionControllers = nil;
}
//
// dealloc
//
// Release instance memory
//
- (void)dealloc
{
	self.sectionControllers = nil;
	[super dealloc];
}

@end

