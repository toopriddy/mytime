//
//  MyTime
//
//  Created by Brent Priddy on 12/29/07.
//  Copyright 2007 PG Software. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UIThreePartButton.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UIPreferencesDeleteTableCell.h>
#import <UIKit/UIPickerView.h>
#import <UIKit/UITextFieldLabel.h>
#import "App.h"
#import "PublicationView.h"
#import "CallView.h"
#import "AddressView.h"
#import "MainView.h"
#import "DatePickerView.h"

#define PLACEMENT_OBJECT_COUNT 2

const NSString *CallViewRowHeight = @"rowHeight";
const NSString *CallViewGroupCell = @"group";
const NSString *CallViewRows = @"rows";
const NSString *CallViewSelectedInvocations = @"select";
const NSString *CallViewDeleteInvocations = @"delete";
const NSString *CallViewInsertDelete = @"insertdelete";
typedef enum {
	kNone,
	kCanInsert,
	kCanDelete
} CanInsertOrDelete;



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

@implementation CallView

- (void)save
{
	// save the notes
	[self saveReturnVisitsNotes];
	
	if(!_newCall && _saveObject != nil)
	{
		[_saveObject performSelector:_saveSelector withObject:self];
	}
}

- (void)setFocus:(UIPreferencesTextTableCell *)cell
{
	[cell becomeFirstResponder];
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
	[invocation setArgument:argument atIndex:2];
	
	return(invocation);
}

- (NSInvocation *)invocationForSelector:(SEL)selector withArgument:(void *)argument andArgument:(void *)anotherArgument
{
	NSInvocation *invocation = [self invocationForSelector:selector withArgument:argument];
	[invocation setArgument:anotherArgument atIndex:3];
	
	return(invocation);
}



/******************************************************************
 *
 *   NAVIGATION BAR
 *   1 left button                                0 right button
 ******************************************************************/
