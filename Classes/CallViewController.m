//
//  CallViewController.m
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "CallViewController.h"
#import "Settings.h"
#import "UITableViewTitleAndValueCell.h"
#import "AddressViewController.h"
#import "PublicationViewController.h"
#import "PublicationTypeViewController.h"
#import "DatePickerViewController.h"
#import "UITableViewMultilineTextCell.h"
#import "NotesViewController.h"
#import "AddressTableCell.h"
#import "SwitchTableCell.h"
#import "MetadataViewController.h"
#import "MetadataEditorViewController.h"
#import "Geocache.h"
#import "PSUrlString.h"
#import "PSLocalization.h"

#define PLACEMENT_OBJECT_COUNT 2

#define USE_TEXT_VIEW 0

NSString * const CallViewRowHeight = @"rowHeight";
NSString * const CallViewGroupText = @"group";
NSString * const CallViewType = @"type";
NSString * const CallViewRows = @"rows";
NSString * const CallViewNames = @"names";
NSString * const CallViewSelectedInvocations = @"select";
NSString * const CallViewDeleteInvocations = @"delete";
NSString * const CallViewInsertDelete = @"insertdelete";
NSString * const CallViewIndentWhenEditing = @"indentWhenEditing";

@interface SelectAddressView : UIResponder <UITextFieldDelegate>
{
	UITableView *tableView;
	NSIndexPath *indexPath;
}
@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) NSIndexPath *indexPath;

- (id)initWithTable:(UITableView *)theTableView indexPath:(NSIndexPath *)theIndexPath;
@end

@implementation SelectAddressView

@synthesize tableView;
@synthesize indexPath;
- (void)dealloc
{
	self.tableView = nil;
	self.indexPath = nil;
	[super dealloc];
}

- (id)initWithTable:(UITableView *)theTableView indexPath:(NSIndexPath *)theIndexPath
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	[super init];
	self.tableView = theTableView;
	self.indexPath = theIndexPath;
	return(self);
}

- (BOOL)becomeFirstResponder 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	[tableView deselectRowAtIndexPath:nil animated:NO];
	[tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
	[tableView.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
	return NO;
}
@end

@implementation CallViewController

@synthesize theTableView;
@synthesize delegate;
@synthesize currentIndexPath;

/******************************************************************
 *
 *   INIT
 *
 ******************************************************************/

- (id) init
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
    return([self initWithCall:nil]);
}

- (id) initWithCall:(NSMutableDictionary *)call
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
    if([super init]) 
    {
		theTableView = nil;
		_initialView = YES;
		delegate = nil;
		currentIndexPath = nil;
		
		self.hidesBottomBarWhenPushed = YES;
		
        NSString *temp;
        DEBUG(NSLog(@"CallView 2initWithFrame:call:%@", call);)

		_setFirstResponderGroup = -1;
		
		_displayInformation = [[NSMutableArray alloc] init];

		_newCall = (call == nil);
		_editing = _newCall;
		_showDeleteButton = !_newCall;
		if(_newCall)
		{
			_call = [[NSMutableDictionary alloc] init];
			_setFirstResponderGroup = 0;
			_showAddCall = NO;

			NSMutableArray *returnVisits = [[[NSMutableArray alloc] initWithArray:[_call objectForKey:CallReturnVisits]] autorelease];
			[_call setObject:returnVisits forKey:CallReturnVisits];
			
			NSMutableDictionary *visit = [[[NSMutableDictionary alloc] init] autorelease];

			[visit setObject:[NSDate date] forKey:CallReturnVisitDate];
			[visit setObject:@"" forKey:CallReturnVisitNotes];
			[visit setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallReturnVisitPublications];
			
			[returnVisits insertObject:visit atIndex:0];
		}
		else
		{
			_showAddCall = YES;

			_call = [[NSMutableDictionary alloc] initWithDictionary:call copyItems:YES];
		}

		_name = [[UITextField alloc] initWithFrame:CGRectZero];
		_name.autocapitalizationType = UITextAutocapitalizationTypeWords;
		_name.returnKeyType = UIReturnKeyDone;
        // _name (make sure that it is initalized)
        //[_name setText:NSLocalizedString(@"Name", @"Name label for Call in editing mode")];
		_name.placeholder = NSLocalizedString(@"Name", @"Name label for Call in editing mode");
        if((temp = [_call objectForKey:CallName]) != nil)
		{
            _name.text = temp;
		}
        else
		{
            [_call setObject:@"" forKey:CallName];
		}

        // address (make sure that everything is initialized)
        if([_call objectForKey:CallStreet] == nil)
            [_call setObject:@"" forKey:CallStreet];
        if([_call objectForKey:CallCity] == nil)
            [_call setObject:@"" forKey:CallCity];
        if([_call objectForKey:CallState] == nil)
            [_call setObject:@"" forKey:CallState];

		// metadata
        if([_call objectForKey:CallMetadata] == nil)
        {
            [_call setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallMetadata];
        }
		
		// return visits
        if([_call objectForKey:CallReturnVisits] == nil)
        {
            [_call setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallReturnVisits];
        }
        else
        {
           // lets check all of the ReturnVisits to make sure that everything was 
            // initialized correctly
            NSMutableArray *returnVisits = [_call objectForKey:CallReturnVisits];
            NSMutableDictionary *visit;
			
            int i;
            int end = [returnVisits count];
            for(i = 0; i < end; ++i)
            {
                visit = [returnVisits objectAtIndex:i];
                if([visit objectForKey:CallReturnVisitDate] == nil)
                    [visit setObject:[NSDate date] forKey:CallReturnVisitDate];
                
                if([visit objectForKey:CallReturnVisitNotes] == nil)
                    [visit setObject:@"" forKey:CallReturnVisitNotes];

                if([visit objectForKey:CallReturnVisitType] == nil)
                    [visit setObject:CallReturnVisitTypeReturnVisit forKey:CallReturnVisitType];
                
                if([visit objectForKey:CallReturnVisitPublications] == nil)
                    [visit setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallReturnVisitPublications];
                else
                {
                    // they had an array of publications, lets check them too
                    NSMutableArray *publications = [visit objectForKey:CallReturnVisitPublications];
                    NSMutableDictionary *publication;
                    int j;
                    int endPublications = [publications count];
                    for(j = 0; j < endPublications; ++j)
                    {
                        publication = [publications objectAtIndex:j];
                        if([publication objectForKey:CallReturnVisitPublicationTitle] == nil)
                            [publication setObject:@"" forKey:CallReturnVisitPublicationTitle];
                        if([publication objectForKey:CallReturnVisitPublicationName] == nil)
                            [publication setObject:@"" forKey:CallReturnVisitPublicationName];
						// the older version that no one should really have had things saved without a type
						// go ahead and initalize this as a magazine
                        if([publication objectForKey:CallReturnVisitPublicationType] == nil)
                            [publication setObject:PublicationTypeMagazine forKey:CallReturnVisitPublicationType];
                        if([publication objectForKey:CallReturnVisitPublicationYear] == nil)
                            [publication setObject:[[[NSNumber alloc] initWithInt:0] autorelease] forKey:CallReturnVisitPublicationYear];
                        if([publication objectForKey:CallReturnVisitPublicationMonth] == nil)
                            [publication setObject:[[[NSNumber alloc] initWithInt:0] autorelease] forKey:CallReturnVisitPublicationMonth];
                        if([publication objectForKey:CallReturnVisitPublicationDay] == nil)
                            [publication setObject:[[[NSNumber alloc] initWithInt:0] autorelease] forKey:CallReturnVisitPublicationDay];
                    }
                }
                
            }
        }
		

		// 0 = greay
		// 1 = red
		// 2 = left arrow
		// 3 = blue
		if(_newCall)
		{
			self.title = NSLocalizedString(@"New Call", @"Call main title when you are adding a new call");
			// update the button in the nav bar
			UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																					 target:self
																					 action:@selector(navigationControlCancel:)] autorelease];
			[self.navigationItem setLeftBarButtonItem:button animated:YES];
		}
		else
		{
			self.title = NSLocalizedString(@"Call", @"Call main title when editing an existing call");
		}
    }
    
    return(self);
}

- (void)dealloc 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	theTableView.delegate = nil;
	theTableView.dataSource = nil;
	[theTableView release];

    [_name release];
    [_call release];
	[_displayInformation release];

	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	return(YES);
}

- (void)save
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)

	[_call setObject:[self name] forKey:CallName];
	
	if(!_newCall)
	{
		if(delegate)
		{
			[delegate callViewController:self saveCall:_call];
		}
	}
}


