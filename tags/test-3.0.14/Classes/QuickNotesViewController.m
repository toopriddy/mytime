//
//  QuickNotesViewController.m
//  MyTime
//
//  Created by Brent Priddy on 8/21/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "QuickNotesViewController.h"
#import "TableViewCellController.h"
#import "UITableViewTitleAndValueCell.h"
#import "GenericTableViewSectionController.h"
#import "UITableViewMultilineTextCell.h"
#import "MTUser.h"
#import "MTReturnVisit.h"
#import "MTPresentation.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSLocalization.h"

@interface QuickNotesCellController : NSObject<TableViewCellController>
{
	QuickNotesViewController *delegate;
}
@property (nonatomic, assign) QuickNotesViewController *delegate;
@end
@implementation QuickNotesCellController
@synthesize delegate;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}
@end





/******************************************************************
 *
 *   JustAddNoteSectionController
 *
 ******************************************************************/
#pragma mark JustAddNoteSectionController

@interface JustAddNoteSectionController : GenericTableViewSectionController
{
}
@end
@implementation JustAddNoteSectionController
- (BOOL)isViewableWhenEditing
{
	return NO;
}
@end


/******************************************************************
 *
 *   JustAddNoteCellController
 *
 ******************************************************************/
#pragma mark JustAddNoteCellController
@interface JustAddNoteCellController : QuickNotesCellController<NotesViewControllerDelegate>
{
}
@end
@implementation JustAddNoteCellController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *commonIdentifier = @"JustAddNotesCell";
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	
	cell.textLabel.text = NSLocalizedString(@"Create a note from scratch", @"More View Table Enable shown popups");
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// make the new call view 
	NotesViewController *p = [[[NotesViewController alloc] initWithNotes:@""] autorelease];
	p.delegate = self;
	[[self.delegate navigationController] pushViewController:p animated:YES];		
	[self.delegate retainObject:self whileViewControllerIsManaged:p];
}

- (void)notesViewControllerDone:(NotesViewController *)notesViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	if(self.delegate.delegate && [self.delegate.delegate respondsToSelector:@selector(notesViewControllerDone:)])
	{
		[self.delegate.delegate notesViewControllerDone:notesViewController];
	}
}

@end


/******************************************************************
 *
 *   FAVORITES
 *
 ******************************************************************/
#pragma mark FAVORITES
@interface FavoriteNotesSectionController : GenericTableViewSectionController
{
	QuickNotesViewController *delegate;
}
@property (nonatomic, assign) QuickNotesViewController *delegate;
@end
@implementation FavoriteNotesSectionController
@synthesize delegate;
- (id)init
{
	if( (self = [super init]) )
	{
		self.title = NSLocalizedString(@"Favorites", @"this is a section label in the 'quick notes' view if you edit a call and add brand new notes.  The favorites section is where you can add your own favorite notes");
		self.editingTitle = self.title;
		self.editingFooter = NSLocalizedString(@"Add your current presentations or common notes here to be used as a template for notes for your initial/return visits", @"This text is right below the Quick notes Favoriate section describing what this section is for");
	}
	return self;
}

- (BOOL)isViewableWhenNotEditing
{
	MTUser *currentUser = [MTUser currentUser];
	NSManagedObjectContext *moc = currentUser.managedObjectContext;
	return [moc countForFetchedObjectsForEntityName:[MTPresentation entityName] 
									  withPredicate:@"user == %@", currentUser] != 0;
}

@end

/******************************************************************
 *
 *   OldQuickNotesCellController
 *
 ******************************************************************/
#pragma mark OldQuickNotesCellController
@interface OldQuickNotesCellController : QuickNotesCellController<NotesViewControllerDelegate>
{
	NSString *notes;
	MTPresentation *presentation;
	BOOL editing;
	BOOL movable;
	int row;
	int section;
}
@property (nonatomic, retain) NSString *notes;
@property (nonatomic, retain) MTPresentation *presentation;
@property (nonatomic, assign) BOOL movable;
@end
@implementation OldQuickNotesCellController
@synthesize notes;
@synthesize presentation;
@synthesize movable;