- (void)navigationBar:(UINavigationBar*)nav buttonClicked:(int)button
{
	if(_editing)
	{
		DEBUG(NSLog(@"navigationBar: buttonClicked:%s", button ? "???" : "done");)

		switch(button)
		{
			case 0: // done
				_editing = NO;
				_showAddCall = YES;
				_showDeleteButton = YES;
				
				// we dont save a new call untill they hit "Done"
				_newCall = NO;
				[self save];

				// remove the editing navigation bar entry
				[_navigationBar showLeftButton:@"All Calls" withStyle:2 rightButton:@"Edit" withStyle:0];
				
				// we need to reload data now, so we need to hide:
				//   the name field if it does not have a value
				//   the insert new call
				//   the per call insert a new publication
				[_table setKeyboardVisible:NO animated:NO];
				[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
				[_table reloadData];
				
				break;

			case 1: // cancel (this is only viewable if this is a new call)
				[_table setKeyboardVisible:NO animated:NO];
				[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
				if(_cancelObject != nil)
				{
					[_cancelObject performSelector:_cancelSelector withObject:self];
				}
				break;
		}
	}
	else
	{
		DEBUG(NSLog(@"navigationBar: buttonClicked:%s", button ? "All Calls" : "edit");)

		switch(button)		
		{
			case 1: // All Calls
				if(_cancelObject != nil)
				{
					[_cancelObject performSelector:_cancelSelector withObject:self];
				}
				break;

			case 0: // Edit
				_editing = YES;
				_showDeleteButton = YES;
				_showAddCall = YES;
				// 0 = greay
				// 1 = red
				// 2 = left arrow
				// 3 = blue
				[_navigationBar showLeftButton:nil withStyle:2 rightButton:@"Done" withStyle:3];

				// we need to reload data now, so we need to show:
				//   the name field if it is not there already
				//   the insert new call
				//   the per call insert a new publication
				[_table reloadData];
				break;
			
		}
	}
}

- (void)setCancelAction: (SEL)aSelector forObject:(NSObject *)obj
{
    _cancelObject = obj;
    _cancelSelector = aSelector;
}

- (void)setDeleteAction: (SEL)aSelector forObject:(NSObject *)obj
{
    _deleteObject = obj;
    _deleteSelector = aSelector;
}

- (void)setSaveAction: (SEL)aSelector forObject:(NSObject *)obj
{
    _saveObject = obj;
    _saveSelector = aSelector;
}

/******************************************************************
 *
 *   Callback functions
 *   
 ******************************************************************/
- (void)unselectRow
{
	// unselect the row
	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
}

- (void)deleteReturnVisitAtIndex:(NSNumber *)index
{
	int i = [index intValue];

	// save off the notes before we delete this return visit
	[self saveReturnVisitsNotes];

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
	// this is the entry that we need to delete
	[[[[_call objectForKey:CallReturnVisits] objectAtIndex:[index intValue]] 
	                                                  objectForKey:CallReturnVisitPublications] 
													      removeObjectAtIndex:[publicationIndex intValue]];
	// save the data
	[self save];
	
	[self reloadData];
}

- (void)addressSelected
{
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
			NSMutableDictionary *settings = [[App getInstance] getSavedData];
			streetNumber = @"";
			street = [settings objectForKey:SettingsLastCallStreet];
			city = [settings objectForKey:SettingsLastCallCity];
			state = [settings objectForKey:SettingsLastCallState];
		}
		// open up the edit address view 
		AddressView *p = [[[AddressView alloc] initWithFrame:_rect 
												streetNumber:streetNumber
													  street:street
														city:city
													   state:state] autorelease];
		[p setAutoresizingMask: kMainAreaResizeMask];
		[p setAutoresizesSubviews: YES];

		// setup the callbacks for save or cancel
		[p setCancelAction: @selector(editAddressCancelAction:) forObject:self];
		[p setSaveAction: @selector(editAddressSaveAction:) forObject:self];

		// transition from bottom up sliding ontop of the old view
		// first refcount us so that when we are not the main UIView
		// we dont get deleted prematurely
		[self retain];
		[[App getInstance] transition:1 fromView:self toView:p];
	
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

			// open up a url
			NSURL *url = [NSURL URLWithString:[NSString 
										 stringWithFormat:@"http://maps.google.com/?lh=en&q=%@+%@+%@,+%@", 
														  [streetNumber stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], 
														  [street stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], 
														  [city stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], 
														  [state stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
			DEBUG(NSLog(@"Trying to open url %@", url);)
			// open up the google map page for this call
			[[App getInstance] openURL:url];
		}
		else
		{
			// unselect the row
			[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
		}
	}
}

- (void)addReturnVisitSelected
{
	_showAddCall = NO;
	// save off the notes before we create the other return visit
	[self saveReturnVisitsNotes];
	
	NSMutableArray *returnVisits = [[[NSMutableArray alloc] initWithArray:[_call objectForKey:CallReturnVisits]] autorelease];
	[_call setObject:returnVisits forKey:CallReturnVisits];
	
	NSMutableDictionary *visit = [[[NSMutableDictionary alloc] init] autorelease];

	[visit setObject:[NSCalendarDate calendarDate] forKey:CallReturnVisitDate];
	[visit setObject:@"" forKey:CallReturnVisitNotes];
	[visit setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallReturnVisitPublications];
	
	[returnVisits insertObject:visit atIndex:0];

	// rebuild the notes before we make the table reloadData
	[self buildReturnVisitsNotes];
	
	// animate the two new rows
//		[_table reloadData];
//		[_table reloadDataForInsertionOfRows:NSMakeRange(_selectedRow, 2) animated:YES];
//		[_table deleteRows:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(_selectedRow, 1)] viaEdge:1 animated:YES];
	[_table animateDeletionOfCellAtRow:_selectedRow column:0 viaEdge:1];
	[self performSelector: @selector(animateInsertRows:) 
			   withObject:[[NSNumber alloc] initWithInt:_selectedRow] 
			   afterDelay:.5];
	_setFirstResponderGroup = 2;
	
	// unselect this row 
	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
}

- (void)deleteCall
{
	UIAlertSheet *alertSheet = [[UIAlertSheet alloc] initWithFrame:CGRectMake(0, 240, 320, 240)];
	[alertSheet setTitle:@"Delete Call?"];
	[alertSheet setBodyText:@"Are you sure you want to delete the call?"];
	[alertSheet addButtonWithTitle:@"Yes"];
	[alertSheet addButtonWithTitle:@"No"];
	[alertSheet setDestructiveButton: [[alertSheet buttons] objectAtIndex: 0]];
	[alertSheet setDefaultButton: [[alertSheet buttons] objectAtIndex: 1]];
	[alertSheet setDelegate:self];
	// 0: grey with grey and black buttons
	// 1: black background with grey and black buttons
	// 2: transparent black background with grey and black buttons
	// 3: grey transparent background
	[alertSheet setAlertSheetStyle: 0];
	[alertSheet presentSheetFromAboveView:self];		
}

- (void)changeDateOfReturnVisitAtIndex:(NSNumber *)index
{
	// they clicked on the Change Date
	_editingReturnVisit = [[_call objectForKey:CallReturnVisits] objectAtIndex:[index intValue]];
	// make the new call view 
	DatePickerView *p = [[[DatePickerView alloc] initWithFrame:_rect date:[_editingReturnVisit objectForKey:CallReturnVisitDate]] autorelease];

	// setup the callbacks for save or cancel
	[p setCancelAction: @selector(changeCallDateCancelAction:) forObject:self];
	[p setSaveAction: @selector(changeCallDateSaveAction:) forObject:self];
	[p setAutoresizingMask: kMainAreaResizeMask];
	[p setAutoresizesSubviews: YES];

	// transition from bottom up sliding ontop of the old view
	// first refcount us so that when we are not the main UIView
	// we dont get deleted prematurely
	[self retain];
	[[App getInstance] transition:1 fromView:self toView:p];
}

- (void)addPublicationToReturnVisitAtIndex:(NSNumber *)index
{
	//this is the add a new entry one
	_editingReturnVisit = [[_call objectForKey:CallReturnVisits] objectAtIndex:[index intValue]];
	_editingPublication = nil; // we are making a new one
	
	// make the new call view 
	PublicationView *p = [[[PublicationView alloc] initWithFrame:_rect] autorelease];

	// setup the callbacks for save or cancel
	[p setCancelAction: @selector(addNewPublicationCancelAction:) forObject:self];
	[p setSaveAction: @selector(addNewPublicationSaveAction:) forObject:self];
	[p setAutoresizingMask: kMainAreaResizeMask];
	[p setAutoresizesSubviews: YES];

	// transition from bottom up sliding ontop of the old view
	// first refcount us so that when we are not the main UIView
	// we dont get deleted prematurely
	[self retain];
	[[App getInstance] transition:1 fromView:self toView:p];
}

- (void)changeReturnVisitAtIndex:(NSNumber *)index withPublicationIndex:(NSNumber *)publicationIndex
{
	// they selected an existing entry
	_editingReturnVisit = [[_call objectForKey:CallReturnVisits] objectAtIndex:[index intValue]];
	_editingPublication = [[_editingReturnVisit objectForKey:CallReturnVisitPublications] objectAtIndex:[publicationIndex intValue]];
	
	// make the new call view 
	PublicationView *p = [[[PublicationView alloc] initWithFrame:_rect 
													 publication: [ _editingPublication objectForKey:CallReturnVisitPublicationName]
															year: [[_editingPublication objectForKey:CallReturnVisitPublicationYear] intValue]
														   month: [[_editingPublication objectForKey:CallReturnVisitPublicationMonth] intValue]
															 day: [[_editingPublication objectForKey:CallReturnVisitPublicationDay] intValue]] autorelease];

	// setup the callbacks for save or cancel
	[p setCancelAction: @selector(addNewPublicationCancelAction:) forObject:self];
	[p setSaveAction: @selector(addNewPublicationSaveAction:) forObject:self];
	[p setAutoresizingMask: kMainAreaResizeMask];
	[p setAutoresizesSubviews: YES];

	// transition from bottom up sliding ontop of the old view
	// first refcount us so that when we are not the main UIView
	// we dont get deleted prematurely
	[self retain];
	[[App getInstance] transition:1 fromView:self toView:p];
}






- (void)addGroup:(id)groupCell rowHeight:(int)rowHeight
{
	_currentGroup = [[[NSMutableDictionary alloc] init] autorelease];
	
	// initialize the arrays
	[_currentGroup setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallViewRows];
	[_currentGroup setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallViewSelectedInvocations];
	[_currentGroup setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallViewDeleteInvocations];
	[_currentGroup setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallViewInsertDelete];

	// set the group's settings
	if(groupCell != nil)
		[_currentGroup setObject:groupCell forKey:CallViewGroupCell];
	if(rowHeight >= 0)
		[_currentGroup setObject:[NSNumber numberWithInt:rowHeight] forKey:CallViewRowHeight];

	[_displayInformation addObject:_currentGroup];
}

- (void)     addRow:(id)cell 
     insertOrDelete:(CanInsertOrDelete)insertOrDelete 
   selectInvocation:(NSInvocation *)selectInvocation 
   deleteInvocation:(NSInvocation *)deleteInvocation
{
	NSInvocation *dummyInvocation = [self invocationForSelector:@selector(dummyFunction)];
	NSInvocation *unselectInvocation = [self invocationForSelector:@selector(unselectRow)];

	[[_currentGroup objectForKey:CallViewRows] addObject:cell];
	[[_currentGroup objectForKey:CallViewSelectedInvocations] addObject:(selectInvocation ? selectInvocation : unselectInvocation)];
	[[_currentGroup objectForKey:CallViewDeleteInvocations] addObject:(deleteInvocation ? deleteInvocation : dummyInvocation)];
	[[_currentGroup objectForKey:CallViewInsertDelete] addObject:[NSNumber numberWithInt:insertOrDelete]];
}

- (void)reloadData
{
	[_displayInformation release];

	// Name
	{
		[self addGroup:nil rowHeight:50];

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
			    insertOrDelete:kNone
			  selectInvocation:nil
			  deleteInvocation:nil];
		}
		else
		{
			// if we are not editing, then just display the name
			UIPreferencesTableCell *cell = [[[UIPreferencesTableCell alloc] init] autorelease];
			[cell setTitle:[_call objectForKey:CallName]];
			[cell setShowSelection:NO];
			[self       addRow:cell
			    insertOrDelete:kNone
			  selectInvocation:nil
			  deleteInvocation:nil];
		}
	}
	
	
	// Address
	{
		UIPreferencesTableCell *cell = [[UIPreferencesTableCell alloc ] init ];
		[ cell setTitle:@"Address" ];

		NSString *streetNumber = [_call objectForKey:CallStreetNumber];
		NSString *street = [_call objectForKey:CallStreet];
		NSString *city = [_call objectForKey:CallCity];
		NSString *state = [_call objectForKey:CallState];

		NSMutableString *top = [[NSMutableString alloc] init];
		[top setString:@""];
		NSMutableString *bottom = [[NSMutableString alloc] init];
		[bottom setString:@""];

		if(streetNumber != nil &&[streetNumber length])
			[top appendFormat:@"%@ ", streetNumber];
		if(street != nil && [street length])
			[top appendFormat:@"%@", street];
		if(city != nil && [city length])
			[bottom appendFormat:@"%@", city];
		if(state != nil && [state length])
			[bottom appendFormat:@", %@", state];
		VERY_VERBOSE(NSLog(@"address:\n%@\n%@", top, bottom);)

		UIView *view = [[UIView alloc] init];
		UITextLabel *label = [[[UITextLabel alloc] init] autorelease];
		[label setHighlightedColor:[[cell titleTextLabel] highlightedColor]];
		float bgColor[] = { 0,0,0,0 };
		[label setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
		[label setText:top];
		[label sizeToFit];
		CGRect lrect = [label bounds];
		lrect.origin.x += 100.0f;
		lrect.origin.y += 15.0f;
		[label setFrame: lrect];
		[view addSubview:label];

		label = [[[UITextLabel alloc] init] autorelease];
		[label setHighlightedColor:[[cell titleTextLabel] highlightedColor]];
		[label setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
		[label setText:bottom];
		[label sizeToFit];
		lrect = [label bounds];
		lrect.origin.x += 100.0f;
		lrect.origin.y += 35.0f;
		[label setFrame: lrect];
		[view addSubview:label];
		[cell addSubview:view];
		[cell setShowDisclosure: _editing];
		[cell updateHighlightColors];

		// add a group for the name
		[self addGroup:nil rowHeight:70];
		
		// add the name to the group
		[self       addRow:cell
			insertOrDelete:kNone
		  selectInvocation:[self invocationForSelector:@selector(addressSelected)]
		  deleteInvocation:nil];
	}

	// Add new Call
	if(_showAddCall)
	{
		// we need a larger row height
		[self addGroup:nil rowHeight:70];
		
		UIPreferencesTableCell *cell = [[[UIPreferencesTableCell alloc ] init ] autorelease];
		[ cell setShowDisclosure: NO ];
		if([[_call objectForKey:CallReturnVisits] count])
		{
			[ cell setValue:@"Add a return visit"];
		}
		else
		{
			[ cell setValue:@"Add a initial visit"];
		}
		[self       addRow:cell
			insertOrDelete:kCanInsert
		  selectInvocation:[self invocationForSelector:@selector(addReturnVisitSelected)]
		  deleteInvocation:nil];
	}

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
			UIPreferencesTableCell *cell = [[UIPreferencesTableCell alloc] init];
			NSCalendarDate *date = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[[visit objectForKey:CallReturnVisitDate] timeIntervalSinceReferenceDate]] autorelease];	
			[cell setTitle:[date descriptionWithCalendarFormat:@"%a %b %d, %Y"]];

			// create dictionary entry for This Return Visit
			[self addGroup:cell rowHeight:-1];


			// NOTES
			if(_editing)
			{
				UIPreferencesTextTableCell *text = [[ [ UIPreferencesTextTableCell alloc ] init ] autorelease];
				[ [text textField] setPlaceholder:@"Return Visit Notes" ];
				[ text setValue:[[returnVisits objectAtIndex:i] objectForKey:CallReturnVisitNotes]];
				[_returnVisitNotes addObject:text];

				[self       addRow:text
					insertOrDelete:kCanDelete
				  selectInvocation:nil
				  deleteInvocation:[self invocationForSelector:@selector(deleteReturnVisitAtIndex:) withArgument:[NSNumber numberWithInt:i]]];
			}
			else
			{
				UIPreferencesTableCell *cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				NSMutableString *notes = [[returnVisits objectAtIndex:i] objectForKey:CallReturnVisitNotes];
				if([notes length] == 0)
					[cell setValue:@"Return Visit Notes"];
				else
					[cell setValue:notes];
				[cell setShowSelection:NO];


				[self       addRow:cell
					insertOrDelete:kNone
				  selectInvocation:nil
				  deleteInvocation:nil];
			}

			// CHANGE DATE
			if(_editing)
			{
				UIPreferencesTableCell *cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setShowDisclosure:YES];
				[cell setValue:@"Change Date"];
				[cell setShowSelection:NO];
				
				[self       addRow:cell
					insertOrDelete:kNone
				  selectInvocation:[self invocationForSelector:@selector(changeDateOfReturnVisitAtIndex:) withArgument:[NSNumber numberWithInt:i]]
				  deleteInvocation:nil];
			}

		
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

					// PUBLICATION
					NSMutableDictionary *publication = [publications objectAtIndex:j];
					cell = [[[UIPreferencesTableCell alloc ] init ] autorelease];
					[cell setShowDisclosure: _editing ];
					[cell setShowSelection: _editing];
					[cell setTitle:[publication objectForKey:CallReturnVisitPublicationTitle]];

					if(_editing)
					{
						[self       addRow:cell
							insertOrDelete:kCanDelete
						  selectInvocation:[self invocationForSelector:@selector(changeReturnVisitAtIndex:publicatoinAtIndex:) withArgument:[NSNumber numberWithInt:i] andArgument:[NSNumber numberWithInt:j]]
						  deleteInvocation:[self invocationForSelector:@selector(deleteReturnVisitAtIndex:publicationAtIndex:) withArgument:[NSNumber numberWithInt:i] andArgument:[NSNumber numberWithInt:j]]];
					}
					else
					{
						[self       addRow:cell
							insertOrDelete:kNone
						  selectInvocation:nil
						  deleteInvocation:nil];
					}
				}
			}
			
			// add publication
			if(_editing)
			{
				cell = [[[UIPreferencesTableCell alloc] init] autorelease];
				[cell setShowDisclosure: YES];
				[cell setValue:@"Add a placed publication"];

				[self       addRow:cell
					insertOrDelete:kCanInsert
				  selectInvocation:[self invocationForSelector:@selector(addPublicationToReturnVisitAtIndex:) withArgument:[NSNumber numberWithInt:i]]
				  deleteInvocation:nil];
			}
			
			
			// DELETE call
			if(_editing)
			{
				[self addGroup:nil rowHeight:-1];

				// DELETE
				cell = [[[UIPreferencesDeleteTableCell alloc ] initWithFrame:CGRectMake(0, 0, 320, 45) ] autorelease];
				[cell setShowDisclosure: NO ];
				[cell setTitle:@"Delete Call"];
				[cell setAlignment:2 ];
				float wcolorComponents[4] = {1.0, 1.0, 1.0, 1.0};
				CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceRGB();
				CGColorRef whiteColor = CGColorCreate(rgbSpace, wcolorComponents);
				CGColorSpaceRelease(rgbSpace);

				[[cell titleTextLabel] setColor:whiteColor];
			
				[self       addRow:cell
					insertOrDelete:kNone
				  selectInvocation:[self invocationForSelector:@selector(deleteCall)]
				  deleteInvocation:nil];
			}
		}
		
	}
	
	[_table reloadData];
}