- (void)navigationControlDone:(id)sender 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	// go through the notes and make them resign the first responder
	[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
	[theTableView flashScrollIndicators];
	[_name resignFirstResponder];

	BOOL isNewCall = _newCall;
	// we dont save a new call untill they hit "Done"
	_newCall = NO;
	[self save];

	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																			 target:self
																			 action:@selector(navigationControlEdit:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	// show the back button when they are done editing
	self.navigationItem.hidesBackButton = NO;
	
	// we need to reload data now, so we need to hide:
	//   the name field if it does not have a value
	//   the insert new call
	//   the per call insert a new publication

	_editing = NO;
	_showAddCall = YES;
	_showDeleteButton = YES;

	if(isNewCall)
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
	else
	{
#if 1
		[self reloadData];
		[theTableView reloadData];
		
		if(theTableView.editing != _editing)
			theTableView.editing = _editing;	
#else			
		NSMutableArray *cachedItems = [[_displayInformation retain] autorelease];
		[self reloadData];

		NSEnumerator *oldDisplayInformation = [_displayInformation objectEnumerator];
		NSMutableDictionary *items;
		[theTableView beginUpdates];
		int section = 0;
		int row = 0;
		NSEnumerator *newDisplayInformation = [cachedItems objectEnumerator];
		NSMutableDictionary *newItems;

		NSMutableIndexSet *insertSections = [NSMutableIndexSet indexSet];
		NSMutableArray *insertRows = [NSMutableArray array];

		while( YES )
		{
			items = [oldDisplayInformation nextObject];
			if(items == nil)
				break;
			// advance to the next section
			newItems = [newDisplayInformation nextObject];


			int start = section;
			while(![[newItems objectForKey:CallViewType] isEqualToString:[items objectForKey:CallViewType]])
			{
				section++;
				newItems = [newDisplayInformation nextObject];
			}
			if(start != section)
			{
				[insertSections addIndexesInRange:NSMakeRange(start, section - start)];
			}
			NSEnumerator *rows = [[items objectForKey:CallViewRows] objectEnumerator];
			NSInvocation *invocation;
			NSEnumerator *newRows = [[newItems objectForKey:CallViewRows] objectEnumerator];
			NSInvocation *newInvocation = [newRows nextObject];
			while( (invocation = [rows nextObject]) )
			{
				NSMutableArray *array = [[NSMutableArray alloc] init];
				while([invocation selector] != [newInvocation selector])
				{
					[array addObject:[NSIndexPath indexPathForRow:row inSection:section]];
					row++;
					newInvocation = [newRows nextObject];
				}
				if([array count])
				{
					[insertRows addObjectsFromArray:array];
				}
				[array release];
				row++;
			}
			while( [newRows nextObject] )
			{
				[insertRows addObject:[NSIndexPath indexPathForRow:row inSection:section]];
				row++;
			}

			section++;
			row = 0;
		}
		while( [newDisplayInformation nextObject] )
		{
			[insertSections addIndex:section];
			section++;
		}
		[theTableView deleteSections:insertSections withRowAnimation:UITableViewRowAnimationFade];
		[theTableView deleteRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationFade];

		if(theTableView.editing != _editing)
			theTableView.editing = _editing;		
		[theTableView endUpdates];
		[theTableView reloadData];
#endif
	}
}


- (void)navigationControlActionSheet:(id)sender 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"You can transfer this call to someone else. Transferring will delete this call from your data, but your statistics from this call will stay. The witness who gets this email will be able to click on a link in the email and add the call to MyTime.", @"This message is displayed when the user clicks on a Call then clicks on Edit and clicks on the \"Action\" button at the top left of the screen")
															 delegate:self
												    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
											   destructiveButtonTitle:NSLocalizedString(@"Transfer, and Delete", @"Transferr this call to another MyTime user and delete it off of this iphone, but keep the data")
												    otherButtonTitles:NSLocalizedString(@"Email Details", @"Email the call details to another MyTime user"), nil] autorelease];

	alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[alertSheet showInView:self.view];
	_actionSheetSource = YES;
}

- (void)navigationControlCancel:(id)sender 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	[_call release];
	_call = nil;
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)navigationControlEdit:(id)sender 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	_editing = YES;
	_showDeleteButton = YES;
	_showAddCall = YES;
	
	[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:NO];
	[theTableView flashScrollIndicators];
	
	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];

	// update the button in the nav bar
	button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
															 target:self
															 action:@selector(navigationControlActionSheet:)] autorelease];
	[self.navigationItem setLeftBarButtonItem:button animated:YES];

	// hide the back button so that they cant cancel the edit without hitting done
	self.navigationItem.hidesBackButton = YES;

#if 0
	[self reloadData];
	[theTableView reloadData];
	if(theTableView.editing != _editing)
		theTableView.editing = _editing;		
#else
	NSMutableArray *cachedItems = [[_displayInformation retain] autorelease];
	[self reloadData];

	NSEnumerator *oldDisplayInformation = [cachedItems objectEnumerator];
	NSMutableDictionary *items;

	int section = 0;
	int row = 0;
	NSEnumerator *newDisplayInformation = [_displayInformation objectEnumerator];
	NSMutableDictionary *newItems;
	
[theTableView beginUpdates];

	while( YES )
	{
		row = 0;
		// get the next old items and if there are no more then dont increment the section
		items = [oldDisplayInformation nextObject];
		// if there were no more new items bust out
		if(items == nil)
			break;
		// advance to the next section
		newItems = [newDisplayInformation nextObject];

		// see if the new section at section is the sames as the older section, if it is new
		// then loop till we find the old section
		while(![[newItems objectForKey:CallViewType] isEqualToString:[items objectForKey:CallViewType]])
		{
			[theTableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
			DEBUG(NSLog(@"insertSection: %d %@", section, [newItems objectForKey:CallViewType]);)
			section++;
			newItems = [newDisplayInformation nextObject];
		}
		
		NSEnumerator *oldRows = [[items objectForKey:CallViewNames] objectEnumerator];
		NSString *oldName;
		NSEnumerator *newRows = [[newItems objectForKey:CallViewNames] objectEnumerator];
		NSString *newName;
		while( (oldName = [oldRows nextObject]) )
		{
			newName = [newRows nextObject];
			while(![oldName isEqualToString:newName])
			{
				[theTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
				DEBUG(NSLog(@"insertRow: %d,%d %@", section, row, newName);)
				row++;
				newName = [newRows nextObject];
			}
			row++;
		}
		while( (newName = [newRows nextObject]) )
		{
			[theTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationFade];
			DEBUG(NSLog(@"insertRow: %d,%d %@", section, row, newName);)
			row++;
		}

		section++;
	}
	
	while( (newItems = [newDisplayInformation nextObject]) )
	{
		[theTableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
		DEBUG(NSLog(@"insertSection: %d %@", section, [newItems objectForKey:CallViewType]);)
		section++;
	}

	if(theTableView.editing != _editing)
		theTableView.editing = _editing;		

[theTableView endUpdates];
#endif	
}

#if 0
- (void)tableViewTextFieldCell:(UITableViewTextFieldCell *)cell selected:(BOOL)selected
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	if(selected)
	{
		if(cell.textField == _name)
		{
			[theTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
			self.currentFirstResponder = _name;
		}
	}
	else
	{
		if(self.currentFirstResponder)
		{
			[self.currentFirstResponder resignFirstResponder];
		}
		self.currentFirstResponder = nil;
	}
}
#endif

- (void)scrollToSelected:(id)unused
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	[theTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	// force the tableview to load
	[self reloadData];
	[theTableView reloadData];
}


- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];

    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	[theTableView flashScrollIndicators];
	if(!_initialView)
	{
		[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
	}
	_initialView = NO;

	NSMutableDictionary *settings = [[Settings sharedInstance] settings];
	if(!_newCall && [settings objectForKey:SettingsExistingCallAlertSheetShown] == nil)
	{
		[settings setObject:@"" forKey:SettingsExistingCallAlertSheetShown];
		[[Settings sharedInstance] saveData];
		
		UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
		[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
		alertSheet.title = NSLocalizedString(@"Touch the Edit button to add a return visit or you can see where your call is located by touching the address of your call", @"This is a note displayed when they first see the non editable call view");
		[alertSheet show];
		
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	if([_name isFirstResponder])
		[_name resignFirstResponder];
}

- (void)loadView 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	UIView *contentView = [[[UIView alloc] initWithFrame:rect] autorelease];
	contentView.backgroundColor = [UIColor blackColor];
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	self.view = contentView;

	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	UITableView *tableView = [[[UITableView alloc] initWithFrame:self.view.bounds 
														  style:UITableViewStyleGrouped] autorelease];

	tableView.editing = _newCall;
	tableView.allowsSelectionDuringEditing = YES;
	// set the autoresizing mask so that the table will always fill the view
	tableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	tableView.delegate = self;
	tableView.dataSource = self;
	
	// set the tableview as the controller view
    self.theTableView = tableView;
	[self.view addSubview:tableView];

	if(_newCall || _editing)
	{
		// add DONE button
		UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				 target:self
																				 action:@selector(navigationControlDone:)] autorelease];
		[self.navigationItem setRightBarButtonItem:button animated:NO];
	}
	else
	{
		// add EDIT button
		UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																				 target:self
																				 action:@selector(navigationControlEdit:)] autorelease];
		[self.navigationItem setRightBarButtonItem:button animated:NO];
	}
	
	//[_table enableRowDeletion: YES animated:YES];
}




//
//
// UITableViewDelegate methods
//
//
- (void)selectRow:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"setRow: section:%d row:%d ", [indexPath section], [indexPath row]);)
	[self.theTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
	[indexPath release];
}

- (NSInvocation *)invocationForSelector:(SEL)selector
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:selector]];
	[invocation setTarget:self];
	[invocation setSelector:selector];
	
	return(invocation);
}

- (NSInvocation *)invocationForSelector:(SEL)selector withArgument:(void *)argument
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	NSInvocation *invocation = [self invocationForSelector:selector];
	[invocation setArgument:&argument atIndex:2];
	
	return(invocation);
}

- (NSInvocation *)invocationForSelector:(SEL)selector withArgument:(void *)argument andArgument:(void *)anotherArgument
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	NSInvocation *invocation = [self invocationForSelector:selector withArgument:argument];
	[invocation setArgument:&anotherArgument atIndex:3];
	
	return(invocation);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if([_name isFirstResponder])
		[_name resignFirstResponder];
}



/******************************************************************
 *
 *   Callback functions
 *   
 ******************************************************************/
#pragma mark Callback Functions
- (void)dummyFunction
{
}

