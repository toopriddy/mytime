//
//  QuickNotesViewController.m
//  MyTime
//
//  Created by Brent Priddy on 8/21/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
#import "QuickNotesViewController.h"
#import "TableViewCellController.h"
#import "Settings.h"
#import "UITableViewTitleAndValueCell.h"
#import "GenericTableViewSectionController.h"
#import "UITableViewMultilineTextCell.h"
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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
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
}

- (void)notesViewControllerDone:(NotesViewController *)notesViewController
{
	[[self retain] autorelease];
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
}
@end
@implementation FavoriteNotesSectionController

- (id)init
{
	if( (self = [super init]) )
	{
		self.title = NSLocalizedString(@"Favorites", @"this is a section label in the 'quick notes' view if you edit a call and add brand new notes.  The favorites section is where you can add your own favorite notes");
	}
	return self;
}

- (BOOL)isViewableWhenNotEditing
{
 	return [[[[Settings sharedInstance] userSettings] objectForKey:SettingsQuickNotes] count] != 0;
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
	BOOL editing;
	int row;
	int section;
}
@property (nonatomic, retain) NSString *notes;
@end
@implementation OldQuickNotesCellController
@synthesize notes;

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
}

- (void)notesViewControllerDone:(NotesViewController *)notesViewController
{
	[[self retain] autorelease];
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	if(editing)
	{
		NSMutableDictionary *userSettings = [[Settings sharedInstance] userSettings];
		NSMutableArray *quickNotes = [userSettings objectForKey:SettingsQuickNotes];
		NSString *note = [NSString stringWithString:notesViewController.textView.text];
		
		[[[[self.delegate.sectionControllers objectAtIndex:1] cellControllers] objectAtIndex:row] setNotes:note];
		
		// now store the data and save it
		[quickNotes replaceObjectAtIndex:row withObject:note];
		[[Settings sharedInstance] saveData];
		
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
	NSMutableArray *quickNotes = [[[Settings sharedInstance] userSettings] objectForKey:SettingsQuickNotes];
	
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		DEBUG(NSLog(@"deleteReturnVisitAtIndex: %d", index);)
		
		[quickNotes removeObjectAtIndex:indexPath.row];
		
		// save the data
		[[Settings sharedInstance] saveData];
		
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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:commonIdentifier] autorelease];
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
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)notesViewControllerDone:(NotesViewController *)notesViewController
{
	[[self retain] autorelease];
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	NSMutableDictionary *userSettings = [[Settings sharedInstance] userSettings];
	NSMutableArray *quickNotes = [userSettings objectForKey:SettingsQuickNotes];
	if(quickNotes == nil)
	{
		quickNotes = [NSMutableArray array];
		[userSettings setObject:quickNotes forKey:SettingsQuickNotes];
	}
	NSString *note = notesViewController.textView.text;

	OldQuickNotesCellController *cellController = [[[OldQuickNotesCellController alloc] init] autorelease];
	cellController.delegate = self.delegate;
	cellController.notes = note;
	[[[self.delegate.sectionControllers objectAtIndex:1] cellControllers] insertObject:cellController atIndex:quickNotes.count];

	// now store the data and save it
	[quickNotes addObject:[NSString stringWithString:note]];
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
@synthesize returnVisitHistory;
@synthesize delegate;

- (void)dealloc
{
	self.returnVisitHistory = nil;
	
	[super dealloc];
}

- (id) init;
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
	
	[self updateAndReload];
	
	[self navigationControlDone:nil];
}

- (void)constructSectionControllers
{
	[super constructSectionControllers];
	
	NSMutableDictionary *userSettings = [[Settings sharedInstance] userSettings];
	NSMutableArray *notes = [userSettings objectForKey:SettingsQuickNotes];

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
		for(NSString *entry in notes)
		{
			OldQuickNotesCellController *cellController = [[OldQuickNotesCellController alloc] init];
			cellController.delegate = self;
			cellController.notes = entry;
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
		NSArray *returnVisits = [[[userSettings objectForKey:SettingsCalls] valueForKeyPath:CallReturnVisits] objectAtIndex:0];
		self.returnVisitHistory = [NSMutableArray arrayWithArray:[returnVisits sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:CallReturnVisitDate ascending:NO] autorelease]]]];

		int i = 0;
		for(NSMutableDictionary *entry in self.returnVisitHistory)
		{
			NSString *notes = [entry objectForKey:CallReturnVisitNotes];
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
