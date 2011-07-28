//
//  DisplayRuleViewController.m
//  MyTime
//
//  Created by Brent Priddy on 1/23/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "DisplayRuleViewController.h"
#import "SorterViewController.h"
#import "TableViewCellController.h"
#import "GenericTableViewSectionController.h"
#import "PSLabelCellController.h"
#import "MTUser.h"
#import "MTDisplayRule.h"
#import "MTSorter.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "UITableViewTitleAndValueCell.h"
#import "PSTextFieldCellController.h"
#import "PSButtonCellController.h"
#import "PSLocalization.h"



@interface DisplayRuleSorterCellController : PSLabelCellController
{
}
@end
@implementation DisplayRuleSorterCellController

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	MTSorter *sorter = (MTSorter *)self.model;
	// move the row
	NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[sorter.displayRule.sorters sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES]]]];
	MTSorter *movedEntry = [[sortedArray objectAtIndex:fromIndexPath.row] retain];
	[sortedArray removeObjectAtIndex:fromIndexPath.row];
	[sortedArray insertObject:movedEntry atIndex:toIndexPath.row];
	[movedEntry release];
	
	int i = 0;
	for(MTSorter *entry in sortedArray)
	{
		entry.orderValue = i++;
	}
	[sorter.managedObjectContext processPendingChanges];
	
	// move the cellController
	GenericTableViewSectionController *fromSectionController = [self.tableViewController.displaySectionControllers objectAtIndex:fromIndexPath.section];
	GenericTableViewSectionController *toSectionController = [self.tableViewController.displaySectionControllers objectAtIndex:toIndexPath.section];
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

@end

@implementation DisplayRuleViewController
@synthesize delegate;
@synthesize displayRule;
@synthesize allTextFields;
@synthesize temporarySorter;

- (id) initWithDisplayRule:(MTDisplayRule *)theDisplayRule newDisplayRule:(BOOL)newDisplayRule
{
	if ((self = [super initWithStyle:UITableViewStyleGrouped])) 
	{
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Edit Display Rule", @"Sort Rules View title");
		self.displayRule = theDisplayRule;
		self.hidesBottomBarWhenPushed = YES;
		self.allTextFields = [NSMutableArray array];

		obtainFocus = self.displayRule.name.length == 0;
		[self.displayRule addObserver:self forKeyPath:@"name" options:0 /*NSKeyValueObservingOptionNew*/ context:nil]; 
		
	}
	return self;
}

- (void)dealloc 
{
	[self.displayRule removeObserver:self forKeyPath:@"name"]; 
	self.allTextFields = nil;
	self.displayRule = nil;
	self.temporarySorter = nil;
	[filterTableViewController_ release];
	
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[self.navigationItem.rightBarButtonItem setEnabled:(self.displayRule.name.length > 0)];
}


- (FilterTableViewController *)filterTableViewController
{
	if(filterTableViewController_ == nil)
	{
		filterTableViewController_ = [FilterTableViewController alloc];
		filterTableViewController_.filter = self.displayRule.filter;
		filterTableViewController_.managedObjectContext = self.displayRule.managedObjectContext;
	}
	return filterTableViewController_;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)resignAllFirstResponders
{
	for(UITextField *textField in self.allTextFields)
	{
		[textField resignFirstResponder];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self resignAllFirstResponders];
}


- (void)navigationControlDone:(id)sender 
{
	if(self.delegate && [self.delegate respondsToSelector:@selector(displayRuleViewControllerDone:)])
	{
		[self.delegate displayRuleViewControllerDone:self];
	}
}	

- (void)loadView 
{
	[super loadView];
	self.editing = YES;
	
	[self.navigationItem setHidesBackButton:YES animated:YES];
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	[self.navigationItem.rightBarButtonItem setEnabled:(self.displayRule.name.length > 0)];
}

- (void)sorterViewControllerDone:(SorterViewController *)sorterViewController
{
	NSManagedObjectContext *moc = self.displayRule.managedObjectContext;
	
	NSError *error = nil;
	if (![moc save:&error]) 
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:self.navigationController error:error];
	}
	if(self.temporarySorter)
	{
		self.temporarySorter = nil;
		[self dismissModalViewControllerAnimated:YES];
	}
	else
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
	
	[self updateAndReload];
}


- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView deleteSorterAtIndexPath:(NSIndexPath *)indexPath
{
	[self resignAllFirstResponders];

	MTSorter *sorter = (MTSorter *)labelCellController.model;
	
	[self.displayRule.managedObjectContext deleteObject:sorter];
	NSError *error = nil;
	if (![self.displayRule.managedObjectContext save:&error]) 
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:self.navigationController error:error];
	}
	[[self retain] autorelease];
	[self deleteDisplayRowAtIndexPath:indexPath];
	[self updateAndReload];
}

- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView modifySorterFromSelectionAtIndexPath:(NSIndexPath *)indexPath
{
	[self resignAllFirstResponders];

	MTSorter *sorter = (MTSorter *)labelCellController.model;
	SorterViewController *p = [[[SorterViewController alloc] initWithSorter:sorter newSorter:NO] autorelease];
	p.delegate = self;
	[[self navigationController] pushViewController:p animated:YES];		
	[self retainObject:labelCellController whileViewControllerIsManaged:p];
}


- (void)addSorterNavigationControlCanceled
{
	NSManagedObjectContext *moc = self.temporarySorter.managedObjectContext;
	[moc deleteObject:self.temporarySorter];
	self.temporarySorter = nil;
	NSError *error = nil;
	if(![moc save:&error])
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:self.navigationController error:error];
	}
	[self dismissModalViewControllerAnimated:YES];
}