- (void)deleteReturnVisitAtIndex:(int)index
{
	DEBUG(NSLog(@"deleteReturnVisitAtIndex: %d", index);)


	NSMutableArray *returnVisits = [_call objectForKey:CallReturnVisits];
	NSMutableArray *array = [[[NSMutableArray alloc] initWithArray:returnVisits] autorelease];
	[_call setObject:array forKey:CallReturnVisits];
	DEBUG(NSLog(@"got %@", array);)
	returnVisits = array;
	// if they click on the notes, then it is like they are deleting
	// the whole return visit
	DEBUG(NSLog(@"trying to remove row %d", index);)
	[returnVisits removeObjectAtIndex:index];
	DEBUG(NSLog(@"got %@", returnVisits);)

	[self reloadData];

	// save the data
	[self save];

	[theTableView deleteSections:[NSIndexSet indexSetWithIndex:[currentIndexPath section]] withRowAnimation:UITableViewRowAnimationLeft];

}

- (void)deleteReturnVisitAtIndex:(int)index publicationAtIndex:(int)publicationIndex
{
	DEBUG(NSLog(@"deleteReturnVisitAtIndex: %d publicationAtIndex:%d %@", index, publicationIndex, currentIndexPath);)
	// this is the entry that we need to delete
	[[[[_call objectForKey:CallReturnVisits] objectAtIndex:index] 
	                                                  objectForKey:CallReturnVisitPublications] 
													      removeObjectAtIndex:publicationIndex];
	
	[self reloadData];
	// save the data
	[self save];

	[theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:currentIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)addressSelected
{
	DEBUG(NSLog(@"addressSelected");)
	if(_editing)
	{
		NSString *streetNumber = [_call objectForKey:CallStreetNumber];
		NSString *apartmentNumber = [_call objectForKey:CallApartmentNumber];
		NSString *street = [_call objectForKey:CallStreet];
		NSString *city = [_call objectForKey:CallCity];
		NSString *state = [_call objectForKey:CallState];
		
		// if they have not initialized the address then assume that it is
		// the same as the last one
		if((streetNumber == nil || [streetNumber isEqualToString:@""]) &&
		   (apartmentNumber == nil || [apartmentNumber isEqualToString:@""]) &&
		   (street == nil || [street isEqualToString:@""]) &&
		   (city == nil || [city isEqualToString:@""]) &&
		   (state == nil || [state isEqualToString:@""]))
		{
			NSMutableDictionary *settings = [[Settings sharedInstance] settings];
			// if they are in an apartment territory then just null out the apartment number
			streetNumber = [settings objectForKey:SettingsLastCallStreetNumber];
			apartmentNumber = [settings objectForKey:SettingsLastCallApartmentNumber];
			if(apartmentNumber.length)
				apartmentNumber = @"";
			else
				streetNumber = @"";
			street = [settings objectForKey:SettingsLastCallStreet];
			city = [settings objectForKey:SettingsLastCallCity];
			state = [settings objectForKey:SettingsLastCallState];
		}
		// open up the edit address view 
		AddressViewController *viewController = [[[AddressViewController alloc] initWithStreetNumber:streetNumber
																			               apartment:apartmentNumber
																							  street:street
																							    city:city
																							   state:state] autorelease];
		viewController.delegate = self;
		[[self navigationController] pushViewController:viewController animated:YES];
		return;
	}
	else
	{
		NSString *streetNumber = [_call objectForKey:CallStreetNumber];
		NSString *apartmentNumber = [_call objectForKey:CallApartmentNumber];
		NSString *street = [_call objectForKey:CallStreet];
		NSString *city = [_call objectForKey:CallCity];
		NSString *state = [_call objectForKey:CallState];
		NSString *latLong = [_call objectForKey:CallLattitudeLongitude];
		
		// if they have not initialized the address then dont show the map program
		// if they have initalized a latLong then include that
		if(!((street == nil || [street isEqualToString:@""]) &&
			 (city == nil || [city isEqualToString:@""]) &&
			 (state == nil || [state isEqualToString:@""])) ||
		   (latLong != nil && ![latLong isEqualToString:@"nil"]))
		{
			// pop up a alert sheet to display buttons to show in google maps?
			//http://maps.google.com/?hl=en&q=kansas+city

			// make sure that we have default values for each of the address parts
			if(streetNumber == nil)
				streetNumber = @"";
			if(apartmentNumber == nil || apartmentNumber.length == 0)
				apartmentNumber = @"";
			else
				apartmentNumber = [NSString stringWithFormat:@"(%@)", apartmentNumber];
			if(street == nil)
				street = @"";
			if(city == nil)
				city = @"";
			if(state == nil)
				state = @"";
			if(latLong == nil || [latLong isEqualToString:@"nil"])
				latLong = @"";
			else
				latLong = [NSString stringWithFormat:@"@%@", [[latLong stringByReplacingOccurrencesOfString:@" " withString:@"" ] stringWithEscapedCharacters]];
#if 1		
			// open up a url
			NSURL *url = [NSURL URLWithString:[NSString 
										 stringWithFormat:@"http://maps.google.com/?lh=%@&q=%@+%@+%@+%@,+%@%@", 
										                  NSLocalizedString(@"en", @"Google Localized Language Name"),
														  [streetNumber stringWithEscapedCharacters], 
														  [apartmentNumber stringWithEscapedCharacters], 
														  [street stringWithEscapedCharacters], 
														  [city stringWithEscapedCharacters], 
														  [state stringWithEscapedCharacters],
														  latLong]];
			DEBUG(NSLog(@"Trying to open url %@", url);)
			// open up the google map page for this call
			[[UIApplication sharedApplication] openURL:url];
#else				
			WebViewController *p = [[[WebViewController alloc] initWithTitle:@"Map" address:_call] autorelease];
			[[self navigationController] pushViewController:p animated:YES];
#endif
		}
		else
		{
			// unselect the row
//			[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
		}
	}
}

- (void)locationTypeSelected
{
	LocationPickerViewController *p = [[[LocationPickerViewController alloc] initWithCall:_call] autorelease];
	p.delegate = self;

	[[self navigationController] pushViewController:p animated:YES];		
}

- (void)selectMetadataAtIndex:(int)metadataIndex
{
	NSMutableDictionary *metadata = [[_call objectForKey:CallMetadata] objectAtIndex:metadataIndex];
	NSNumber *type = [metadata objectForKey:CallMetadataType];
	NSString *name = [metadata objectForKey:CallMetadataName];
	NSString *value = [metadata objectForKey:CallMetadataValue];
	NSObject *data = [metadata objectForKey:CallMetadataData];

	if(_editing)
	{
		_editingMetadata = metadata; // we are making a new one
		
		// make the new call view 
		MetadataEditorViewController *p = [[[MetadataEditorViewController alloc] initWithName:name type:[type intValue] data:data value:value] autorelease];
		p.delegate = self;

		[[self navigationController] pushViewController:p animated:YES];		
	}
	else
	{
		switch([type intValue])
		{
			case PHONE:
				if(value)
				{
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", value]]];
				}
				break;
			case EMAIL:
				if(value)
				{
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto://%@", value]]];
				}
			case URL:
				if(value)
				{
					NSString *url;
					if([value hasPrefix:@"http://"])
						url = value;
					else
						url = [NSString stringWithFormat:@"http://%@", value];
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
				}
				break;
		}
	}
}

- (void)deleteMetadataAtIndex:(int)metadataIndex
{
	NSMutableArray *array = [NSMutableArray arrayWithArray:[_call objectForKey:CallMetadata]];
	[array removeObjectAtIndex:metadataIndex];
	[_call setObject:array forKey:CallMetadata];
	
	[self reloadData];
	// save the data
	[self save];

	[theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:currentIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)addMetadataSelected
{
	_editingMetadata = nil; // we are making a new one
	
	// make the new call view 
	MetadataViewController *p = [[[MetadataViewController alloc] init] autorelease];
	p.delegate = self;

	[[self navigationController] pushViewController:p animated:YES];		
}

- (void)addReturnVisitSelected
{
	DEBUG(NSLog(@"addReturnVisitSelected _selectedRow=%d", _selectedRow);)
	_showAddCall = NO;

	NSMutableArray *returnVisits = [[[NSMutableArray alloc] initWithArray:[_call objectForKey:CallReturnVisits]] autorelease];
	[_call setObject:returnVisits forKey:CallReturnVisits];
	
	NSMutableDictionary *visit = [[[NSMutableDictionary alloc] init] autorelease];

	[visit setObject:[NSDate date] forKey:CallReturnVisitDate];
	[visit setObject:@"" forKey:CallReturnVisitNotes];
	[visit setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallReturnVisitPublications];
	
	[returnVisits insertObject:visit atIndex:0];

	// unselect this row 
	[self reloadData];

    [theTableView beginUpdates];
		[theTableView deselectRowAtIndexPath:currentIndexPath animated:YES];
		[theTableView deleteSections:[NSIndexSet indexSetWithIndex:[currentIndexPath section]] withRowAnimation:UITableViewRowAnimationLeft];
		[theTableView insertSections:[NSIndexSet indexSetWithIndex:[currentIndexPath section]] withRowAnimation:UITableViewRowAnimationRight];
    [theTableView endUpdates];

}

- (void)deleteCall
{
	DEBUG(NSLog(@"deleteCall");)
	UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete the call (the return visits and placed literature will still be counted)?", @"Statement to make the user realize that this will still save information, and acknowledge they are deleting a call")
															 delegate:self
												    cancelButtonTitle:NSLocalizedString(@"No", @"No dont delete the call")
											   destructiveButtonTitle:NSLocalizedString(@"Yes", @"Yes delete the call")
												    otherButtonTitles:NSLocalizedString(@"Delete and don't keep info", @"Yes delete the call and the data"), nil] autorelease];
	// 0: grey with grey and black buttons
	// 1: black background with grey and black buttons
	// 2: transparent black background with grey and black buttons
	// 3: grey transparent background
	alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[alertSheet showInView:self.view];
	_actionSheetSource = NO;
}