- (void)dealloc
{
    DEBUG(NSLog(@"CallView: dealloc");)
    [_name release];
    [_call release];
    [_navigationBar release];
    [_table release];
	[_displayInformation release];

    [super dealloc];
}
/******************************************************************
 *
 *   INIT
 *
 ******************************************************************/

- (id) initWithFrame: (CGRect)rect
{
    DEBUG(NSLog(@"CallView 1initWithFrame: %p", self);)
    return([self initWithFrame:rect call:nil]);
}

- (id) initWithFrame: (CGRect)rect call:(NSMutableDictionary *)call
{
    if((self = [super initWithFrame: rect])) 
    {
		[self becomeFirstResponder];
		[self setAutoresizingMask: kMainAreaResizeMask];
		[self setAutoresizesSubviews: YES];
		
        NSString *temp;
        DEBUG(NSLog(@"CallView 2initWithFrame:call:%@", call);)

        _saveObject = nil;
        _cancelObject = nil;
		_deleteObject = nil;
		_setFirstResponderGroup = -1;


		_newCall = (call == nil);
		_editing = _newCall;
		_showDeleteButton = !_newCall;
		if(_newCall)
		{
			_call = [[NSMutableDictionary alloc] init];
		}
		else
		{
			_call = [[NSMutableDictionary alloc] initWithDictionary:call copyItems:YES];
		}
		_showAddCall = YES;


        _name = [[UIPreferencesTextTableCell alloc] init];
        // _name (make sure that it is initalized)
        [_name setTitle:@"Name"];
        if((temp = [_call objectForKey:CallName]) != nil)
            [_name setValue:temp];
        else
            [_call setObject:@"" forKey:CallName];


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
                    [visit setObject:[NSCalendarDate calendarDate] forKey:CallReturnVisitDate];
                
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
        
        _rect = rect;   
        // make the navigation bar with
        //                        +
        CGSize s = [UINavigationBar defaultSize];
        _navigationBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0,0,rect.size.width, s.height)];
        [_navigationBar setDelegate: self];
		[_navigationBar setAutoresizingMask: kTopBarResizeMask];
		[_navigationBar setAutoresizesSubviews: YES];
        [self addSubview: _navigationBar]; 

		// 0 = greay
		// 1 = red
		// 2 = left arrow
		// 3 = blue
		if(_newCall)
		{
			_setFirstResponderGroup = 0;
			[_navigationBar pushNavigationItem: [[[UINavigationItem alloc] initWithTitle:@"New Call"] autorelease] ];
			[_navigationBar showLeftButton:@"Cancel" withStyle:2 rightButton:@"Done" withStyle:3];
		}
		else
		{
			[_navigationBar pushNavigationItem: [[[UINavigationItem alloc] initWithTitle:@"Call"] autorelease] ];
			[_navigationBar showLeftButton:@"All Calls" withStyle:2 rightButton:@"Edit" withStyle:0];
		}
        
        _table = [[UIPreferencesTable alloc] initWithFrame: CGRectMake(0, s.height, rect.size.width, rect.size.height - s.height)];
        [self addSubview: _table];
        [_table setDelegate: self];
        [_table setDataSource: self];
		[_table enableRowDeletion: YES animated:YES];
		[_table setAutoresizingMask: kMainAreaResizeMask];
		[_table setAutoresizesSubviews: YES];

        [self reloadData];
    }
    
    return(self);
}