- (void)restoreDefaults
{
	[self.displayRule restoreDefaults];
	[self updateAndReload];
}

- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView addSorterFromSelectionAtIndexPath:(NSIndexPath *)indexPath
{
	[self resignAllFirstResponders];

	self.temporarySorter = [MTSorter createSorterForDisplayRule:self.displayRule];
	self.temporarySorter.displayRule = self.displayRule;
	SorterViewController *controller = [[[SorterViewController alloc] initWithSorter:self.temporarySorter newSorter:YES] autorelease];
	controller.delegate = self;
	
	// push the element view controller onto the navigation stack to display it
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
	
	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *temporaryBarButtonItem = [[[UIBarButtonItem alloc] init] autorelease];
	temporaryBarButtonItem.title = NSLocalizedString(@"Cancel", @"Cancel button");
	
	controller.title = NSLocalizedString(@"New Sort Rule", @"Title for the Sorted By ... area when you are editing the display rules");
	[self presentModalViewController:navigationController animated:YES];
	[temporaryBarButtonItem setAction:@selector(addSorterNavigationControlCanceled)];
	[temporaryBarButtonItem setTarget:self];
	controller.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
	
	[self retainObject:controller whileViewControllerIsManaged:controller];
}


- (void)constructSectionControllers
{
	[super constructSectionControllers];

	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];

		if(self.displayRule.deleteableValue)
		{
			PSTextFieldCellController *cellController = [[[PSTextFieldCellController alloc] init] autorelease];
			cellController.model = self.displayRule;
			cellController.modelPath = @"name";
			cellController.placeholder = NSLocalizedString(@"Display Rule Name", @"This is the placeholder text in the Display Rule detail screen where you name the display rule");
			cellController.returnKeyType = UIReturnKeyDone;
			cellController.clearButtonMode = UITextFieldViewModeAlways;
			cellController.autocapitalizationType = UITextAutocapitalizationTypeWords;
			cellController.selectionStyle = UITableViewCellSelectionStyleNone;
			cellController.obtainFocus = obtainFocus;
			cellController.allTextFields = self.allTextFields;
			cellController.indentWhileEditing = NO;
			obtainFocus = NO;
			[self addCellController:cellController toSection:sectionController];
		}
		else
		{
			PSLabelCellController *cellController = [[[PSLabelCellController alloc] init] autorelease];
			cellController.model = self.displayRule;
			cellController.indentWhileEditing = NO;
			cellController.selectionStyle = UITableViewCellSelectionStyleNone;
			cellController.modelPath = @"localizedName";
			[self addCellController:cellController toSection:sectionController];
		}
	}
	// Filters
	self.filterTableViewController.filter = self.displayRule.filter;
	[self.filterTableViewController constructSectionControllersForTableViewController:self];
	
	// Sorters
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		sectionController.editingTitle = NSLocalizedString(@"Sort Rules", @"Section title for the Display Rule editing view");
		sectionController.editingFooter = NSLocalizedString(@"The first sort rule determines what is used in the index to the right of the list of calls.  The '∧' and '∨' at the end of the rows specifies an ascending or decending sort.", @"Description of what to do with the sort rules in the Display Rule editor");
		[sectionController release];

		NSArray *sorters = [self.displayRule.managedObjectContext fetchObjectsForEntityName:[MTSorter entityName]
																		  propertiesToFetch:nil
																		withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES] ]
																			  withPredicate:@"displayRule == %@", self.displayRule];
		
		for(MTSorter *sorter in sorters)
		{
			DisplayRuleSorterCellController *cellController = [[[DisplayRuleSorterCellController alloc] init] autorelease];
			cellController.model = sorter;
			cellController.modelPath = @"name";
			cellController.editingStyle = UITableViewCellEditingStyleDelete;
			cellController.editingAccessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:sorter.ascendingValue ? @"up.png" : @"down.png"] highlightedImage:[UIImage imageNamed:sorter.ascendingValue ? @"upSelected.png" : @"downSelected.png"]] autorelease];
			[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:modifySorterFromSelectionAtIndexPath:)];
			[cellController setDeleteTarget:self action:@selector(labelCellController:tableView:deleteSorterAtIndexPath:)];
			[self addCellController:cellController toSection:sectionController];
		}
		
		// add the "Add Sorter" cell at the end
		{
			PSLabelCellController *cellController = [[[PSLabelCellController alloc] init] autorelease];
			cellController.title = NSLocalizedString(@"Add New Sort Rule", @"Button to click to add an additional sort or filter rule for the Sorted By ... view");
			cellController.editingStyle = UITableViewCellEditingStyleInsert;
			[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:addSorterFromSelectionAtIndexPath:)];
			[cellController setInsertTarget:self action:@selector(labelCellController:tableView:addSorterFromSelectionAtIndexPath:)];
			[self addCellController:cellController toSection:sectionController];
		}
	}	
	
	//
	// Reset to defaults
	if(self.displayRule.internalValue)
	{
		GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		// add the "Restore to Defaults"
		{
			PSButtonCellController *cellController = [[[PSButtonCellController alloc] init] autorelease];
			cellController.title = NSLocalizedString(@"Restore to Defaults", @"Button to click to add an additional sort or filter rule for the Sorted By ... view");
			cellController.imageName = @"blueButton.png";
			cellController.imagePressedName = @"blueButton.png";
			[cellController setButtonTarget:self action:@selector(restoreDefaults)];
			[self addCellController:cellController toSection:sectionController];
		}
	}	
	
}

@end