- (void)dealloc
{
	self.notes = nil;
	self.presentation = nil;
	[super dealloc];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.movable;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	if([fromIndexPath isEqual:toIndexPath])
		return;

	NSUInteger fromIndex = fromIndexPath.row;  
    NSUInteger toIndex = toIndexPath.row;
	
	NSManagedObjectContext *moc = self.presentation.managedObjectContext;
	
	NSArray *presentations = [moc fetchObjectsForEntityName:[MTPresentation entityName]
										  propertiesToFetch:[NSArray arrayWithObject:@"order"]
										withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES]] 
											  withPredicate:@"user == %@", [MTUser currentUser]];
	
    self.presentation.orderValue = toIndex;
	
    NSUInteger start;
	NSUInteger end;
    int delta;
	
    if (fromIndex < toIndex) 
	{
        // move was down, need to shift up
        delta = -1;
        start = fromIndex + 1;
        end = toIndex;
    } 
	else // fromIndex > toIndex
	{ 
        // move was up, need to shift down
        delta = 1;
        start = toIndex;
        end = fromIndex - 1;
    }
	
    for(NSUInteger i = start; i <= end; i++) 
	{
        MTPresentation *otherPresentation = [presentations objectAtIndex:i];  
//        NSLog(@"Updated %@ / %@ from %i to %i", otherObject.name, otherObject.state, otherObject.displayOrderValue, otherObject.displayOrderValue + delta);  
        otherPresentation.orderValue += delta;
    }
	
	NSError *error = nil;
	if (![self.presentation.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	
	
	// move the cellController
	GenericTableViewSectionController *fromSectionController = [self.delegate.displaySectionControllers objectAtIndex:fromIndexPath.section];
	GenericTableViewSectionController *toSectionController = [self.delegate.displaySectionControllers objectAtIndex:toIndexPath.section];
	OldQuickNotesCellController *cellController = [[fromSectionController.displayCellControllers objectAtIndex:fromIndexPath.row] retain];

	
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
	NSString *commonIdentifier = @"OldQuickNotesCell";
	UITableViewMultilineTextCell *cell = (UITableViewMultilineTextCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewMultilineTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
		
//		cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
//		cell.detailTextLabel.numberOfLines = 0; // unlimited lines
	}
	
	[cell setText:self.notes];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [UITableViewMultilineTextCell heightForWidth:(tableView.bounds.size.width - 90) withText:self.notes];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// make the new call view 
	editing = tableView.editing;
	NotesViewController *p = [[[NotesViewController alloc] initWithNotes:self.notes] autorelease];
	p.delegate = self;
	row = indexPath.row;
	section = indexPath.section;
	[[self.delegate navigationController] pushViewController:p animated:YES];		
	[self.delegate retainObject:self whileViewControllerIsManaged:p];
}

- (void)notesViewControllerDone:(NotesViewController *)notesViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	if(editing)
	{
		self.notes = notesViewController.textView.text;
		self.presentation.notes = self.notes;
		
		// now store the data and save it
		NSError *error = nil;
		if (![self.presentation.managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		
		// reload the table
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
//		[self.delegate updateWithoutReload];
		[[self.delegate navigationController] popToViewController:self.delegate animated:YES];
	}
	else
	{
		if(self.delegate.delegate && [self.delegate.delegate respondsToSelector:@selector(notesViewControllerDone:)])
		{
			[self.delegate.delegate notesViewControllerDone:notesViewController];
		}
	}
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		DEBUG(NSLog(@"deleteReturnVisitAtIndex: %d", index);)
		
		[self.presentation.managedObjectContext deleteObject:self.presentation];
		
		// save the data
		NSError *error = nil;
		if (![self.presentation.managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		
		[self.delegate deleteDisplayRowAtIndexPath:indexPath];
	}
}

@end


/******************************************************************
 *
 *   AddQuickNotesCellController
 *
 ******************************************************************/
#pragma mark AddQuickNotesCellController
@interface AddQuickNotesCellController : QuickNotesCellController<NotesViewControllerDelegate>
{
	int section;
	int row;
}
@end
@implementation AddQuickNotesCellController

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
	
	cell.textLabel.text = NSLocalizedString(@"Add New Quick Note", @"button to press when you are in the Quick Notes view and have pressed the Edit nagivation button, this button lets the user add another quick note favorite");
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// make the new call view 
	NotesViewController *p = [[[NotesViewController alloc] initWithNotes:@""] autorelease];
	p.delegate = self;
	section = indexPath.section;
	row = indexPath.row;
	[[self.delegate navigationController] pushViewController:p animated:YES];		
	[self.delegate retainObject:self whileViewControllerIsManaged:p];
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)notesViewControllerDone:(NotesViewController *)notesViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)

	MTPresentation *presentation = [MTPresentation createPresentationInManagedObjectContext:self.delegate.managedObjectContext];
	presentation.user = [MTUser currentUser];
	presentation.notes = notesViewController.textView.text;
	NSError *error = nil;
	if (![self.delegate.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	

	OldQuickNotesCellController *cellController = [[[OldQuickNotesCellController alloc] init] autorelease];
	cellController.delegate = self.delegate;
	cellController.notes = presentation.notes;
	cellController.presentation = presentation;
	cellController.movable = YES;
	[[[self.delegate.sectionControllers objectAtIndex:1] cellControllers] insertObject:cellController atIndex:row];

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
 *   History
 *
 ******************************************************************/
#pragma mark HISTORY
@interface HistoryNotesSectionController : GenericTableViewSectionController
{
}
@end
@implementation HistoryNotesSectionController

- (id)init
{
	if( (self = [super init]) )
	{
		self.title = NSLocalizedString(@"Notes History", @"this is a section label in the 'quick notes' view if you edit a call and add brand new notes.  The history section is where you can add notes to a call based on a previous note you wrote");
	}
	return self;
}

- (BOOL)isViewableWhenEditing
{
	return NO;
}
@end




@implementation QuickNotesViewController
@synthesize delegate;
@synthesize editOnly;
@synthesize managedObjectContext;

- (void)dealloc
{
	self.managedObjectContext = nil;
	
	[super dealloc];
}

- (id) init
{
	if ([super initWithStyle:UITableViewStyleGrouped]) 
	{
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Quick Notes", @"Quick Notes title.  This is shown when you click on the notes to type in for a call, it is the title of the view that shows you the last several notes you have typed in");
		
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

	if(self.editOnly)
		self.editing = YES;
	
	[self updateAndReload];
	
	if(!self.editOnly)
	{
		[self navigationControlDone:nil];
	}
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



- (void)constructSectionControllers
{
	[super constructSectionControllers];
	NSManagedObjectContext *moc = self.managedObjectContext;
	
// Add A New Note section
	{
		GenericTableViewSectionController *sectionController = [[JustAddNoteSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		JustAddNoteCellController *cellController = [[JustAddNoteCellController alloc] init];
		cellController.delegate = self;
		[sectionController.cellControllers addObject:cellController];
		[cellController release];
	}
// Favorate Notes Section
	{
		GenericTableViewSectionController *sectionController = [[FavoriteNotesSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		for(MTPresentation *entry in [moc fetchObjectsForEntityName:[MTPresentation entityName]
												  propertiesToFetch:nil 
												withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES]] 
													  withPredicate:@"user == %@", [MTUser currentUser]])
		{
			OldQuickNotesCellController *cellController = [[OldQuickNotesCellController alloc] init];
			cellController.delegate = self;
			cellController.movable = YES;
			cellController.presentation = entry;
			cellController.notes = entry.notes;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
		}
	
		// add the "Add Additional User" cell at the end
		AddQuickNotesCellController *addCellController = [[AddQuickNotesCellController alloc] init];
		addCellController.delegate = self;
		[sectionController.cellControllers addObject:addCellController];
		[addCellController release];
	}
// Notes History Section
	{
		GenericTableViewSectionController *sectionController = [[HistoryNotesSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		int i = 0;
		for(MTReturnVisit *returnVisit in [moc fetchObjectsForEntityName:[MTReturnVisit entityName]
													   propertiesToFetch:nil 
													 withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:NO]] 
														   withPredicate:@"call.user == %@", [MTUser currentUser]])
		{
			NSString *notes = returnVisit.notes;
			if(notes == nil || notes.length == 0)
			{
				continue;
			}
			
			i++;
			OldQuickNotesCellController *cellController = [[OldQuickNotesCellController alloc] init];
			cellController.delegate = self;
			cellController.notes = notes;
			[sectionController.cellControllers addObject:cellController];
			[cellController release];
			
			// we need to put a limit on the calls
			if(i == 100)
			{
				break;
			}
		}
	}
}


@end