- (void)saveReturnVisitsNotes
{
	VERY_VERBOSE(NSLog(@"saveReturnVisitsNotes");)
	// rebuild the return visit notes
	NSMutableArray *returnVisits = [[NSMutableArray alloc] initWithArray:[_call objectForKey:CallReturnVisits]];
	int count = [returnVisits count];
	int i;
	for(i = 0; i < count; ++i)
	{
		// get the notes cell
		UIPreferencesTextTableCell *text = [_returnVisitNotes objectAtIndex:i];
		// make a brandnew NSMutableDictionary because the old one might not be Mutable and copy
		// the contents of the original return visit
		NSMutableDictionary *visit = [[NSMutableDictionary alloc] initWithDictionary:[returnVisits objectAtIndex:i]];
		// replace the CallReturnVisitNotes object with the contents of the text cell
		[visit setObject:[text value] forKey:CallReturnVisitNotes];
		[returnVisits replaceObjectAtIndex:i withObject:visit];
	}
	[_call setObject:returnVisits forKey:CallReturnVisits];
}

/******************************************************************
 *
 *   PUBLICATION VIEW CALLBACKS
 *
 ******************************************************************/

- (void)addNewPublicationCancelAction: (PublicationView *)publicationView
{
    DEBUG(NSLog(@"CallView addNewPublicationCancelAction:");)
    [[App getInstance] transition:2 fromView:publicationView toView:self];
    [_table setKeyboardVisible:NO animated:NO];
	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
    // release the refcount on ourselves since we are now the main UIView
    [self release];
}

