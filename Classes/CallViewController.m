//
//  CallViewController.m
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "CallViewController.h"
#import "Settings.h"
#import "UITableViewTitleAndValueCell.h"
#import "AddressViewController.h"
#import "PublicationViewController.h"
#import "PublicationTypeViewController.h"
#import "WebViewController.h"
#import "DatePickerViewController.h"
#import "UITableViewMultilineTextCell.h"
#import "NotesViewController.h"
#import "AddressTableCell.h"
#import "SwitchTableCell.h"

#define PLACEMENT_OBJECT_COUNT 2

#define USE_TEXT_VIEW 0

const NSString *CallViewRowHeight = @"rowHeight";
const NSString *CallViewGroupText = @"group";
const NSString *CallViewType = @"type";
const NSString *CallViewRows = @"rows";
const NSString *CallViewSelectedInvocations = @"select";
const NSString *CallViewDeleteInvocations = @"delete";
const NSString *CallViewInsertDelete = @"insertdelete";
const NSString *CallViewIndentWhenEditing = @"indentWhenEditing";

/* TODOS:
. make the delete button at the end of the editing screen work
. fix the "add new call" "done" display of cell entries
. fix the notes section to be a multiline text view when displaying and when editing
. get screen rotation working
. make editing/done with editing transition
. hot at home screen?
. Time view
    . return visits, publications, time? this month and last month


*/



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
@synthesize currentFirstResponder;
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
		currentFirstResponder = nil;
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

		_name = [[UITableViewTextFieldCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil];
		_name.indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		_name.delegate = self;
		_name.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
		_name.textField.returnKeyType = UIReturnKeyDone;
        // _name (make sure that it is initalized)
        //[_name setText:NSLocalizedString(@"Name", @"Name label for Call in editing mode")];
		_name.textField.placeholder = NSLocalizedString(@"Name", @"Name label for Call in editing mode");
        if((temp = [_call objectForKey:CallName]) != nil)
		{
            _name.textField.text = temp;
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

		// phone numbers
        if([_call objectForKey:CallPhoneNumbers] == nil)
        {
            [_call setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallPhoneNumbers];
        }
        else
        {
           // lets check all of the ReturnVisits to make sure that everything was 
            // initialized correctly
            NSMutableArray *numbers = [_call objectForKey:CallPhoneNumbers];
            NSMutableDictionary *entry;
			
            int i;
            int end = [numbers count];
            for(i = 0; i < end; ++i)
            {
                entry = [numbers objectAtIndex:i];
                if([entry objectForKey:CallPhoneNumberType] == nil)
                    [entry setObject:@"home" forKey:CallPhoneNumberType];
                
                if([entry objectForKey:CallPhoneNumber] == nil)
                    [entry setObject:@"" forKey:CallReturnVisitNotes];
			}
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
	
	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	// hide the back button so that they cant cancel the edit without hitting done
	self.navigationItem.hidesBackButton = YES;

#if 1
	[self reloadData];
	[theTableView reloadData];
	if(theTableView.editing != _editing)
		theTableView.editing = _editing;		
#else
	NSMutableArray *cachedItems = [[_displayInformation retain] autorelease];
	[self reloadData];

	NSEnumerator *oldDisplayInformation = [cachedItems objectEnumerator];
	NSMutableDictionary *items;
	[theTableView beginUpdates];
	int section = 0;
	int row = 0;
	NSEnumerator *newDisplayInformation = [_displayInformation objectEnumerator];
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
	[theTableView insertSections:insertSections withRowAnimation:UITableViewRowAnimationFade];
	[theTableView insertRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationFade];

	if(theTableView.editing != _editing)
		theTableView.editing = _editing;		
	[theTableView endUpdates];
	[theTableView reloadData];
#endif	
}

- (void)tableViewTextFieldCell:(UITableViewTextFieldCell *)cell selected:(BOOL)selected;
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	if(selected)
	{
		if(cell.tableView && cell.indexPath)
		{
			[cell.tableView selectRowAtIndexPath:cell.indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
		}
		self.currentFirstResponder = cell.textField;
	}
	else
	{
		if(self.currentFirstResponder)
		{
			[self.currentFirstResponder resignFirstResponder];
		}
		self.currentFirstResponder = nil;
		if(cell.tableView && cell.indexPath)
		{
			[cell.tableView deselectRowAtIndexPath:cell.indexPath animated:YES];
		}
	}
}
- (void)scrollToSelected:(id)unused
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	[theTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	// force the tableview to load
	[self reloadData];
	[theTableView reloadData];
	[super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
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


	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	if(currentFirstResponder)
	{
		[currentFirstResponder resignFirstResponder];
		self.currentFirstResponder = nil;
	}
}

- (void)loadView 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	UIView *contentView = [[[UIView alloc] initWithFrame:rect] autorelease];
	contentView.backgroundColor = [UIColor blackColor];
	contentView.autoresizesSubviews = YES;
	self.view = contentView;

	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	UITableView *tableView = [[[UITableView alloc] initWithFrame:self.view.bounds 
														  style:UITableViewStyleGrouped] autorelease];

	_name.tableView = tableView;
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
		NSString *street = [_call objectForKey:CallStreet];
		NSString *city = [_call objectForKey:CallCity];
		NSString *state = [_call objectForKey:CallState];
		
		// if they have not initialized the address then assume that it is
		// the same as the last one
		if((streetNumber == nil || [streetNumber isEqualToString:@""]) &&
		   (street == nil || [street isEqualToString:@""]) &&
		   (city == nil || [city isEqualToString:@""]) &&
		   (state == nil || [state isEqualToString:@""]))
		{
			NSMutableDictionary *settings = [[Settings sharedInstance] settings];
			streetNumber = @"";
			street = [settings objectForKey:SettingsLastCallStreet];
			city = [settings objectForKey:SettingsLastCallCity];
			state = [settings objectForKey:SettingsLastCallState];
		}
		// open up the edit address view 
		AddressViewController *viewController = [[[AddressViewController alloc] initWithStreetNumber:streetNumber
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
		NSString *street = [_call objectForKey:CallStreet];
		NSString *city = [_call objectForKey:CallCity];
		NSString *state = [_call objectForKey:CallState];
		
		// if they have not initialized the address then dont show the map program
		if(!((streetNumber == nil || [streetNumber isEqualToString:@""]) &&
			 (street == nil || [street isEqualToString:@""]) &&
			 (city == nil || [city isEqualToString:@""]) &&
			 (state == nil || [state isEqualToString:@""])))
		{
			// pop up a alert sheet to display buttons to show in google maps?
			//http://maps.google.com/?hl=en&q=kansas+city
			NSString *streetNumber = [_call objectForKey:CallStreetNumber];
			NSString *street = [_call objectForKey:CallStreet];
			NSString *city = [_call objectForKey:CallCity];
			NSString *state = [_call objectForKey:CallState];

			// make sure that we have default values for each of the address parts
			if(streetNumber == nil)
				streetNumber = @"";
			if(street == nil)
				street = @"";
			if(city == nil)
				city = @"";
			if(state == nil)
				state = @"";

#if 1		
			// open up a url
			NSURL *url = [NSURL URLWithString:[NSString 
										 stringWithFormat:@"http://maps.google.com/?lh=%@&q=%@+%@+%@,+%@", 
										                  NSLocalizedString(@"en", @"Google Localized Language Name"),
														  [streetNumber stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
														  [street stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
														  [city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
														  [state stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
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
	_editingReturnVisit = [[_call objectForKey:CallReturnVisits] objectAtIndex:index];
	NSString *type = [_editingReturnVisit objectForKey:CallReturnVisitType];
	if(type == nil)
		type = (NSString *)CallReturnVisitTypeReturnVisit;
		
	// make the new call view 
	ReturnVisitTypeViewController *p = [[[ReturnVisitTypeViewController alloc] initWithType:type] autorelease];

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
			 rowHeight:(int)rowHeight
     insertOrDelete:(UITableViewCellEditingStyle)insertOrDelete
  indentWhenEditing:(BOOL)indentWhenEditing 
   selectInvocation:(NSInvocation *)selectInvocation 
   deleteInvocation:(NSInvocation *)deleteInvocation
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	NSInvocation *dummyInvocation = [self invocationForSelector:@selector(dummyFunction)];

	[[_currentGroup objectForKey:CallViewRows] addObject:cellInvocation];
	[[_currentGroup objectForKey:CallViewSelectedInvocations] addObject:(selectInvocation ? selectInvocation : dummyInvocation)];
	[[_currentGroup objectForKey:CallViewDeleteInvocations] addObject:(deleteInvocation ? deleteInvocation : dummyInvocation)];
	[[_currentGroup objectForKey:CallViewInsertDelete] addObject:[NSNumber numberWithInt:insertOrDelete]];
	[[_currentGroup objectForKey:CallViewIndentWhenEditing] addObject:[NSNumber numberWithBool:indentWhenEditing]];
	[[_currentGroup objectForKey:CallViewRowHeight] addObject:[NSNumber numberWithInt:rowHeight]];
}

#pragma mark Cell Getters

- (UITableViewCell *)getNameCell
{
	if(_editing)
	{
		if(_setFirstResponderGroup == 0)
		{
			[self performSelector: @selector(selectRow:) 
					   withObject:[[NSIndexPath indexPathForRow:0 inSection:0] retain]];

			_setFirstResponderGroup = -1;
		}

		return(_name);
	}
	else
	{
		UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[theTableView dequeueReusableCellWithIdentifier:@"NameCell"];
		if(cell == nil)
		{
			cell = [[[UITableViewTitleAndValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"NameCell"] autorelease];
		}
		// if we are not editing, then just display the name
		[cell setTitle:[_call objectForKey:CallName]];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return(cell);
	}
}

- (UITableViewCell *)getAddressCell
{
	AddressTableCell *cell = (AddressTableCell *)[theTableView dequeueReusableCellWithIdentifier:@"AddressCell"];
	if(cell == nil)
	{
		cell = [[[AddressTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"AddressCell"] autorelease];
	}
	[cell setStreetNumber:[_call objectForKey:CallStreetNumber] 
	               street:[_call objectForKey:CallStreet] 
				     city:[_call objectForKey:CallCity] 
					state:[_call objectForKey:CallState]];

	return(cell);
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

	NSString *type = [[[_call objectForKey:CallReturnVisits] objectAtIndex:returnVisitIndex] objectForKey:CallReturnVisitType];
	if(type == nil)
		type = (NSString *)CallReturnVisitTypeReturnVisit;


	[cell setTitle:NSLocalizedString(@"Type", @"Return visit type label")];
	[cell setValue:[[NSBundle mainBundle] localizedStringForKey:type value:type table:@""]];

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
	[cell setTitle:NSLocalizedString(@"Delete Call", @"Delete Call button in editing mode of call view")];
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.backgroundColor = [UIColor redColor];
	cell.titleLabel.textColor = [UIColor redColor];
	cell.titleLabel.textAlignment  = UITextAlignmentCenter;
	cell.titleLabel.backgroundColor = [UIColor clearColor];
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
				 rowHeight:50
			insertOrDelete:UITableViewCellEditingStyleNone
		 indentWhenEditing:NO
		  selectInvocation:nil
		  deleteInvocation:nil];
	}
	
DEBUG(NSLog(@"CallView %s:%d", __FILE__, __LINE__);)
	
	// Address
	{
		NSString *streetNumber = [_call objectForKey:CallStreetNumber];
		NSString *street = [_call objectForKey:CallStreet];
		NSString *city = [_call objectForKey:CallCity];
		NSString *state = [_call objectForKey:CallState];

		NSMutableString *top = [[[NSMutableString alloc] init] autorelease];
		[top setString:@""];
		NSMutableString *bottom = [[[NSMutableString alloc] init] autorelease];
		[bottom setString:@""];
		BOOL found = NO;
		if(streetNumber && [streetNumber length] && street && [street length])
		{
			[top appendFormat:NSLocalizedString(@"%@ %@", @"House number and Street represented by %1$@ as the house number and %2$@ as the street name"), streetNumber, street];
			found = YES;
		}
		else if(streetNumber && [streetNumber length])
		{
			[top appendFormat:@"%@", streetNumber];
			found = YES;
		}
		else if(street && [street length])
		{
			[top appendFormat:@"%@", street];
			found = YES;
		}
		if(city != nil && [city length])
		{
			[bottom appendFormat:@"%@", city];
			found = YES;
		}
		if(state != nil && [state length])
		{
			[bottom appendFormat:@", %@", state];
			found = YES;
		}
		VERY_VERBOSE(NSLog(@"address:\n%@\n%@", top, bottom);)

		// if there was no street information then just dont display
		// the address (unless we are editing
		if(found || _editing)
		{
			// add a group for the name
			[self addGroup:nil type:@"Address"];
			
			[self  addRowInvocation:[self invocationForSelector:@selector(getAddressCell)]
					 rowHeight:70
				insertOrDelete:UITableViewCellEditingStyleNone
			 indentWhenEditing:NO
			  selectInvocation:[self invocationForSelector:@selector(addressSelected)]
			  deleteInvocation:nil];
		}
		
		//  make it where they can hit hext and go into the address view to setup the address
		_name.nextKeyboardResponder = [[[SelectAddressView alloc] initWithTable:theTableView indexPath:[self lastIndexPath]] autorelease];
	}

DEBUG(NSLog(@"CallView %s:%d", __FILE__, __LINE__);)

	// Add new Call
	if(_showAddCall && _editing)
	{
		// we need a larger row height
		[self addGroup:nil type:@"AddCall"];

		[self  addRowInvocation:[self invocationForSelector:@selector(getAddReturnVisitCell)]
				 rowHeight:-1
			insertOrDelete:UITableViewCellEditingStyleInsert
		 indentWhenEditing:YES
		  selectInvocation:[self invocationForSelector:@selector(addReturnVisitSelected)]
		  deleteInvocation:nil];
	}
DEBUG(NSLog(@"CallView %s:%d", __FILE__, __LINE__);)

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
			[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
			NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
//			[dateFormatter setDateFormat:NSLocalizedString(@"%a %b %d, %Y", @"Calendar format where %a is an abbreviated weekday %b is an abbreviated month %d is the day of the month as a decimal number and %Y is the current year")];
			[dateFormatter setDateStyle:NSDateFormatterFullStyle];
			[dateFormatter setTimeStyle:NSDateFormatterShortStyle];			 
			NSString *formattedDateString = [NSString stringWithString:[dateFormatter stringFromDate:date]];			
			[self addGroup:formattedDateString type:@"Visit"];


DEBUG(NSLog(@"CallView %s:%d", __FILE__, __LINE__);)
			// NOTES
			if(_editing)
			{
				[self  addRowInvocation:[self invocationForSelector:@selector(getNotesCellForReturnVisitIndex:) withArgument:(void *)i]
						 rowHeight:[UITableViewMultilineTextCell heightForWidth:250 withText:[[returnVisits objectAtIndex:i] objectForKey:CallReturnVisitNotes]]
					insertOrDelete:(end == 1 ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete)
				 indentWhenEditing:YES
				  selectInvocation:[self invocationForSelector:@selector(changeNotesForReturnVisitAtIndex:) withArgument:(void *)i]
				  deleteInvocation:[self invocationForSelector:@selector(deleteReturnVisitAtIndex:) withArgument:(void *)i]];
			}
			else
			{
				[self  addRowInvocation:[self invocationForSelector:@selector(getNotesCellForReturnVisitIndex:) withArgument:(void *)i]
						 rowHeight:[UITableViewMultilineTextCell heightForWidth:250 withText:[[returnVisits objectAtIndex:i] objectForKey:CallReturnVisitNotes]]
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
						 rowHeight:-1
					insertOrDelete:UITableViewCellEditingStyleNone
           		 indentWhenEditing:YES
				  selectInvocation:[self invocationForSelector:@selector(changeDateOfReturnVisitAtIndex:) withArgument:(void *)i]
				  deleteInvocation:nil];
			}
 
			// STUDY (only show if you are editing or this is a study)
			NSString *type = [visit objectForKey:CallReturnVisitType];
			if(type == nil)
				type = (NSString *)CallReturnVisitTypeReturnVisit;
				
			if(_editing || ![type isEqualToString:(NSString *)CallReturnVisitTypeReturnVisit])
			{
				[self  addRowInvocation:[self invocationForSelector:@selector(getTypeCellForReturnVisitIndex:) withArgument:(void *)i]
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
								 rowHeight:-1
							insertOrDelete:UITableViewCellEditingStyleDelete
						indentWhenEditing:YES
						  selectInvocation:[self invocationForSelector:@selector(changeReturnVisitAtIndex:publicationAtIndex:) withArgument:(void *)i andArgument:(void *)j]
						  deleteInvocation:[self invocationForSelector:@selector(deleteReturnVisitAtIndex:publicationAtIndex:) withArgument:(void *)i andArgument:(void *)j]];
					}
					else
					{
						[self  addRowInvocation:[self invocationForSelector:@selector(getPublicationCellForReturnVisitIndex:publicationIndex:) withArgument:(void *)i andArgument:(void *)j]
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
	[_call setObject:(addressViewController.street ? addressViewController.street : @"") forKey:CallStreet];
	[_call setObject:(addressViewController.city ? addressViewController.city : @"") forKey:CallCity];
	[_call setObject:(addressViewController.state ? addressViewController.state : @"") forKey:CallState];
	// remove the gps location so that they will look it up again
	[_call removeObjectForKey:CallLattitudeLongitude];

	[self reloadData];
	[self save];
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
 *   DELETE ACTION SHEET DELEGATE FUNCTIONS
 *
 ******************************************************************/
#pragma mark Delete ActionSheet Delegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{
	VERBOSE(NSLog(@"alertSheet: button:%d", button);)
//	[sheet dismissAnimated:YES];

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
    VERBOSE(NSLog(@"tableView: heightForRowAtIndexPath: row=%d section=%d", row, section);)
	if (row == -1) 
	{
		if([[_displayInformation objectAtIndex:section] objectForKey:CallViewGroupText] != nil)
		{
			return 40;
		}
	}
	else
	{
		float height;
#if 0
		if([[[[_displayInformation objectAtIndex:section] objectForKey:CallViewRows] objectAtIndex:row] respondsToSelector:@selector(height)])
		{
			height = [[[[_displayInformation objectAtIndex:section] objectForKey:CallViewRows] objectAtIndex:row] height];
		}
		else
#endif
		{
			height = [[[[_displayInformation objectAtIndex:section] objectForKey:CallViewRowHeight] objectAtIndex:row] floatValue];
		}
		VERBOSE(NSLog(@"tableView: heightForRowAtIndexPath: row=%d section=%d height=%f", row, section, height);)
		if(height >= 0.0)
			return(height);
	}
	return theTableView.rowHeight;
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
    if(_name.textField.text == nil)
        return(@"");
    else
        return(_name.textField.text);
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