- (void)changeNotesForReturnVisitAtIndex:(int)index
{
	DEBUG(NSLog(@"changeNotesForReturnVisitAtIndex: %d", index);)

	// they clicked on the Change Date
	_editingReturnVisit = [[_call objectForKey:CallReturnVisits] objectAtIndex:index];
	
	// make the new call view 
	NotesViewController *p = [[[NotesViewController alloc] initWithNotes:[_editingReturnVisit objectForKey:CallReturnVisitNotes]] autorelease];

	p.delegate = self;

	[[self navigationController] pushViewController:p animated:YES];		
}

- (void)changeDateOfReturnVisitAtIndex:(int)index
{
	DEBUG(NSLog(@"changeDateOfReturnVisitAtIndex: %d", index);)

	// they clicked on the Change Date
	_editingReturnVisit = [[_call objectForKey:CallReturnVisits] objectAtIndex:index];
	
	// make the new call view 
	DatePickerViewController *p = [[[DatePickerViewController alloc] initWithDate:[_editingReturnVisit objectForKey:CallReturnVisitDate]] autorelease];

	p.delegate = self;

	[[self navigationController] pushViewController:p animated:YES];		
}

- (void)changeTypeForReturnVisitAtIndex:(int)index
{
	DEBUG(NSLog(@"isStudyOnForReturnVisitAtIndex: %d", index);)

	// they clicked on the Change Type
	NSMutableArray *returnVisits = [_call objectForKey:CallReturnVisits];
	_editingReturnVisit = [returnVisits objectAtIndex:index];
	NSString *type = [_editingReturnVisit objectForKey:CallReturnVisitType];
	if(type == nil)
		type = CallReturnVisitTypeReturnVisit;
		
	// make the new call view 
	ReturnVisitTypeViewController *p = [[[ReturnVisitTypeViewController alloc] initWithType:type isInitialVisit:(returnVisits.count == index + 1)] autorelease];

	p.delegate = self;

	[[self navigationController] pushViewController:p animated:YES];		
}

- (void)addPublicationToReturnVisitAtIndex:(int)index
{
	DEBUG(NSLog(@"addPublicationToReturnVisitAtIndex: %d", index);)

	//this is the add a new entry one
	_editingReturnVisit = [[_call objectForKey:CallReturnVisits] objectAtIndex:index];
	
	_editingPublication = nil; // we are making a new one
	
	// make the new call view 
	PublicationTypeViewController *p = [[[PublicationTypeViewController alloc] init] autorelease];
	p.delegate = self;

	[[self navigationController] pushViewController:p animated:YES];		
}

- (void)changeReturnVisitAtIndex:(int)index publicationAtIndex:(int)publicationIndex
{
	DEBUG(NSLog(@"changeReturnVisitAtIndex: %d publicationAtIndex:%d", index, publicationIndex);)

	// they selected an existing entry
	_editingReturnVisit = [[_call objectForKey:CallReturnVisits] objectAtIndex:index];
	_editingPublication = [[_editingReturnVisit objectForKey:CallReturnVisitPublications] objectAtIndex:publicationIndex];
	
	// make the new call view 
	PublicationViewController *p = [[[PublicationViewController alloc] initWithPublication: [ _editingPublication objectForKey:CallReturnVisitPublicationName]
																					  year: [[_editingPublication objectForKey:CallReturnVisitPublicationYear] intValue]
																				     month: [[_editingPublication objectForKey:CallReturnVisitPublicationMonth] intValue]
																					   day: [[_editingPublication objectForKey:CallReturnVisitPublicationDay] intValue]] autorelease];

	p.delegate = self;
	[[self navigationController] pushViewController:p animated:YES];
}


#pragma mark Display Data functions

- (NSIndexPath *)lastIndexPath
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	return([NSIndexPath indexPathForRow:([[_currentGroup objectForKey:CallViewRows] count] - 1) inSection:([_displayInformation count] - 1)]);
}

- (void)addGroup:(NSString *)groupCell type:(const NSString *)type
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	_currentGroup = [[[NSMutableDictionary alloc] init] autorelease];
	
	// initialize the arrays
	[_currentGroup setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallViewRows];
	[_currentGroup setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallViewNames];
	[_currentGroup setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallViewSelectedInvocations];
	[_currentGroup setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallViewDeleteInvocations];
	[_currentGroup setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallViewInsertDelete];
	[_currentGroup setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallViewIndentWhenEditing];
	[_currentGroup setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallViewRowHeight];

	// set the group's settings
	if(groupCell != nil)
		[_currentGroup setObject:groupCell forKey:CallViewGroupText];

	[_currentGroup setObject:type forKey:CallViewType];

	[_displayInformation addObject:_currentGroup];
	DEBUG(NSLog(@"_displayInformation count = %d", [_displayInformation count]);)
}

- (void) addRowInvocation:(NSInvocation *)cellInvocation 
				 cellName:(NSString *)name
			 rowHeight:(int)rowHeight
     insertOrDelete:(UITableViewCellEditingStyle)insertOrDelete
  indentWhenEditing:(BOOL)indentWhenEditing 
   selectInvocation:(NSInvocation *)selectInvocation 
   deleteInvocation:(NSInvocation *)deleteInvocation
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	NSInvocation *dummyInvocation = [self invocationForSelector:@selector(dummyFunction)];

	[[_currentGroup objectForKey:CallViewRows] addObject:cellInvocation];
	[[_currentGroup objectForKey:CallViewNames] addObject:name];
	[[_currentGroup objectForKey:CallViewSelectedInvocations] addObject:(selectInvocation ? selectInvocation : dummyInvocation)];
	[[_currentGroup objectForKey:CallViewDeleteInvocations] addObject:(deleteInvocation ? deleteInvocation : dummyInvocation)];
	[[_currentGroup objectForKey:CallViewInsertDelete] addObject:[NSNumber numberWithInt:insertOrDelete]];
	[[_currentGroup objectForKey:CallViewIndentWhenEditing] addObject:[NSNumber numberWithBool:indentWhenEditing]];
	[[_currentGroup objectForKey:CallViewRowHeight] addObject:[NSNumber numberWithInt:rowHeight]];
}

#pragma mark Cell Getters

- (UITableViewCell *)getNameCell
{
	UITableViewTextFieldCell *cell = (UITableViewTextFieldCell *)[theTableView dequeueReusableCellWithIdentifier:@"NameCell"];
	if(cell == nil)
	{
		cell = [[UITableViewTextFieldCell alloc] initWithTextField:_name Frame:CGRectZero reuseIdentifier:@"NameCell"];
	}
	cell.delegate = self;
	cell.observeEditing = YES;
	if(_editing)
	{
		if(_setFirstResponderGroup == 0)
		{
#if 1
			[cell.textField performSelector:@selector(becomeFirstResponder)
								 withObject:nil
			                     afterDelay:0.0000001];
#else			
			[self performSelector:@selector(selectRow:) 
					   withObject:[[NSIndexPath indexPathForRow:0 inSection:0] retain]
					   afterDelay:0.00001];
#endif
			_setFirstResponderGroup = -1;
		}

		//  make it where they can hit hext and go into the address view to setup the address
		cell.nextKeyboardResponder = [[[SelectAddressView alloc] initWithTable:theTableView indexPath:[NSIndexPath indexPathForRow:0 inSection:1]] autorelease];
	}
	
	return(cell);
}