- (void)addNewPublicationSaveAction: (PublicationView *)publicationView
{
    DEBUG(NSLog(@"CallView addNewPublicationSaveAction:");)
    
    if(_editingPublication == nil)
    {
        VERBOSE(NSLog(@"creating a new publication entry and adding it");)
        // if we are adding a publication then create the NSDictionary and add it to the end
        // of the publications array
        _editingPublication = [[[NSMutableDictionary alloc] init] autorelease];
        [[_editingReturnVisit objectForKey:CallReturnVisitPublications] addObject:_editingPublication];
    }
    VERBOSE(NSLog(@"_editingPublication was = %@", _editingPublication);)
    [_editingPublication setObject:[publicationView publication] forKey:CallReturnVisitPublicationName];
    [_editingPublication setObject:[publicationView publicationTitle] forKey:CallReturnVisitPublicationTitle];
    [_editingPublication setObject:[publicationView publicationType] forKey:CallReturnVisitPublicationType];
    [_editingPublication setObject:[[[NSNumber alloc] initWithInt:[publicationView year]] autorelease] forKey:CallReturnVisitPublicationYear];
    [_editingPublication setObject:[[[NSNumber alloc] initWithInt:[publicationView month]] autorelease] forKey:CallReturnVisitPublicationMonth];
    [_editingPublication setObject:[[[NSNumber alloc] initWithInt:[publicationView day]] autorelease] forKey:CallReturnVisitPublicationDay];
    VERBOSE(NSLog(@"_editingPublication is = %@", _editingPublication);)

    [_table setKeyboardVisible:NO animated:NO];
	[_table reloadData];
    [[App getInstance] transition:2 fromView:publicationView toView:self];
	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];

	// reload like we inserted a publication at the row they clicked on
