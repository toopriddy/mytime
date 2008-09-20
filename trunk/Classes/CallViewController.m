//
//  CallViewController.m
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CallViewController.h"
#import "Settings.h"
#import "UITableViewTitleAndValueCell.h"
#import "AddressViewController.h"
#import "PublicationViewController.h"
#import "WebViewController.h"
#import "DatePickerViewController.h"

#define PLACEMENT_OBJECT_COUNT 2

#define USE_TEXT_VIEW 0

const NSString *CallViewRowHeight = @"rowHeight";
const NSString *CallViewGroupText = @"group";
const NSString *CallViewRows = @"rows";
const NSString *CallViewSelectedInvocations = @"select";
const NSString *CallViewDeleteInvocations = @"delete";
const NSString *CallViewInsertDelete = @"insertdelete";


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
#define AlternateLocalizedString(a, b) (a)


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

- (id)initWithTable:(UITableView *)theTableView indexPath:(NSIndexPath *)theIndexPath
{
	[super init];
	self.tableView = theTableView;
	self.indexPath = theIndexPath;
	return(self);
}

- (BOOL)becomeFirstResponder 
{
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

/******************************************************************
 *
 *   INIT
 *
 ******************************************************************/

- (id) init
{
    DEBUG(NSLog(@"CallView 1initWithFrame: %p", self);)
    return([self initWithCall:nil]);
}

- (id) initWithCall:(NSMutableDictionary *)call
{
    if([super init]) 
    {
		theTableView = nil;
		_initialView = YES;
		delegate = nil;
		currentFirstResponder = nil;
		
		self.hidesBottomBarWhenPushed = YES;
		
        NSString *temp;
        DEBUG(NSLog(@"CallView 2initWithFrame:call:%@", call);)

		_setFirstResponderGroup = -1;
		
		_displayInformation = nil;
		_lastDisplayInformation = nil;

		_newCall = (call == nil);
		_editing = _newCall;
		_showDeleteButton = !_newCall;
		if(_newCall)
		{
			_call = [[NSMutableDictionary alloc] init];
			_setFirstResponderGroup = 0;
		}
		else
		{
			_call = [[NSMutableDictionary alloc] initWithDictionary:call copyItems:YES];
		}
		_showAddCall = YES;

        _name = [[UITableViewTextFieldCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"NameCellForCall"];
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
		
		_returnVisitNotes = [[NSMutableArray alloc] init];
        

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
        
        [self reloadData];
    }
    
    return(self);
}

- (void)dealloc 
{
    DEBUG(NSLog(@"%s: dealloc", __FILE__);)
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
	return(YES);
}

- (void)save
{
	DEBUG(NSLog(@"save");)

	[_call setObject:[self name] forKey:CallName];
	
	// save the notes
	[self saveReturnVisitsNotes];
	
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
	NSLog(@"navigationControlDone:");
	// go through the notes and make them resign the first responder
	[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
	[_name resignFirstResponder];

	int count = [_returnVisitNotes count];
	int i;
	for(i = 0; i < count; ++i)
	{
		// get the notes cell
		UITableViewTextFieldCell *text = [_returnVisitNotes objectAtIndex:i];
		[text.textField resignFirstResponder];
	}

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
		[self reloadData];
	}
}

- (void)navigationControlCancel:(id)sender 
{
	[_call release];
	_call = nil;
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)navigationControlEdit:(id)sender 
{
	NSLog(@"navigationControlEdit:");
	_editing = YES;
	_showDeleteButton = YES;
	_showAddCall = YES;

	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	// hide the back button so that they cant cancel the edit without hitting done
	self.navigationItem.hidesBackButton = YES;

	// we need to reload data now, so we need to show:
	//   the name field if it is not there already
	//   the insert new call
	//   the per call insert a new publication
	[self reloadData];
}

- (void)tableViewTextFieldCell:(UITableViewTextFieldCell *)cell selected:(BOOL)selected;
{
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
	[theTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
//	NSLog(@"keyboardWillShow");
	// only modify if this view controller is on top
	if(self.navigationController.topViewController == self)
	{
		[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.3];
			
			CGRect rect = self.view.frame;
			if(self.interfaceOrientation == UIInterfaceOrientationPortrait ||
			   self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
			{
				rect.size.height -= 215;
			}
			else
			{
				rect.size.height -= 160;
			}
			self.view.frame = rect;
		[UIView commitAnimations];
	}
	// when in landscape mode make sure that the text box shows up on the screen
	[self performSelector: @selector(scrollToSelected:) 
			   withObject:nil
			   afterDelay:.4];
}
 
-(void)keyboardWillHide:(NSNotification *)notif
{
//	NSLog(@"keyboardWillHide");
	// only modify if this view controller is on top
	if(self.navigationController.topViewController == self)
	{
//		[UIView beginAnimations:nil context:NULL];
//			[UIView setAnimationDuration:0.3];
			
			CGRect rect = theTableView.frame;
			if(self.interfaceOrientation == UIInterfaceOrientationPortrait ||
			   self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
			{
				rect.size.height += 215;
			}
			else
			{
				rect.size.height += 160;
			}
			self.view.frame = rect;
//		[UIView commitAnimations];
	}
}

-(void)viewWillAppear:(BOOL)animated
{
	// force the tableview to load
	[self reloadData];
	
	[super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated 
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];

	if(!_initialView)
	{
		[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
	}
	_initialView = NO;

	DEBUG(NSLog(@"%s: viewDidAppear", __FILE__);)
	
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if(currentFirstResponder)
	{
		[currentFirstResponder resignFirstResponder];
		self.currentFirstResponder = nil;
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:self.view.window];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:self.view.window];
}

- (void)loadView 
{
	CGRect rect = [[UIScreen mainScreen] applicationFrame];
	UIView *contentView = [[[UIView alloc] initWithFrame:rect] autorelease];
	contentView.backgroundColor = [UIColor blackColor];
	contentView.autoresizesSubviews = YES;
	self.view = contentView;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];


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

	[self reloadData];

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




// UITableViewDataSource methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  
{
    VERBOSE(NSLog(@"numberOfSectionsInTableView:");)
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
    return(title);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
	int section = [indexPath section];
    VERBOSE(NSLog(@"tableView: cellForRow:%d inSection:%d", row, section);)
	return([[[_displayInformation objectAtIndex:section] objectForKey:CallViewRows] objectAtIndex:row]);
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
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:selector]];
	[invocation setTarget:self];
	[invocation setSelector:selector];
	
	return(invocation);
}

- (NSInvocation *)invocationForSelector:(SEL)selector withArgument:(void *)argument
{
	NSInvocation *invocation = [self invocationForSelector:selector];
	[invocation setArgument:&argument atIndex:2];
	
	return(invocation);
}

- (NSInvocation *)invocationForSelector:(SEL)selector withArgument:(void *)argument andArgument:(void *)anotherArgument
{
	NSInvocation *invocation = [self invocationForSelector:selector withArgument:argument];
	[invocation setArgument:&anotherArgument atIndex:3];
	
	return(invocation);
}



/******************************************************************
 *
 *   Callback functions
 *   
 ******************************************************************/
- (void)dummyFunction
{
}

- (void)unselectRow
{
	DEBUG(NSLog(@"unselectRow");)
	// unselect the row
// TODO:
//	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
}

- (void)deleteReturnVisitAtIndex:(NSNumber *)index
{
	DEBUG(NSLog(@"deleteReturnVisitAtIndex: %@", index);)
	int i = [index intValue];
	[index release];

	// make sure that the keyboard is not focused on this textfield
	UITableViewTextFieldCell *text = [_returnVisitNotes objectAtIndex:i];
	[text.textField resignFirstResponder];


	NSMutableArray *returnVisits = [_call objectForKey:CallReturnVisits];
	NSMutableArray *array = [[[NSMutableArray alloc] initWithArray:returnVisits] autorelease];
	[_call setObject:array forKey:CallReturnVisits];
	DEBUG(NSLog(@"got %@", array);)
	returnVisits = array;
	// if they click on the notes, then it is like they are deleting
	// the whole return visit
	DEBUG(NSLog(@"trying to remove row %d", i);)
	[returnVisits removeObjectAtIndex:[index intValue]];
	DEBUG(NSLog(@"got %@", returnVisits);)

	// save the data
	[self save];

	// animate the removal of the next rows (change date publications and insert publication cells)
//	[_table deleteRows:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(_selectedRow-1, num+1)] viaEdge:1];
	[self reloadData];
}

- (void)deleteReturnVisitAtIndex:(NSNumber *)index publicationAtIndex:(NSNumber *)publicationIndex
{
	DEBUG(NSLog(@"deleteReturnVisitAtIndex: %@ publicationAtIndex:%@", index, publicationIndex);)
	// this is the entry that we need to delete
	[[[[_call objectForKey:CallReturnVisits] objectAtIndex:[index intValue]] 
	                                                  objectForKey:CallReturnVisitPublications] 
													      removeObjectAtIndex:[publicationIndex intValue]];

	[index release];
	// save the data
	[self save];
	
	[self reloadData];
}

- (void)addressSelected
{
	DEBUG(NSLog(@"addressSelected");)
	if(_editing)
	{
		// save off the notes before we delete this return visit
		[self saveReturnVisitsNotes];
		
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
														  [streetNumber stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], 
														  [street stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], 
														  [city stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], 
														  [state stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
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
	// save off the notes before we create the other return visit
	[self saveReturnVisitsNotes];
	
	NSMutableArray *returnVisits = [[[NSMutableArray alloc] initWithArray:[_call objectForKey:CallReturnVisits]] autorelease];
	[_call setObject:returnVisits forKey:CallReturnVisits];
	
	NSMutableDictionary *visit = [[[NSMutableDictionary alloc] init] autorelease];

	[visit setObject:[NSDate date] forKey:CallReturnVisitDate];
	[visit setObject:@"" forKey:CallReturnVisitNotes];
	[visit setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallReturnVisitPublications];
	
	[returnVisits insertObject:visit atIndex:0];

	[theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[theTableView indexPathForSelectedRow]] 
	                    withRowAnimation:UITableViewRowAnimationLeft];
	[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];

	_setFirstResponderGroup = 2;

	// unselect this row 
	[self reloadData];
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

- (void)changeDateOfReturnVisitAtIndex:(NSNumber *)index
{
	DEBUG(NSLog(@"changeDateOfReturnVisitAtIndex: %@", index);)

	// they clicked on the Change Date
	_editingReturnVisit = [[_call objectForKey:CallReturnVisits] objectAtIndex:[index intValue]];
	[index release];
	
	// make the new call view 
	DatePickerViewController *p = [[[DatePickerViewController alloc] initWithDate:[_editingReturnVisit objectForKey:CallReturnVisitDate]] autorelease];

	p.delegate = self;

	[[self navigationController] pushViewController:p animated:YES];		
}

- (void)addPublicationToReturnVisitAtIndex:(NSNumber *)index
{
	DEBUG(NSLog(@"addPublicationToReturnVisitAtIndex: %p", index);)

	// save off the notes before we move to another view
	[self saveReturnVisitsNotes];
	
	//this is the add a new entry one
	_editingReturnVisit = [[_call objectForKey:CallReturnVisits] objectAtIndex:[index intValue]];
	[index release];
	
	_editingPublication = nil; // we are making a new one
	
	// make the new call view 
	PublicationViewController *p = [[[PublicationViewController alloc] init] autorelease];
	p.delegate = self;

	[[self navigationController] pushViewController:p animated:YES];		
}

- (void)changeReturnVisitAtIndex:(NSNumber *)index publicationAtIndex:(NSNumber *)publicationIndex
{
	DEBUG(NSLog(@"changeReturnVisitAtIndex: %@ publicationAtIndex:%@", index, publicationIndex);)

	// save off the notes before we move to another view
	[self saveReturnVisitsNotes];
	
	// they selected an existing entry
	_editingReturnVisit = [[_call objectForKey:CallReturnVisits] objectAtIndex:[index intValue]];
	_editingPublication = [[_editingReturnVisit objectForKey:CallReturnVisitPublications] objectAtIndex:[publicationIndex intValue]];
	[index release];
	[publicationIndex release];
	
	// make the new call view 
	PublicationViewController *p = [[[PublicationViewController alloc] initWithPublication: [ _editingPublication objectForKey:CallReturnVisitPublicationName]
																					  year: [[_editingPublication objectForKey:CallReturnVisitPublicationYear] intValue]
																				     month: [[_editingPublication objectForKey:CallReturnVisitPublicationMonth] intValue]
																					   day: [[_editingPublication objectForKey:CallReturnVisitPublicationDay] intValue]] autorelease];

	p.delegate = self;
	[[self navigationController] pushViewController:p animated:YES];

}




- (NSIndexPath *)lastIndexPath
{
	return([NSIndexPath indexPathForRow:([[_currentGroup objectForKey:CallViewRows] count] - 1) inSection:([_displayInformation count] - 1)]);
}

- (void)addGroup:(NSString *)groupCell
{
	DEBUG(NSLog(@"addGroup: ");)
	_currentGroup = [[[NSMutableDictionary alloc] init] autorelease];
	
	// initialize the arrays
	[_currentGroup setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallViewRows];
	[_currentGroup setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallViewSelectedInvocations];
	[_currentGroup setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallViewDeleteInvocations];
	[_currentGroup setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallViewInsertDelete];
	[_currentGroup setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallViewRowHeight];

	// set the group's settings
	if(groupCell != nil)
		[_currentGroup setObject:groupCell forKey:CallViewGroupText];

	[_displayInformation addObject:_currentGroup];
	DEBUG(NSLog(@"_displayInformation count = %d", [_displayInformation count]);)
}

- (void)     addRow:(id)cell 
			 rowHeight:(int)rowHeight
     insertOrDelete:(UITableViewCellEditingStyle)insertOrDelete 
   selectInvocation:(NSInvocation *)selectInvocation 
   deleteInvocation:(NSInvocation *)deleteInvocation
{
	NSInvocation *dummyInvocation = [self invocationForSelector:@selector(dummyFunction)];
//	NSInvocation *unselectInvocation = [self invocationForSelector:@selector(unselectRow)];

	[[_currentGroup objectForKey:CallViewRows] addObject:cell];
	[[_currentGroup objectForKey:CallViewSelectedInvocations] addObject:(selectInvocation ? selectInvocation : dummyInvocation)];
	[[_currentGroup objectForKey:CallViewDeleteInvocations] addObject:(deleteInvocation ? deleteInvocation : dummyInvocation)];
	[[_currentGroup objectForKey:CallViewInsertDelete] addObject:[NSNumber numberWithInt:insertOrDelete]];
	[[_currentGroup objectForKey:CallViewRowHeight] addObject:[NSNumber numberWithInt:rowHeight]];
}

- (void)reloadData
{
	DEBUG(NSLog(@"CallView reloadData");)

	// get rid of the last display information, we double buffer this to get around a douple reloadData call
	[_lastDisplayInformation release];
	
	// lets store the information till later so that if the iPhone is still using some of this data
	// in current displays, it does not disappear while still using it.  This is kind of a kludge but
	// I do not know of a way to find and fix this problem (I spent hours in the simulator trying to find the memory issue)
	_lastDisplayInformation = _displayInformation;
	_displayInformation = [[NSMutableArray alloc] init];
	
	// Name
	if(_editing || [[_call objectForKey:CallName] length])
	{
		[self addGroup:nil];

		if(_editing)
		{
			// 0 regular
			// 1 numbers
			// 2 telephone
			// 3 web
			// 4 normal with a numberpad as the numbers
			// 5 seethrough black keyboard normal
			// 6 telephone without +
			// 7 seethrough black telephone without +
			// 8 email address keyboard with space @ . and _ - +
			// 9 email address keyboard with @ . .com
			//[[text textField] setPreferredKeyboardType: 0];
			// use the textfield
			[self       addRow:_name
					 rowHeight:50
			    insertOrDelete:UITableViewCellEditingStyleNone
			  selectInvocation:nil
			  deleteInvocation:nil];

 			if(_setFirstResponderGroup == 0)
			{
				
				[self performSelector: @selector(selectRow:) 
						   withObject:[[self lastIndexPath] retain]
						   afterDelay:.5];

				_setFirstResponderGroup = -1;
			}

		}
		else
		{
			// if we are not editing, then just display the name
			UITableViewTitleAndValueCell *cell = [[[UITableViewTitleAndValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
			[cell setTitle:[_call objectForKey:CallName]];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			[self       addRow:cell
					 rowHeight:50
			    insertOrDelete:UITableViewCellEditingStyleNone
			  selectInvocation:nil
			  deleteInvocation:nil];
		}
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
			UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
			[cell setText:NSLocalizedString(@"Address", @"Address label for call") ];
			cell.accessoryType = _editing ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;

			UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
			UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
			
			label.highlightedTextColor = cell.selectedTextColor;
			label.backgroundColor = [UIColor clearColor];
			[label setText:top];
			[label sizeToFit];
			CGRect lrect = [label bounds];
			lrect.origin.x += 100.0f;
			lrect.origin.y += 15.0f;
			[label setFrame: lrect];
			[view addSubview:label];

			label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
			label.highlightedTextColor = cell.selectedTextColor;
			label.backgroundColor = [UIColor clearColor];
			[label setText:bottom];
			[label sizeToFit];
			lrect = [label bounds];
			lrect.origin.x += 100.0f;
			lrect.origin.y += 35.0f;
			[label setFrame: lrect];
			[view addSubview:label];

			[cell.contentView addSubview:view];

			// add a group for the name
			[self addGroup:nil];
			
			// add the name to the group
			[self       addRow:cell
					 rowHeight:70
				insertOrDelete:UITableViewCellEditingStyleNone
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
		[self addGroup:nil];
		
		UITableViewTitleAndValueCell *cell = [[[UITableViewTitleAndValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		if([[_call objectForKey:CallReturnVisits] count])
		{
			[ cell setValue:NSLocalizedString(@"Add a return visit", @"Add a return visit action button")];
		}
		else
		{
			[ cell setValue:NSLocalizedString(@"Add a initial visit", @"Add a initial visit action buton")];
		}
		[self       addRow:cell
				 rowHeight:-1
			insertOrDelete:UITableViewCellEditingStyleInsert
		  selectInvocation:[self invocationForSelector:@selector(addReturnVisitSelected)]
		  deleteInvocation:nil];
	}

DEBUG(NSLog(@"CallView %s:%d", __FILE__, __LINE__);)

	// RETURN VISITS
	{
		NSMutableArray *returnVisits = [_call objectForKey:CallReturnVisits];
		NSMutableDictionary *visit;

		// release old return visits notes
		[_returnVisitNotes removeAllObjects];


		
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
#warning fix me
//			[dateFormatter setDateFormat:NSLocalizedString(@"%a %b %d, %Y", @"Calendar format where %a is an abbreviated weekday %b is an abbreviated month %d is the day of the month as a decimal number and %Y is the current year")];
			[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
			[dateFormatter setTimeStyle:NSDateFormatterNoStyle];			 
			NSString *formattedDateString = [dateFormatter stringFromDate:date];			
			[self addGroup:formattedDateString];

DEBUG(NSLog(@"CallView %s:%d", __FILE__, __LINE__);)
			// NOTES
			if(_editing)
			{
#if USE_TEXT_VIEW
				NotesTextView *cell = [[[NotesTextView alloc] initWithString:[[returnVisits objectAtIndex:i] objectForKey:CallReturnVisitNotes] editing:YES] autorelease];

				[_returnVisitNotes addObject:cell];
				NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!Height = %f", [cell height]);
				[cell sizeToFit];
				[cell setAutoresizingMask: kMainAreaResizeMask];
				[cell setAutoresizesSubviews: YES];
				
				[self       addRow:cell
						 rowHeight:[cell height]
					insertOrDelete:UITableViewCellEditingStyleDelete
				  selectInvocation:nil
				  deleteInvocation:[self invocationForSelector:@selector(deleteReturnVisitAtIndex:) withArgument:[[NSNumber alloc] initWithInt:i]]];
				
				if(_setFirstResponderGroup == 2 && i == 0)
				{
					[self performSelector:@selector(selectRow:) 
							   withObject:[[self lastIndexPath] retain]
							   afterDelay:.5];
					_setFirstResponderGroup = -1;
				}
#else
				UITableViewTextFieldCell *text = [[[UITableViewTextFieldCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
				text.textField.returnKeyType = UIReturnKeyDone;
				text.textField.placeholder = NSLocalizedString(@"Add Notes", @"Return Visit Notes Placeholder text");
				text.textField.text = [[returnVisits objectAtIndex:i] objectForKey:CallReturnVisitNotes];
				text.tableView = self.theTableView;
				text.delegate = self;
				[_returnVisitNotes addObject:text];

				[self       addRow:text
						 rowHeight:-1
					insertOrDelete:UITableViewCellEditingStyleDelete
				  selectInvocation:nil
				  deleteInvocation:[self invocationForSelector:@selector(deleteReturnVisitAtIndex:) withArgument:[[NSNumber alloc] initWithInt:i]]];
				// set the index path for selecting this row when the text box is selected
				text.indexPath = [self lastIndexPath];

				if(_setFirstResponderGroup == 2 && i == 0)
				{
					[self performSelector:@selector(selectRow:) 
							   withObject:[[self lastIndexPath] retain]
							   afterDelay:.5];
					_setFirstResponderGroup = -1;
				}
#endif
			}
			else
			{
#if USE_TEXT_VIEW
				NSString *string;
				NSMutableString *notes = [[returnVisits objectAtIndex:i] objectForKey:CallReturnVisitNotes];
				if([notes length] == 0)
					string = NSLocalizedString(@"Return Visit Notes", @"Return Visit Notes default text when the user did not enter notes, displayed on the view-mode Call view");
				else
					string = notes;
				NotesTextView *cell = [[[NotesTextView alloc] initWithString:string editing:NO] autorelease];
				
				[self       addRow:cell
						 rowHeight:-1
					insertOrDelete:UITableViewCellEditingStyleNone
				  selectInvocation:nil
				  deleteInvocation:nil];
#else
				UITableViewTitleAndValueCell *cell = [[[UITableViewTitleAndValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
				NSMutableString *notes = [[returnVisits objectAtIndex:i] objectForKey:CallReturnVisitNotes];
				if([notes length] == 0)
					[cell setValue:NSLocalizedString(@"Return Visit Notes", @"Return Visit Notes default text when the user did not enter notes, displayed on the view-mode Call view")];
				else
					[cell setValue:notes];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;


				[self       addRow:cell
						 rowHeight:-1
					insertOrDelete:UITableViewCellEditingStyleNone
				  selectInvocation:nil
				  deleteInvocation:nil];
#endif
			}

DEBUG(NSLog(@"CallView %s:%d", __FILE__, __LINE__);)
	
			// CHANGE DATE
			if(_editing)
			{
				UITableViewTitleAndValueCell *cell = [[[UITableViewTitleAndValueCell alloc] initWithFrame:CGRectZero reuseIdentifier:nil] autorelease];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				[cell setValue:NSLocalizedString(@"Change Date", @"Change Date action button for visit in call view")];
				
DEBUG(NSLog(@"CallView %s:%d", __FILE__, __LINE__);)
				[self       addRow:cell
						 rowHeight:-1
					insertOrDelete:UITableViewCellEditingStyleNone
				  selectInvocation:[self invocationForSelector:@selector(changeDateOfReturnVisitAtIndex:) withArgument:[[NSNumber alloc] initWithInt:i]]
				  deleteInvocation:nil];
			}

		
DEBUG(NSLog(@"CallView %s:%d", __FILE__, __LINE__);)
	
			// Publications
			if([visit objectForKey:CallReturnVisitPublications] != nil)
			{
				// they had an array of publications, lets check them too
				NSMutableArray *publications = [visit objectForKey:CallReturnVisitPublications];
				NSMutableDictionary *publication;
				int j;
				int endPublications = [publications count];
				for(j = 0; j < endPublications; ++j)
				{
					publication = [publications objectAtIndex:j];

DEBUG(NSLog(@"CallView %s:%d", __FILE__, __LINE__);)
					// PUBLICATION
					NSMutableDictionary *publication = [publications objectAtIndex:j];
					UITableViewTitleAndValueCell *cell = [[[UITableViewTitleAndValueCell alloc ] initWithFrame:CGRectZero ] autorelease];
					cell.accessoryType = _editing ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
					cell.selectionStyle = _editing ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
					[cell setTitle:[publication objectForKey:CallReturnVisitPublicationTitle]];

					if(_editing)
					{
DEBUG(NSLog(@"CallView %s:%d", __FILE__, __LINE__);)
						[self       addRow:cell
								 rowHeight:-1
							insertOrDelete:UITableViewCellEditingStyleDelete
						  selectInvocation:[self invocationForSelector:@selector(changeReturnVisitAtIndex:publicationAtIndex:) withArgument:[[NSNumber alloc] initWithInt:i] andArgument:[[NSNumber alloc] initWithInt:j]]
						  deleteInvocation:[self invocationForSelector:@selector(deleteReturnVisitAtIndex:publicationAtIndex:) withArgument:[[NSNumber alloc] initWithInt:i] andArgument:[[NSNumber alloc] initWithInt:j]]];
					}
					else
					{
DEBUG(NSLog(@"CallView %s:%d", __FILE__, __LINE__);)
						[self       addRow:cell
								 rowHeight:-1
							insertOrDelete:UITableViewCellEditingStyleNone
						  selectInvocation:nil
						  deleteInvocation:nil];
					}
				}
			}
			
	
			// add publication
			if(_editing)
			{
				UITableViewTitleAndValueCell *cell = [[[UITableViewTitleAndValueCell alloc] initWithFrame:CGRectZero] autorelease];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				[cell setValue:NSLocalizedString(@"Add a placed publication", @"Add a placed publication action button in call view")];

DEBUG(NSLog(@"CallView %s:%d", __FILE__, __LINE__);)
				[self       addRow:cell
						 rowHeight:-1
					insertOrDelete:UITableViewCellEditingStyleInsert
				  selectInvocation:[self invocationForSelector:@selector(addPublicationToReturnVisitAtIndex:) withArgument:[[NSNumber numberWithInt:i] retain]]
				  deleteInvocation:nil];
			}
		}
	}

	// DELETE call
	if(_editing && !_newCall)
	{
		[self addGroup:nil];

		// DELETE
		UITableViewTitleAndValueCell *cell = [[[UITableViewTitleAndValueCell alloc ] initWithFrame:CGRectMake(0, 0, 320, 45) ] autorelease];
		[cell setTitle:NSLocalizedString(@"Delete Call", @"Delete Call button in editing mode of call view")];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.backgroundColor = [UIColor redColor];
		cell.titleLabel.textColor = [UIColor redColor];
		cell.titleLabel.textAlignment  = UITextAlignmentCenter;
		cell.titleLabel.backgroundColor = [UIColor clearColor];
	
		[self       addRow:cell
				 rowHeight:-1
			insertOrDelete:UITableViewCellEditingStyleNone
		  selectInvocation:[self invocationForSelector:@selector(deleteCall)]
		  deleteInvocation:nil];
	}
	
	DEBUG(NSLog(@"CallView reloadData %s:%d", __FILE__, __LINE__);)

	if([_displayInformation count] == 0)
	{
		[self navigationControlEdit:nil];
		return;
	}

	[theTableView reloadData];

	theTableView.editing = _editing;		

	DEBUG(NSLog(@"CallView reloadData %s:%d", __FILE__, __LINE__);)
}


- (void)saveReturnVisitsNotes
{
	VERY_VERBOSE(NSLog(@"saveReturnVisitsNotes");)
	if(_editing)
	{
		NSMutableArray *returnVisits;
		// rebuild the return visit notes
		if([_call objectForKey:CallReturnVisits])
		{
			returnVisits = [[[NSMutableArray alloc] initWithArray:[_call objectForKey:CallReturnVisits]] autorelease];
		}
		else
		{
			returnVisits = [[[NSMutableArray alloc] init] autorelease];
		}
		int count = [returnVisits count];
		int i;
		for(i = 0; i < count; ++i)
		{
	#if USE_TEXT_VIEW
			// get the notes cell
			UITextView *text = [_returnVisitNotes objectAtIndex:i];
			// make a brandnew NSMutableDictionary because the old one might not be Mutable and copy
			// the contents of the original return visit
			NSMutableDictionary *visit = [[NSMutableDictionary alloc] initWithDictionary:[returnVisits objectAtIndex:i]];
			// replace the CallReturnVisitNotes object with the contents of the text cell
			[visit setObject:[text text] forKey:CallReturnVisitNotes];
			[returnVisits replaceObjectAtIndex:i withObject:visit];
	#else
			// get the notes cell
			UITableViewTextFieldCell *text = [_returnVisitNotes objectAtIndex:i];
			// make a brandnew NSMutableDictionary because the old one might not be Mutable and copy
			// the contents of the original return visit
			NSMutableDictionary *visit = [[NSMutableDictionary alloc] initWithDictionary:[returnVisits objectAtIndex:i]];
			// replace the CallReturnVisitNotes object with the contents of the text cell
			[visit setObject:text.textField.text forKey:CallReturnVisitNotes];
			[returnVisits replaceObjectAtIndex:i withObject:visit];
	#endif
		}
		[_call setObject:returnVisits forKey:CallReturnVisits];
	}
}

/******************************************************************
 *
 *   ADDRESS VIEW CALLBACKS
 *
 ******************************************************************/
- (void)addressViewControllerDone:(AddressViewController *)addressViewController
{
	[_call setObject:(addressViewController.streetNumber ? addressViewController.streetNumber : @"") forKey:CallStreetNumber];
	[_call setObject:(addressViewController.street ? addressViewController.street : @"") forKey:CallStreet];
	[_call setObject:(addressViewController.city ? addressViewController.city : @"") forKey:CallCity];
	[_call setObject:(addressViewController.state ? addressViewController.state : @"") forKey:CallState];

	[self save];
}

/******************************************************************
 *
 *   PUBLICATION VIEW CALLBACKS
 *
 ******************************************************************/
- (void)publicationViewControllerDone:(PublicationViewController *)publicationViewController
{
    if(_editingPublication == nil)
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

	// save the data
	[self save];
}



- (void)datePickerViewControllerDone:(DatePickerViewController *)datePickerViewController
{
    DEBUG(NSLog(@"CallView datePickerViewControllerDone:");)
    VERBOSE(NSLog(@"date is now = %@", [datePickerViewController date]);)

    [_editingReturnVisit setObject:[datePickerViewController date] forKey:CallReturnVisitDate];
    
	[self reloadData];

	// save the data
	[self save];
}


/******************************************************************
 *
 *   PREFERENCES TABLE DELEGATE FUNCTIONS
 *
 ******************************************************************/


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{
	NSLog(@"alertSheet: button:%d", button);
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

- (void)animateInsertRows: (NSNumber *)start
{
//	NSNumber *start = [timer userInfo];
	VERBOSE(NSLog(@"animateInsertRows for %d", [start intValue]);)
#if 0
	// reload the group title
	[the reloadCellAtRow: [start intValue] - 1 column:0 animated:YES];
	// reload the inserted rows
	[_table reloadDataForInsertionOfRows:NSMakeRange([start intValue], 3) animated:YES];
	[self reloadData];
	[start release];
#endif
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    DEBUG(NSLog(@"tableRowSelected: tableRowSelected section=%d row=%d editing%d", section, row, _editing);)

	_selectedRow = row;
	[[[[_displayInformation objectAtIndex:section] objectForKey:CallViewSelectedInvocations] objectAtIndex:row] invoke];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    DEBUG(NSLog(@"tableView: shouldIndentWhileEditingRowAtIndexPath section=%d row=%d editing%d", section, row, _editing);)
	UITableViewCellEditingStyle value = [[[[_displayInformation objectAtIndex:section] objectForKey:CallViewInsertDelete] objectAtIndex:row] intValue];
	if(value == UITableViewCellEditingStyleNone && row == 0)
	{
		return(NO);
	}
	return(YES);
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
    DEBUG(NSLog(@"tableView: editingStyleForRowAtIndexPath section=%d row=%d editing%d", section, row, _editing);)
	return [[[[_displayInformation objectAtIndex:section] objectForKey:CallViewInsertDelete] objectAtIndex:row] intValue];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    DEBUG(NSLog(@"tableView: editingStyleForRowAtIndexPath section=%d row=%d editing%d", section, row, _editing);)
	switch(editingStyle)
	{
		case UITableViewCellEditingStyleInsert:
			[tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
			[self tableView:tableView didSelectRowAtIndexPath:indexPath];
			break;
		case UITableViewCellEditingStyleDelete:
			[[[[_displayInformation objectAtIndex:section] objectForKey:CallViewDeleteInvocations] objectAtIndex:row] invoke];
			break;
	}
}

/******************************************************************
 *
 *   ACCESSOR METHODS
 *
 ******************************************************************/

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