- (UITableViewCell *)getAddressCell
{
	AddressTableCell *cell = (AddressTableCell *)[theTableView dequeueReusableCellWithIdentifier:@"AddressCell"];
	if(cell == nil)
	{
		cell = [[[AddressTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"AddressCell"] autorelease];
	}
	[cell setStreetNumber:[_call objectForKey:CallStreetNumber] 
				apartment:[_call objectForKey:CallApartmentNumber] 
	               street:[_call objectForKey:CallStreet] 
				     city:[_call objectForKey:CallCity] 
					state:[_call objectForKey:CallState]];

	return(cell);
}

- (UITableViewCell *)getLocationTypeCell
{
	NSLocale * locale = [NSLocale currentLocale];
	NSLog(@"current locale %@", [locale localeIdentifier]);
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[theTableView dequeueReusableCellWithIdentifier:@"locationCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"locationCell"] autorelease];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	NSString *locationType = [_call objectForKey:CallLocationType];
	if(locationType == nil)
	{
		locationType = CallLocationTypeGoogleMaps;
	}
	[cell setValue:[[PSLocalization localizationBundle] localizedStringForKey:locationType value:locationType table:@""]];

	cell.hidesAccessoryWhenEditing = NO;
	
	// if this does not have a latitude/longitude then look it up
	if([locationType isEqualToString:CallLocationTypeGoogleMaps] &&
	   [_call objectForKey:CallLattitudeLongitude] != nil)
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	// if this does not have a latitude/longitude then look it up
	if([locationType isEqualToString:CallLocationTypeGoogleMaps] &&
	   [_call objectForKey:CallLattitudeLongitude] == nil)
	{
		// TODO: Need to have a spinnie show up here
	}
	return(cell);
}


- (UITableViewCell *)getAddMetadataCell
{
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[theTableView dequeueReusableCellWithIdentifier:@"addMetadataCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"addMetadataCell"] autorelease];
	}
	cell.accessoryType = UITableViewCellAccessoryNone;
	[cell setValue:NSLocalizedString(@"Add Additional Information", @"Button to click to add more information like phone number and email address")];

	return cell;
}

- (UITableViewCell *)getMetadataCellAtIndex:(int)metadataIndex
{
	NSMutableDictionary *metadata = [[_call objectForKey:CallMetadata] objectAtIndex:metadataIndex];
	NSNumber *type = [metadata objectForKey:CallMetadataType];
	NSString *name = [metadata objectForKey:CallMetadataName];
	NSString *value = [metadata objectForKey:CallMetadataValue];

	if([type intValue] == NOTES)
	{
		UITableViewMultilineTextCell *cell = (UITableViewMultilineTextCell *)[theTableView dequeueReusableCellWithIdentifier:@"MetadataNotesCell"];
		if(cell == nil)
		{
			cell = [[[UITableViewMultilineTextCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MetadataNotesCell"] autorelease];
		}
		cell.selectionStyle = _editing ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		[cell setText:value.length ? value : name];
		return(cell);
	}
	else
	{
		UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[theTableView dequeueReusableCellWithIdentifier:@"MetadataCell"];
		if(cell == nil)
		{
			cell = [[[UITableViewTitleAndValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"MetadataCell"] autorelease];
		}
		cell.accessoryType = UITableViewCellAccessoryNone;

		[cell setSelectionStyle:_editing ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone];
		switch([type intValue])
		{
			case PHONE:
			case EMAIL:
			case URL:
				[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
				// fallthrough
			default:
				[cell setTitle:[[PSLocalization localizationBundle] localizedStringForKey:name value:name table:@""]];
				[cell setValue:value];
				break;
		}
		return cell;
	}
}

- (UITableViewCell *)getAddReturnVisitCell
{
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[theTableView dequeueReusableCellWithIdentifier:@"AddReturnVisitCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"AddReturnVisitCell"] autorelease];
	}
	cell.accessoryType = UITableViewCellAccessoryNone;
	if([[_call objectForKey:CallReturnVisits] count])
	{
		[ cell setValue:NSLocalizedString(@"Add a return visit", @"Add a return visit action button")];
	}
	else
	{
		[ cell setValue:NSLocalizedString(@"Add a initial visit", @"Add a initial visit action buton")];
	}
	return(cell);
}

- (UITableViewCell *)getNotesCellForReturnVisitIndex:(int)returnVisitIndex
{
	UITableViewMultilineTextCell *cell = (UITableViewMultilineTextCell *)[theTableView dequeueReusableCellWithIdentifier:@"NotesCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewMultilineTextCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"NotesCell"] autorelease];
	}
	NSMutableString *notes = [[[_call objectForKey:CallReturnVisits] objectAtIndex:returnVisitIndex] objectForKey:CallReturnVisitNotes];

	if(_editing)
	{
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		if([notes length] == 0)
			[cell setText:NSLocalizedString(@"Add Notes", @"Return Visit Notes Placeholder text")];
		else
			[cell setText:notes];
	}
	else
	{
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		if([notes length] == 0)
		{
			if([[_call objectForKey:CallReturnVisits] count] == returnVisitIndex + 1)
				[cell setText:NSLocalizedString(@"Initial Visit Notes", @"Initial Visit Notes default text when the user did not enter notes, displayed on the view-mode Call view")];
			else
				[cell setText:NSLocalizedString(@"Return Visit Notes", @"Return Visit Notes default text when the user did not enter notes, displayed on the view-mode Call view")];
		}
		else
		{
			[cell setText:notes];
		}
	}
	return(cell);
}

- (UITableViewCell *)getChangeDateCellForReturnVisitIndex:(int)returnVisitIndex
{
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[theTableView dequeueReusableCellWithIdentifier:@"ChangeDateCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ChangeDateCell"] autorelease];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[cell setValue:NSLocalizedString(@"Change Date", @"Change Date action button for visit in call view")];
//	cell.valueLabel.textAlignment = UITextAlignmentCenter;
	return(cell);
}

- (UITableViewCell *)getTypeCellForReturnVisitIndex:(int)returnVisitIndex
{
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[theTableView dequeueReusableCellWithIdentifier:@"returnVisitTypeCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"returnVisitTypeCell"] autorelease];
	}
	NSArray *returnVisits = [_call objectForKey:CallReturnVisits];
	NSString *type = [[returnVisits objectAtIndex:returnVisitIndex] objectForKey:CallReturnVisitType];
	if(type == nil)
		type = CallReturnVisitTypeReturnVisit;


	[cell setTitle:NSLocalizedString(@"Type", @"Return visit type label")];
	// if this is the initial visit, then just say that it is the initial visit
	if([type isEqualToString:CallReturnVisitTypeReturnVisit] && returnVisits.count == (returnVisitIndex + 1))
	{
		[cell setValue:NSLocalizedString(@"Initial Visit", @"This is used to signify the first visit which is not counted as a return visit.  This is in the view where you get to pick the visit type")];
	}
	else
	{
		[cell setValue:[[PSLocalization localizationBundle] localizedStringForKey:type value:type table:@""]];
	}

	cell.accessoryType = _editing ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	cell.selectionStyle = _editing ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;

	return(cell);
}

- (UITableViewCell *)getPublicationCellForReturnVisitIndex:(int)returnVisitIndex publicationIndex:(int)publicationIndex
{
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[theTableView dequeueReusableCellWithIdentifier:@"PublicationCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc ] initWithFrame:CGRectZero reuseIdentifier:@"PublicationCell"] autorelease];
	}
	cell.accessoryType = _editing ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	cell.selectionStyle = _editing ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	[cell setTitle:[[[[[_call objectForKey:CallReturnVisits] objectAtIndex:returnVisitIndex] objectForKey:CallReturnVisitPublications] objectAtIndex:publicationIndex] objectForKey:CallReturnVisitPublicationTitle]];
	return(cell);
}

- (UITableViewCell *)getAddPublicationCellForReturnVisitIndex:(int)returnVisitIndex
{
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[theTableView dequeueReusableCellWithIdentifier:@"AddPublicationCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"AddPublicationCell"] autorelease];
	}
	cell.hidden = NO;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	[cell setValue:NSLocalizedString(@"Add a placed publication", @"Add a placed publication action button in call view")];
	return(cell);
}

- (UITableViewCell *)getDeleteCallCell
{
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[theTableView dequeueReusableCellWithIdentifier:@"DeleteCallCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc ] initWithFrame:CGRectMake(0, 0, 320, 45) reuseIdentifier:@"DeleteCallCell"] autorelease];
	}
#if 0
	[cell setTitle:NSLocalizedString(@"Delete Call", @"Delete Call button in editing mode of call view")];
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.backgroundColor = [UIColor redColor];
	cell.titleLabel.textColor = [UIColor redColor];
	cell.titleLabel.textAlignment  = UITextAlignmentCenter;
	cell.titleLabel.backgroundColor = [UIColor clearColor];
	
#else
	CGRect frame = CGRectMake(5, 0, 310, 45);
	
	UIButton *button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	button.frame = frame;
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	[button setTitle:NSLocalizedString(@"Delete Call", @"Delete Call button in editing mode of call view") forState:UIControlStateNormal];	
	[button setFont:[UIFont boldSystemFontOfSize:16]];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	UIImage *newImage = [[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:newImage forState:UIControlStateNormal];
	
	UIImage *selectedImage = [[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
	
	[button addTarget:self action:@selector(deleteCall) forControlEvents:UIControlEventTouchUpInside];
	
    // in case the parent view draws with a custom color or gradient, use a transparent color
	button.backgroundColor = [UIColor clearColor];	

	[cell addSubview:button];
#endif	
	return(cell);
}



- (void)reloadData
{
	DEBUG(NSLog(@"CallView reloadData");)
	// get rid of the last display information, we double buffer this to get around a douple reloadData call
	[_displayInformation release];
	_displayInformation = [[NSMutableArray alloc] init];

	// Name
	if(_editing || [[_call objectForKey:CallName] length])
	{
		[self addGroup:nil type:@"Name"];

		// use the textfield
		[self  addRowInvocation:[self invocationForSelector:@selector(getNameCell)]
		           cellName:@"Name"     
				 rowHeight:50
			insertOrDelete:UITableViewCellEditingStyleNone
		 indentWhenEditing:NO
		  selectInvocation:nil
		  deleteInvocation:nil];
	}
	
	// Address
	{
		NSString *streetNumber = [_call objectForKey:CallStreetNumber];
		NSString *apartmentNumber = [_call objectForKey:CallApartmentNumber];
		NSString *street = [_call objectForKey:CallStreet];
		NSString *city = [_call objectForKey:CallCity];
		NSString *state = [_call objectForKey:CallState];
		NSString *latLong = [_call objectForKey:CallLattitudeLongitude];

		BOOL found = NO;
		if((streetNumber && [streetNumber length]) ||
		   (apartmentNumber && [apartmentNumber length]) || 
		   (street && [street length]) || 
		   (city && [city length]) || 
		   (state && [state length]) ||
		   (latLong && ![latLong isEqualToString:@"nil"]))
		{
			found = YES;
		}

		// if there was no street information then just dont display
		// the address (unless we are editing
		if(found || _editing)
		{
			// add a group for the name
			[self addGroup:nil type:@"Address"];
			
			[self  addRowInvocation:[self invocationForSelector:@selector(getAddressCell)]
						   cellName:@"Address"
					 rowHeight:70
				insertOrDelete:UITableViewCellEditingStyleNone
			 indentWhenEditing:NO
			  selectInvocation:[self invocationForSelector:@selector(addressSelected)]
			  deleteInvocation:nil];

			if(_editing)
			{
				[self  addRowInvocation:[self invocationForSelector:@selector(getLocationTypeCell)]
						   cellName:@"Location"
						 rowHeight:-1
					insertOrDelete:UITableViewCellEditingStyleNone
				 indentWhenEditing:NO
				  selectInvocation:[self invocationForSelector:@selector(locationTypeSelected)]
				  deleteInvocation:nil];
			}
		}
	}

	// Add Metadata
	{
		// they had an array of publications, lets check them too
		NSMutableArray *metadata = [_call objectForKey:CallMetadata];
		if(_editing || (metadata && metadata.count))
		{
			// we need a larger row height
			[self addGroup:nil type:@"Metadata"];
			if(metadata != nil)
			{
				int j;
				int endMetadata = [metadata count];
				for(j = 0; j < endMetadata; ++j)
				{
					// METADATA
					int height = -1;
					NSMutableDictionary *entry = [metadata objectAtIndex:j];
					// if the entry is a notes entry then we need to adjust the height of the cell
					if([[entry objectForKey:SettingsMetadataType] intValue] == NOTES &&
					   [[entry objectForKey:SettingsMetadataValue] length])
					{
						height = [UITableViewMultilineTextCell heightForWidth:250 withText:[entry objectForKey:SettingsMetadataValue]];
					}
					[self  addRowInvocation:[self invocationForSelector:@selector(getMetadataCellAtIndex:) withArgument:(void *)j]
							   cellName:[entry objectForKey:SettingsMetadataName]
								 rowHeight:height
							insertOrDelete:(_editing ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone)
						indentWhenEditing:YES
						  selectInvocation:[self invocationForSelector:@selector(selectMetadataAtIndex:) withArgument:(void *)j]
						  deleteInvocation:[self invocationForSelector:@selector(deleteMetadataAtIndex:) withArgument:(void *)j]];
				}
			}

			if(_editing)
			{
				[self  addRowInvocation:[self invocationForSelector:@selector(getAddMetadataCell)]
							   cellName:@"New Metadata UNIQUE TITLE"
						 rowHeight:-1
					insertOrDelete:UITableViewCellEditingStyleInsert
				 indentWhenEditing:YES
				  selectInvocation:[self invocationForSelector:@selector(addMetadataSelected)]
				  deleteInvocation:nil];
			}
		}
	}

	// Add new Call
	if(_showAddCall && _editing)
	{
		// we need a larger row height
		[self addGroup:nil type:@"AddCall"];

		[self  addRowInvocation:[self invocationForSelector:@selector(getAddReturnVisitCell)]
					   cellName:@"Add Call"
				 rowHeight:-1
			insertOrDelete:UITableViewCellEditingStyleInsert
		 indentWhenEditing:YES
		  selectInvocation:[self invocationForSelector:@selector(addReturnVisitSelected)]
		  deleteInvocation:nil];
	}

	// RETURN VISITS
	{
		NSMutableArray *returnVisits = [_call objectForKey:CallReturnVisits];
		NSMutableDictionary *visit;

		int i;
		int end = [returnVisits count];
		for(i = 0; i < end; ++i)
		{
			visit = [returnVisits objectAtIndex:i];

			// GROUP TITLE
			NSDate *date = [visit objectForKey:CallReturnVisitDate];	
			// create dictionary entry for This Return Visit
			NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
			if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
			{
				[dateFormatter setDateFormat:@"EEE, d/M/yyy h:mma"];
			}
			else
			{
				[dateFormatter setDateFormat:NSLocalizedString(@"EEE, M/d/yyy h:mma", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
			}
			NSString *formattedDateString = [NSString stringWithString:[dateFormatter stringFromDate:date]];			
			[self addGroup:formattedDateString type:@"Visit"];


DEBUG(NSLog(@"CallView %s:%d", __FILE__, __LINE__);)
			// NOTES
			if(_editing)
			{
				[self  addRowInvocation:[self invocationForSelector:@selector(getNotesCellForReturnVisitIndex:) withArgument:(void *)i]
						   cellName:@"Notes"
						 rowHeight:[UITableViewMultilineTextCell heightForWidth:(self.view.bounds.size.width - 70) withText:[[returnVisits objectAtIndex:i] objectForKey:CallReturnVisitNotes]]
					insertOrDelete:(end == 1 ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete)
				 indentWhenEditing:YES
				  selectInvocation:[self invocationForSelector:@selector(changeNotesForReturnVisitAtIndex:) withArgument:(void *)i]
				  deleteInvocation:[self invocationForSelector:@selector(deleteReturnVisitAtIndex:) withArgument:(void *)i]];
			}
			else
			{
				[self  addRowInvocation:[self invocationForSelector:@selector(getNotesCellForReturnVisitIndex:) withArgument:(void *)i]
						   cellName:@"Notes"
						 rowHeight:[UITableViewMultilineTextCell heightForWidth:(self.view.bounds.size.width - 70) withText:[[returnVisits objectAtIndex:i] objectForKey:CallReturnVisitNotes]]
					insertOrDelete:UITableViewCellEditingStyleNone
				 indentWhenEditing:NO
				  selectInvocation:nil
				  deleteInvocation:nil];
			}
DEBUG(NSLog(@"CallView %s:%d", __FILE__, __LINE__);)
	
			// CHANGE DATE
			if(_editing)
			{
				[self  addRowInvocation:[self invocationForSelector:@selector(getChangeDateCellForReturnVisitIndex:) withArgument:(void *)i]
						   cellName:@"ChangeDate"
						 rowHeight:-1
					insertOrDelete:UITableViewCellEditingStyleNone
           		 indentWhenEditing:YES
				  selectInvocation:[self invocationForSelector:@selector(changeDateOfReturnVisitAtIndex:) withArgument:(void *)i]
				  deleteInvocation:nil];
			}
 
			// STUDY (only show if you are editing or this is a study)
			NSString *type = [visit objectForKey:CallReturnVisitType];
			if(type == nil)
				type = CallReturnVisitTypeReturnVisit;
				
			if(_editing || ![type isEqualToString:CallReturnVisitTypeReturnVisit])
			{
				[self  addRowInvocation:[self invocationForSelector:@selector(getTypeCellForReturnVisitIndex:) withArgument:(void *)i]
						   cellName:@"Return Visit Type"
						 rowHeight:-1
					insertOrDelete:UITableViewCellEditingStyleNone
				 indentWhenEditing:YES
				  selectInvocation:(_editing ? [self invocationForSelector:@selector(changeTypeForReturnVisitAtIndex:) withArgument:(void *)i] : nil)
				  deleteInvocation:nil];
			}

DEBUG(NSLog(@"CallView %s:%d", __FILE__, __LINE__);)
			// Publications
			if([visit objectForKey:CallReturnVisitPublications] != nil)
			{
				// they had an array of publications, lets check them too
				NSMutableArray *publications = [visit objectForKey:CallReturnVisitPublications];
				int j;
				int endPublications = [publications count];
				for(j = 0; j < endPublications; ++j)
				{
DEBUG(NSLog(@"CallView %s:%d", __FILE__, __LINE__);)
					// PUBLICATION

					if(_editing)
					{
						[self  addRowInvocation:[self invocationForSelector:@selector(getPublicationCellForReturnVisitIndex:publicationIndex:) withArgument:(void *)i andArgument:(void *)j]
						   cellName:[[publications objectAtIndex:j] objectForKey:CallReturnVisitPublicationTitle]
								 rowHeight:-1
							insertOrDelete:UITableViewCellEditingStyleDelete
						indentWhenEditing:YES
						  selectInvocation:[self invocationForSelector:@selector(changeReturnVisitAtIndex:publicationAtIndex:) withArgument:(void *)i andArgument:(void *)j]
						  deleteInvocation:[self invocationForSelector:@selector(deleteReturnVisitAtIndex:publicationAtIndex:) withArgument:(void *)i andArgument:(void *)j]];
					}
					else
					{
						[self  addRowInvocation:[self invocationForSelector:@selector(getPublicationCellForReturnVisitIndex:publicationIndex:) withArgument:(void *)i andArgument:(void *)j]
									   cellName:[[publications objectAtIndex:j] objectForKey:CallReturnVisitPublicationTitle]
								 rowHeight:-1
							insertOrDelete:UITableViewCellEditingStyleNone
						indentWhenEditing:NO
						  selectInvocation:nil
						  deleteInvocation:nil];
					}
				}
			}
			
			// add publication
			if(_editing)
			{
				[self  addRowInvocation:[self invocationForSelector:@selector(getAddPublicationCellForReturnVisitIndex:) withArgument:(void *)i]
						   cellName:@"Add Publication"
						 rowHeight:-1
					insertOrDelete:UITableViewCellEditingStyleInsert
				 indentWhenEditing:YES
				  selectInvocation:[self invocationForSelector:@selector(addPublicationToReturnVisitAtIndex:) withArgument:(void *)i]
				  deleteInvocation:nil];
			}
		}
	}

	// DELETE call
	if(_editing && !_newCall)
	{
		[self addGroup:nil type:@"Delete"];

		[self  addRowInvocation:[self invocationForSelector:@selector(getDeleteCallCell)]
					   cellName:@"Delete"
				 rowHeight:-1
			insertOrDelete:UITableViewCellEditingStyleNone
		 indentWhenEditing:NO
		  selectInvocation:[self invocationForSelector:@selector(deleteCall)]
		  deleteInvocation:nil];
	}

	DEBUG(NSLog(@"CallView reloadData %s:%d", __FILE__, __LINE__);)
}


/******************************************************************
 *
 *   Location
 *
 ******************************************************************/
#pragma mark Location Delegate
- (void)locationPickerViewControllerDone:(LocationPickerViewController *)locationPickerViewController
{
	[_call setObject:locationPickerViewController.type forKey:CallLocationType];
	if([locationPickerViewController.type isEqualToString:CallLocationTypeManual])
	{
		SelectPositionMapViewController *controller = [[[SelectPositionMapViewController alloc] initWithPosition:[_call objectForKey:CallLattitudeLongitude]] autorelease];
		controller.delegate = self;
		[[self navigationController] pushViewController:controller animated:YES];
	}
	else if([locationPickerViewController.type isEqualToString:CallLocationTypeGoogleMaps])
	{
		// they are using google maps so kick off a lookup
		[[Geocache sharedInstance] lookupCall:_call];
	}
	[[Settings sharedInstance] saveData];
}

- (void)selectPositionMapViewControllerDone:(SelectPositionMapViewController *)selectPositionMapViewController
{
	[_call setObject:[NSString stringWithFormat:@"%f, %f", selectPositionMapViewController.point.latitude, selectPositionMapViewController.point.longitude] forKey:CallLattitudeLongitude];
	[[Settings sharedInstance] saveData];
}

/******************************************************************
 *
 *   METADATA
 *
 ******************************************************************/
#pragma mark Metadata Delegate
- (void)metadataViewControllerAdd:(MetadataViewController *)metadataViewController metadataInformation:(MetadataInformation *)metadataInformation
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	NSMutableArray *metadata = [NSMutableArray arrayWithArray:[_call objectForKey:CallMetadata]];
	[_call setObject:metadata forKey:CallMetadata];

	NSMutableDictionary *newData = [[[NSMutableDictionary alloc] init] autorelease];
	[metadata addObject:newData];
	[newData setObject:metadataInformation->name forKey:CallMetadataName];
	[newData setObject:[NSNumber numberWithInt:metadataInformation->type] forKey:CallMetadataType];
	switch(metadataInformation->type)
	{
		case PHONE:
		case EMAIL:
		case NOTES:
		case URL:
		case STRING:
			[newData setObject:@"" forKey:CallMetadataValue];
			[newData setObject:@"" forKey:CallMetadataData];
			break;
		case DATE:
		{
			NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
			if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
			{
				[dateFormatter setDateFormat:@"EEE, d/M/yyy h:mma"];
			}
			else
			{
				[dateFormatter setDateFormat:NSLocalizedString(@"EEE, M/d/yyy h:mma", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
			}
			NSDate *date = [NSDate date];
			NSString *formattedDateString = [NSString stringWithString:[dateFormatter stringFromDate:date]];			
			[newData setObject:formattedDateString forKey:CallMetadataValue];
			[newData setObject:date forKey:CallMetadataData];
			break;
		}
	}
	[self reloadData];
	[self save];
	[theTableView reloadData];
}

- (void)metadataEditorViewControllerDone:(MetadataEditorViewController *)metadataEditorViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	int index = [[_call objectForKey:CallMetadata] indexOfObject:_editingMetadata];

	NSMutableArray *metadata = [NSMutableArray arrayWithArray:[_call objectForKey:CallMetadata]];
	[_call setObject:metadata forKey:CallMetadata];
	
	_editingMetadata = [metadata objectAtIndex:index];
	[_editingMetadata setObject:[metadataEditorViewController data] forKey:CallMetadataData];
	[_editingMetadata setObject:[metadataEditorViewController value] forKey:CallMetadataValue];

	[self reloadData];
	[self save];
	[theTableView reloadData];
}

/******************************************************************
 *
 *   NOTES VIEW CALLBACKS
 *
 ******************************************************************/
#pragma mark NotesView Delegate
- (void)notesViewControllerDone:(NotesViewController *)notesViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
    [_editingReturnVisit setObject:[notesViewController notes] forKey:CallReturnVisitNotes];
	_editingReturnVisit = nil;
	[self reloadData];
	[self save];
	[theTableView reloadData];
}

/******************************************************************
 *
 *   TYPE VIEW CALLBACKS
 *
 ******************************************************************/
#pragma mark ReturnVisitTypeView Delegate
- (void)returnVisitTypeViewControllerDone:(ReturnVisitTypeViewController *)returnVisitTypeViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
    [_editingReturnVisit setObject:[returnVisitTypeViewController type] forKey:CallReturnVisitType];
	_editingReturnVisit = nil;
	[self reloadData];
	[self save];
	[theTableView reloadData];
}

/******************************************************************
 *
 *   ADDRESS VIEW CALLBACKS
 *
 ******************************************************************/
#pragma mark AddressView Delegate
- (void)addressViewControllerDone:(AddressViewController *)addressViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	[_call setObject:(addressViewController.streetNumber ? addressViewController.streetNumber : @"") forKey:CallStreetNumber];
	[_call setObject:(addressViewController.apartmentNumber ? addressViewController.apartmentNumber : @"") forKey:CallApartmentNumber];
	[_call setObject:(addressViewController.street ? addressViewController.street : @"") forKey:CallStreet];
	[_call setObject:(addressViewController.city ? addressViewController.city : @"") forKey:CallCity];
	[_call setObject:(addressViewController.state ? addressViewController.state : @"") forKey:CallState];
	// remove the gps location so that they will look it up again
	[_call removeObjectForKey:CallLattitudeLongitude];
	
	[self reloadData];
	[self save];
	if(![[_call objectForKey:CallLocationType] isEqualToString:CallLocationTypeManual])
	{
		[[Geocache sharedInstance] lookupCall:_call];
	}

	[theTableView reloadData];
}

/******************************************************************
 *
 *   PUBLICATION VIEW CALLBACKS
 *
 ******************************************************************/
#pragma mark PublicationView Delegate

- (void)publicationViewControllerDone:(PublicationViewController *)publicationViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	bool newPublication = (_editingPublication == nil);
    if(newPublication)
    {
        VERBOSE(NSLog(@"creating a new publication entry and adding it");)
        // if we are adding a publication then create the NSDictionary and add it to the end
        // of the publications array
        _editingPublication = [[[NSMutableDictionary alloc] init] autorelease];
        [[_editingReturnVisit objectForKey:CallReturnVisitPublications] addObject:_editingPublication];
    }
    VERBOSE(NSLog(@"_editingPublication was = %@", _editingPublication);)
	PublicationPickerView *picker = [publicationViewController publicationPicker];
    [_editingPublication setObject:[picker publication] forKey:CallReturnVisitPublicationName];
    [_editingPublication setObject:[picker publicationTitle] forKey:CallReturnVisitPublicationTitle];
    [_editingPublication setObject:[picker publicationType] forKey:CallReturnVisitPublicationType];
    [_editingPublication setObject:[[[NSNumber alloc] initWithInt:[picker year]] autorelease] forKey:CallReturnVisitPublicationYear];
    [_editingPublication setObject:[[[NSNumber alloc] initWithInt:[picker month]] autorelease] forKey:CallReturnVisitPublicationMonth];
    [_editingPublication setObject:[[[NSNumber alloc] initWithInt:[picker day]] autorelease] forKey:CallReturnVisitPublicationDay];
    VERBOSE(NSLog(@"_editingPublication is = %@", _editingPublication);)
	_editingPublication = nil;
	_editingReturnVisit = nil;
	
	// save the data
	[self reloadData];
	[self save];
	
	if(newPublication)
	{
		[theTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:currentIndexPath] withRowAnimation:UITableViewRowAnimationRight];
	}
	else
	{
		[theTableView reloadData];
	}
}



- (void)datePickerViewControllerDone:(DatePickerViewController *)datePickerViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
    VERBOSE(NSLog(@"date is now = %@", [datePickerViewController date]);)

    [_editingReturnVisit setObject:[datePickerViewController date] forKey:CallReturnVisitDate];
    
	[self reloadData];
	[self save];
	[theTableView reloadData];
}


/******************************************************************
 *
 *   ACTION SHEET DELEGATE FUNCTIONS
 *
 ******************************************************************/
#pragma mark ActionSheet Delegate

- (BOOL)emailCallToUser
{
	// add notes if there are any
	NSString *value;
		
	NSMutableString *string = [[[NSMutableString alloc] initWithString:@"mailto:?"] autorelease];
	[string appendString:@"subject="];
	[string appendString:[NSLocalizedString(@"MyTime Call, open this on your iPhone/iTouch", @"Subject text for the email that is sent for sending the details of a call to another witness") stringWithEscapedCharacters]];
	[string appendString:@"&body="];

	[string appendString:[NSLocalizedString(@"This return visit has been turned over to you, here are the details.  If you are a MyTime user, please view this email on your iPhone/iTouch and scroll all the way down to the end of the email and click on the link to import this call into MyTime.\n\nReturn Visit Details:\n", @"This is the first part of the body of the email message that is sent to a user when you click on a Call then click on Edit and then click on the action button in the upper left corner and select transfer or email details") stringWithEscapedCharacters]];
	[string appendString:[[NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"Name", @"Name label for Call in editing mode"), [_call objectForKey:CallName]] stringWithEscapedCharacters]];
	
	NSMutableString *top = [[NSMutableString alloc] init];
	NSMutableString *bottom = [[NSMutableString alloc] init];
	[Settings formatStreetNumber:[_call objectForKey:CallStreetNumber]
	                   apartment:[_call objectForKey:CallApartmentNumber]
					      street:[_call objectForKey:CallStreet]
							city:[_call objectForKey:CallCity]
						   state:[_call objectForKey:CallState]
						 topLine:top 
				      bottomLine:bottom];
	[string appendString:[[NSString stringWithFormat:@"%@:\n%@\n%@\n", NSLocalizedString(@"Address", @"Address label for call"), top, bottom] stringWithEscapedCharacters]];
	[top release];
	[bottom release];
	top = nil;
	bottom = nil;
	
	// Add Metadata
	// they had an array of publications, lets check them too
	NSMutableArray *metadata = [_call objectForKey:CallMetadata];
	if(metadata != nil)
	{
		int j;
		int endMetadata = [metadata count];
		for(j = 0; j < endMetadata; ++j)
		{
			// METADATA
			NSMutableDictionary *entry = [metadata objectAtIndex:j];
			NSString *name = [entry objectForKey:SettingsMetadataName];
			value = [entry objectForKey:SettingsMetadataValue];
			[string appendString:[[NSString stringWithFormat:@"%@: %@\n", [[PSLocalization localizationBundle] localizedStringForKey:name value:name table:@""], value] stringWithEscapedCharacters]];
		}
	}

	[string appendString:[[NSString stringWithFormat:@"\n"] stringWithEscapedCharacters]];
	

	NSMutableArray *returnVisits = [_call objectForKey:CallReturnVisits];
	NSMutableDictionary *visit;

	int i;
	int end = [returnVisits count];
	for(i = 0; i < end; ++i)
	{
		visit = [returnVisits objectAtIndex:i];

		// GROUP TITLE
		NSDate *date = [visit objectForKey:CallReturnVisitDate];	
		// create dictionary entry for This Return Visit
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
		{
			[dateFormatter setDateFormat:@"EEE, d/M/yyy h:mma"];
		}
		else
		{
			[dateFormatter setDateFormat:NSLocalizedString(@"EEE, M/d/yyy h:mma", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
		}
		NSString *formattedDateString = [NSString stringWithString:[dateFormatter stringFromDate:date]];			

		[string appendString:[[NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"Return Visit", @"return visit type name"), formattedDateString] stringWithEscapedCharacters]];
		value = [visit objectForKey:CallReturnVisitType];
		[string appendString:[[NSString stringWithFormat:@"%@\n", [[PSLocalization localizationBundle] localizedStringForKey:value value:value table:@""]] stringWithEscapedCharacters]];
		[string appendString:[[NSString stringWithFormat:@"%@:\n%@\n", NSLocalizedString(@"Notes", @"Call Metadata"), [visit objectForKey:CallReturnVisitNotes]] stringWithEscapedCharacters]];

		// Publications
		if([visit objectForKey:CallReturnVisitPublications] != nil)
		{
			// they had an array of publications, lets check them too
			NSMutableArray *publications = [visit objectForKey:CallReturnVisitPublications];
			int j;
			int endPublications = [publications count];
			for(j = 0; j < endPublications; ++j)
			{
				NSDictionary *publication = [publications objectAtIndex:j];
				// PUBLICATION
				[string appendString:[[NSString stringWithFormat:@"%@\n", [publication objectForKey:CallReturnVisitPublicationTitle]] stringWithEscapedCharacters]];
			}
		}
		[string appendString:[[NSString stringWithFormat:@"  \n"] stringWithEscapedCharacters]];
	}

	[string appendString:[NSLocalizedString(@"You are able to import this call into MyTime if you click on the link below while viewing this email from your iPhone/iTouch.  Please make sure that at the end of this email there is a \"VERIFICATION CHECK:\" right after the link, it verifies that all data is contained within this email\n", @"This is the second part of the body of the email message that is sent to a user when you click on a Call then click on Edit and then click on the action button in the upper left corner and select transfer or email details") stringWithEscapedCharacters]];

	// now add the url that will allow importing

	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_call];
	NSMutableString *theurl = [NSMutableString string];
	NSMutableString *link = [NSMutableString string];
	[link appendString:@"<a href=\""];
	[theurl appendString:@"mytime://mytime/addCall?"];
	int length = data.length;
	unsigned char *bytes = (unsigned char *)data.bytes;
	for(int i = 0; i < length; ++i)
	{
		[theurl appendFormat:@"%02X", *bytes++];
	}
	[link appendString:theurl];
	[link appendString:@"\">"];
	[link appendString:NSLocalizedString(@"Click on this link from your iPhone/iTouch", @"This is the text that appears in the link of the email when you are transferring a call to another witness.  this is the link that they press to open MyTime")];
	[link appendString:@"</a>\n\n"];
	[link appendString:NSLocalizedString(@"VERIFICATION CHECK: all data was contained in this email", @"This is a very important message that is at the end of the email used to transfer a call to another witness or if you are just emailing a backup to yourself, it verifies that all of the data is contained in the email, if it is not there then all of the data is not in the email and something bad happened :(")];



	[string appendString:[link stringWithEscapedCharacters]];

	// open the mail program
	NSURL *url = [NSURL URLWithString:string];
	BOOL worked = [[UIApplication sharedApplication] openURL:url];
	NSLog(@"it %s", worked ? "worked" : "did not work");
	return worked;
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{
	VERBOSE(NSLog(@"alertSheet: button:%d", button);)
//	[sheet dismissAnimated:YES];
	if(_actionSheetSource)
	{
		switch(button)
		{
			//transfer
			case 0:
			{
				if([self emailCallToUser])
				{
					[delegate callViewController:self deleteCall:_call keepInformation:YES];
				}
				break;
			}
			// email
			case 1:
			{
				[self emailCallToUser];
				break;
			}
		}
	}
	else
	{
		[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
		if(button == 0)
		{
			if(delegate)
			{
				[delegate callViewController:self deleteCall:_call keepInformation:YES];
				[self.navigationController popViewControllerAnimated:YES];

			}
		}
		if(button == 1)
		{
			if(delegate)
			{
				[delegate callViewController:self deleteCall:_call keepInformation:NO];
				[self.navigationController popViewControllerAnimated:YES];
			}
		}
	}
}

#pragma mark Table DataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
    int count = [_displayInformation count];
	VERBOSE(NSLog(@"count=%d", count);)
    return(count);
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{
	VERBOSE(NSLog(@"tableView numberOfRowsInSection:%d", section);)
	if(section >= [_displayInformation count])
		return(0);
    int count = [[[_displayInformation objectAtIndex:section] objectForKey:CallViewRows] count];
	VERBOSE(NSLog(@"count=%d", count);)
	return(count);
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    VERBOSE(NSLog(@"tableView: titleForHeaderInSection:%d", section);)
	NSString *title = [[_displayInformation objectAtIndex:section] objectForKey:CallViewGroupText];
	int retCount = [title retainCount];
	if(title)
		assert(retCount);
    return(title);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
	int section = [indexPath section];
	NSMutableArray *array = [[_displayInformation objectAtIndex:section] objectForKey:CallViewRows];
	NSInvocation *invocation = [array objectAtIndex:row];
	[invocation invoke];
	UITableViewCell *cell;
	[invocation getReturnValue:&cell];
    VERBOSE(NSLog(@"tableView: cellForRow:%d inSection:%d cell=%p", row, section, cell);)
	return(cell);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
	int section = [indexPath section];
	float height = [[[[_displayInformation objectAtIndex:section] objectForKey:CallViewRowHeight] objectAtIndex:row] floatValue];
	
	if(height < 0.0)
		height = theTableView.rowHeight;
	VERBOSE(NSLog(@"tableView: heightForRowAtIndexPath: row=%d section=%d height=%f", row, section, height);)
	return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    DEBUG(NSLog(@"tableRowSelected: tableRowSelected section=%d row=%d editing%d", section, row, _editing);)

	_selectedRow = row;
	self.currentIndexPath = indexPath;
	assert([_displayInformation count] > section);
	NSInvocation *invocation = [[[[[_displayInformation objectAtIndex:section] objectForKey:CallViewSelectedInvocations] objectAtIndex:row] retain] autorelease];
	[invocation invoke];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
	assert([_displayInformation count] > section);
	BOOL ret = [[[[_displayInformation objectAtIndex:section] objectForKey:CallViewIndentWhenEditing] objectAtIndex:row] boolValue];
    DEBUG(NSLog(@"tableView: shouldIndentWhileEditingRowAtIndexPath section=%d row=%d editing=%d return=%d", section, row, _editing, ret);)
	return(ret);
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    DEBUG(NSLog(@"tableView: indentationLevelForRowAtIndexPath section=%d row=%d editing%d", section, row, _editing);)
	return(0);
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
	self.currentIndexPath = indexPath;
    DEBUG(NSLog(@"tableView: editingStyleForRowAtIndexPath section=%d row=%d editing%d", section, row, _editing);)
	assert([_displayInformation count] > section);
	return [[[[_displayInformation objectAtIndex:section] objectForKey:CallViewInsertDelete] objectAtIndex:row] intValue];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    DEBUG(NSLog(@"tableView: editingStyleForRowAtIndexPath section=%d row=%d editing%d", section, row, _editing);)
	assert([_displayInformation count] > section);
	self.currentIndexPath = indexPath;
	switch(editingStyle)
	{
		case UITableViewCellEditingStyleInsert:
			[tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
			[self tableView:tableView didSelectRowAtIndexPath:indexPath];
			break;
		case UITableViewCellEditingStyleDelete:
		{
			NSInvocation *invocation = [[[[[_displayInformation objectAtIndex:section] objectForKey:CallViewDeleteInvocations] objectAtIndex:row] retain] autorelease];
			[invocation invoke];
			break;
		}
	}
}

/******************************************************************
 *
 *   ACCESSOR METHODS
 *
 ******************************************************************/
#pragma mark Accessors

- (NSString *)name
{
    if(_name.text == nil)
        return @"";
    else
        return _name.text;
}

- (NSString *)street
{
    return([_call objectForKey:CallStreet]);
}

- (NSString *)city
{
    return([_call objectForKey:CallCity]);
}

- (NSString *)state
{
    return([_call objectForKey:CallState]);
}

- (NSMutableDictionary *)call
{
    VERBOSE(NSLog(@"CallView call:");)
    [_call setObject:[self name] forKey:CallName];
    VERBOSE(NSLog(@"CallView call: %@", _call);)
    return(_call);
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