//	[_table reloadDataForInsertionOfRows:NSMakeRange(_selectedRow, 2) animated:YES];

    // release the refcount on ourselves since we are now the main UIView
    [self release];

	// save the data
	[self save];
}



/******************************************************************
 *
 *   DATE PICKER VIEW CALLBACKS
 *
 ******************************************************************/

- (void)changeCallDateCancelAction: (DatePickerView *)view
{
    DEBUG(NSLog(@"CallView changeCallDateCancelAction:");)
    [[App getInstance] transition:2 fromView:view toView:self];
    [_table setKeyboardVisible:NO animated:NO];
	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
    // release the refcount on ourselves since we are now the main UIView
    [self release];
}

- (void)changeCallDateSaveAction: (DatePickerView *)view
{
    DEBUG(NSLog(@"CallView changeCallDateSaveAction:");)
    VERBOSE(NSLog(@"date is now = %@", [view date]);)

    [_editingReturnVisit setObject:[view date] forKey:CallReturnVisitDate];
    
	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
    [_table setKeyboardVisible:NO animated:NO];
    [[App getInstance] transition:2 fromView:view toView:self];

	[_table reloadData];
    // release the refcount on ourselves since we are now the main UIView
    [self release];

	// save the data
	[self save];
}

/******************************************************************
 *
 *   ADDRESS VIEW CALLBACKS
 *
 ******************************************************************/

- (void)editAddressCancelAction: (AddressView *)addressView
{
    DEBUG(NSLog(@"PublicationView editAddressCancelAction:");)
    //transitions:
    // 0 nothing
    // 1 slide left with the to view to the right
    // 2 slide right with the to view to the left
    // 3 from bottom up with the to view right below the from view
    // 4 from bottom up, but background seems to be invisible
    // 5 from top down, but background seems to be invisible
    // 6 fade away to the to view
    // 7 down with the to view above the from view
    // 8 from bottom up sliding ontop of
    // 9 from top down sliding ontop of
    [[App getInstance] transition:2 fromView:addressView toView:self];
    [_table setKeyboardVisible:NO animated:NO];
	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
    // release the refcount on ourselves since we are now the main UIView
    [self release];
}

- (void)editAddressSaveAction: (AddressView *)addressView
{
    DEBUG(NSLog(@"PublicationView editAddressSaveAction:");)
    [_call setObject:[addressView streetNumber] forKey:CallStreetNumber];
    [_call setObject:[addressView street] forKey:CallStreet];
    [_call setObject:[addressView city] forKey:CallCity];
    [_call setObject:[addressView state] forKey:CallState];
    VERBOSE(NSLog(@"%@ %@ %@", [addressView street], [addressView city], [addressView state]);)
	
	// save the address information as the last saved address so that the user does not
	// have to enter everything, just the house number if they are on the same street
	NSMutableDictionary *settings = [[App getInstance] getSavedData];
	[settings setObject:[addressView street] forKey:SettingsLastCallStreet];
	[settings setObject:[addressView city] forKey:SettingsLastCallCity];
	[settings setObject:[addressView state] forKey:SettingsLastCallState];

	[_table reloadCellAtRow:_selectedRow column:0 animated:YES];
    [[App getInstance] transition:2 fromView:addressView toView:self];
    [_table setKeyboardVisible:NO animated:NO];
	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
    // release the refcount on ourselves since we are now the main UIView
    [self release];

	// save the data
	[self save];
}


/******************************************************************
 *
 *   PREFERENCES TABLE DELEGATE FUNCTIONS
 *
 ******************************************************************/
- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable *)table 
{
    VERBOSE(NSLog(@"numberOfGroupsInPreferencesTable:");)
    int count = [_displayInformation count];
	VERBOSE(NSLog(@"count=%d", count);)
    return(count);
}
- (int) preferencesTable: (UIPreferencesTable *)table numberOfRowsInGroup: (int) group 
{
    VERBOSE(NSLog(@"preferencesTable: numberOfRowsInGroup:%d", group);)
    int count = [[[_displayInformation objectAtIndex:group] objectForKey:CallViewRows] count];
	VERBOSE(NSLog(@"count=%d", count);)
	return(count);
}

- (UIPreferencesTableCell *)preferencesTable:(UIPreferencesTable *)aTable cellForGroup:(int)group
{
    VERBOSE(NSLog(@"preferencesTable: cellForGroup:%d", group);)

    UIPreferencesTextTableCell *cell = [[_displayInformation objectAtIndex:group] objectForKey:CallViewGroupCell];
    return(cell);
} 

- (float)preferencesTable: (UIPreferencesTable *)table heightForRow: (int)row inGroup:(int)group withProposedHeight: (float)proposed 
{
    VERBOSE(NSLog(@"preferencesTable: heightForRow:%d inGroup:%d withProposedHeight:%f", row, group, proposed);)
	if(row == 0)
	{
		return([[[_displayInformation objectAtIndex:group] objectForKey:CallViewRowHeight] intValue]);
	}
#if 0
	else if (row == -1) 
	{
		if([[_displayInformation objectAtIndex:group] objectForKey:CallViewGroupCell] != nil)
		{
			return 40;
		}
	}
#endif
    return proposed;
}

- (BOOL)preferencesTable:(UIPreferencesTable *)aTable isLabelGroup:(int)group 
{
    VERBOSE(NSLog(@"preferencesTable: isLabelGroup:%d", group);)
	return(NO);
}


- (UIPreferencesTableCell *)preferencesTable: (UIPreferencesTable *)table cellForRow: (int)row inGroup: (int)group 
{
    VERBOSE(NSLog(@"preferencesTable: cellForRow:%d inGroup:%d", row, group);)

	return([[[_displayInformation objectAtIndex:group] objectForKey:CallViewRows] objectAtIndex:row]);

#if 0	
    switch (group) 
    {
        // Name
        case 0:
            switch (row) 
            {
                case 0:
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
					if(_editing)
					{
						[_name retain];
						cell = _name;
						if(_setFirstResponderGroup == group)
						{
							_setFirstResponderGroup = -1;
							[self performSelector: @selector(setFocus:) 
									   withObject:_name
									   afterDelay:.3];
						}
					}
					else
					{
						// if we are not editing, then 
						cell = [[[UIPreferencesTableCell alloc] init] autorelease];
						[cell setTitle:[_call objectForKey:CallName]];
						[cell setShowSelection:NO];
					}
                    break;
            }
            break;

				NSMutableDictionary *info = [[_call objectForKey:CallReturnVisits] objectAtIndex:group-adjust];
				if(row == 0)
				{
					// NOTES
					if(_editing)
					{
						// pull the cell from the prebuilt _returnVisitNotes
						UIPreferencesTextTableCell *text = [_returnVisitNotes objectAtIndex:group-adjust];
						cell = text;
						if(_setFirstResponderGroup == group)
						{
							_setFirstResponderGroup = -1;
							[self performSelector: @selector(setFocus:) 
									   withObject:text 
									   afterDelay:.3];
						}
					}
					else
					{
						// if we are not editing, then 
						cell = [[[UIPreferencesTableCell alloc] init] autorelease];
						if([[info objectForKey:CallReturnVisitNotes] length] == 0)
							[cell setValue:@"Return Visit Notes"];
						else
							[cell setValue:[info objectForKey:CallReturnVisitNotes]];
						[cell setShowSelection:NO];
					}
					
				}
            break;
        }
    }
#endif
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
	[sheet dismissAnimated:YES];
	if(button == 1)
	{
		if(_deleteObject != nil)
		{
			[_deleteObject performSelector:_deleteSelector withObject:self];
		}
	}
}

- (void)animateInsertRows: (NSNumber *)start
{
//	NSNumber *start = [timer userInfo];
	VERBOSE(NSLog(@"animateInsertRows for %d", [start intValue]);)
	// reload the group title
	[_table reloadCellAtRow: [start intValue] - 1 column:0 animated:YES];
	// reload the inserted rows
	[_table reloadDataForInsertionOfRows:NSMakeRange([start intValue], 3) animated:YES];
}

- (void)tableRowSelected:(NSNotification*)notification
{
    int row = [[notification object] selectedRow];
    DEBUG(NSLog(@"tableRowSelected: tableRowSelected row=%@ row%d editing%d", notification, row, _editing);)
	_selectedRow = row;

	// there is nothing to select in row 1
	if(row == 0)
		return;
	int groupCount = [_displayInformation count];
	int group;
	int i;
	int rowCount;
	for(group = 0; group < groupCount; ++group)
	{
		NSMutableDictionary *info = [_displayInformation objectAtIndex:group];
		// sutract off the group's row
		--row;
		rowCount = [[info objectForKey:CallViewInsertDelete] count];
		for(i = 0; i < rowCount; ++i)
		{
			if(row == 0)
			{
				[[[info objectForKey:CallViewSelectedInvocations] objectAtIndex:i] invoke];
				return;
			}
			--row;
		}
	}
	
}

-(BOOL)table:(UITable*)table canDeleteRow:(int)row
{
    VERBOSE(NSLog(@"table: canDeleteRow: %d _showAddCall:%d", row, _showAddCall);)
	if(!_editing)
		return(NO);
		
	// cant insert/delete the group title
	if(row == 0)
		return(NO);

	int groupCount = [_displayInformation count];
	int group;
	int i;
	int rowCount;
	for(group = 0; group < groupCount; ++group)
	{
		NSMutableDictionary *info = [_displayInformation objectAtIndex:group];
		// sutract off the group's row
		--row;
		rowCount = [[info objectForKey:CallViewInsertDelete] count];
		for(i = 0; i < rowCount; ++i)
		{
			if(row == 0)
			{
				return( [[[info objectForKey:CallViewInsertDelete] objectAtIndex:i] intValue] == kCanDelete);
			}
			--row;
		}
	}
    return(NO);    
}

-(BOOL)table:(UITable*)table canInsertAtRow:(int)row
{
    VERBOSE(NSLog(@"table: canInsertAtRow: %d", row);)
	
	// cant insert/delete the group title
	if(row == 0)
		return(NO);

	int groupCount = [_displayInformation count];
	int group;
	int i;
	int rowCount;
	for(group = 0; group < groupCount; ++group)
	{
		NSMutableDictionary *info = [_displayInformation objectAtIndex:group];
		// sutract off the group's row
		--row;
		rowCount = [[info objectForKey:CallViewInsertDelete] count];
		for(i = 0; i < rowCount; ++i)
		{
			if(row == 0)
			{
				return( [[[info objectForKey:CallViewInsertDelete] objectAtIndex:i] intValue] == kCanInsert);
			}
			--row;
		}
	}
    return(NO);    
}

-(void)table:(UITable*)table deleteRow:(int)row
{
    DEBUG(NSLog(@"table: deleteRow:%d", row);)

	// cant insert/delete the group title
	if(row == 0)
		return;

	_selectedRow = row;

	int groupCount = [_displayInformation count];
	int group;
	int i;
	int rowCount;
	for(group = 0; group < groupCount; ++group)
	{
		NSMutableDictionary *info = [_displayInformation objectAtIndex:group];
		// sutract off the group's row
		--row;
		rowCount = [[info objectForKey:CallViewInsertDelete] count];
		for(i = 0; i < rowCount; ++i)
		{
			if(row == 0)
			{
				[[info objectForKey:CallViewDeleteInvocations] invoke];
				return;
			}
			--row;
		}
	}
}

/******************************************************************
 *
 *   ACCESSOR METHODS
 *
 ******************************************************************/

- (NSString *)name
{
    if([_name value] == nil)
        return(@"");
    else
        return([_name value]);
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


- (void)setBounds:(CGRect)rect
{
	if([_table keyboardVisible])
	{
		CGRect frame = [[UIKeyboard activeKeyboard] frame];
		frame.size = [UIKeyboard defaultSizeForOrientation:[[App getInstance] orientation]];
		[[_table keyboard] setFrame:frame];
	}
	[super setBounds:rect];
}


- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"CallView respondsToSelector: %s", selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"CallView methodSignatureForSelector: %s", selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"CallView forwardInvocation: %s", [invocation selector]);)
    [super forwardInvocation:invocation];
}


@end
