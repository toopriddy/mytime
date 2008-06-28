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
#import <UIKit/UIPickerView.h>
#import <UIKit/UITextFieldLabel.h>
#import <GraphicsServices/GraphicsServices.h>
#import <UIKit/UIKit.h>
#import "LiteraturePlacementView.h"
#import "App.h"
#import "TimePickerView.h"
#import "DatePickerView.h"

@implementation LiteraturePlacementTable

- (id)initWithFrame:(CGRect) rect entries:(NSMutableArray*) timeEntries;
{
    if((self = [super initWithFrame: rect])) 
    {
		DEBUG(NSLog(@"LiteraturePlacementTable: initWithFrame");)
		_entries = timeEntries;
		_offset = rect.origin;
		[self enableRowDeletion: YES animated:YES];
		
	}
	return self;
}

- (int)swipe:(int)direction withEvent:(struct __GSEvent *)event;
{
	if ((direction == kSwipeDirectionRight) || (direction == kSwipeDirectionLeft) )
	{
        // The line below should be used with the newer toolchain.  If you
        // are using the older toolchain, comment this one out and use the
        // two commented out lines below.
        CGPoint point = GSEventGetLocationInWindow(event);
		
        // The next two lines are used with the old toolchain.  If you are
        // using the older toolchain uncomment these two lines and comment
        // out the line above.
		//	CGRect rect = GSEventGetLocationInWindow(event);
		//	CGPoint point = CGPointMake(rect.origin.x, rect.origin.y-50.0f); 
		
		point.x -= _offset.x;
		point.y -= _offset.y;
		
		int row = [self rowAtPoint:point];
		
		if( [[self visibleCellForRow:row column:0] isRemoveControlVisible] )
		{
			[[self visibleCellForRow:row column:0] _showDeleteOrInsertion:NO 
														   withDisclosure:NO 
																 animated:NO 
																 isDelete:NO 
													andRemoveConfirmation:NO];
		}
		else
		{
			[[self visibleCellForRow:row column:0] _showDeleteOrInsertion:YES
		                                                   withDisclosure:NO 
														         animated:YES 
																 isDelete:YES 
													andRemoveConfirmation:YES];
		}	
	}
	return [super swipe:direction withEvent:event];
}

- (BOOL)respondsToSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"LiteraturePlacementTable respondsToSelector: %s", selector);)
	return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"LiteraturePlacementTable methodSignatureForSelector: %s", selector);)
	return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
	VERY_VERBOSE(NSLog(@"LiteraturePlacementTable forwardInvocation: %s", [invocation selector]);)
	[super forwardInvocation:invocation];
}
@end


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
extern NSString const * const SettingsBulkLiterature;
extern NSString const * const BulkLiteratureDate;
extern NSString const * const BulkLiteratureArray;
extern NSString const * const BulkLiteratureArrayCount;
extern NSString const * const BulkLiteratureArrayTitle;
extern NSString const * const BulkLiteratureArrayName;
extern NSString const * const BulkLiteratureArrayYear;
extern NSString const * const BulkLiteratureArrayMonth;
extern NSString const * const BulkLiteratureArrayDay;





@implementation LiteraturePlacementView

- (void)dealloc
{
	[_table release];
	[_editingPlacements release];
	
	[super dealloc];
}

- (id) initWithFrame: (CGRect)rect
{
	return([self initWithFrame:rect placements:nil]);
}



- (id) initWithFrame: (CGRect)rect placements:(NSMutableDictionary *)placements
{
    if((self = [super initWithFrame: rect])) 
    {
        DEBUG(NSLog(@"LiteraturePlacementView initWithFrame:");)
        _saveObject = nil;
        _cancelObject = nil;
		
		
		_editingPlacements = [[NSMutableDictionary alloc] initWithDictionary:placements];
		NSMutableArray *entries = [[[NSMutableArray alloc] initWithArray:[placements objectForKey:BulkLiteratureArray]] autorelease];
		[_editingPlacements setObject:entries forKey:BulkLiteratureArray];
		
		if([_editingPlacements objectForKey:BulkLiteratureDate] == nil)
			[_editingPlacements setObject:[NSCalendarDate calendarDate] forKey:BulkLiteratureDate];
		
        _rect = rect;   
        // make the navigation bar 
        CGSize s = [UINavigationBar defaultSize];
        _navigationBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0,0,rect.size.width, s.height)];
        [_navigationBar setDelegate: self];
		[_navigationBar setAutoresizingMask: kTopBarResizeMask];
		[_navigationBar setAutoresizesSubviews: YES];
        [self addSubview: _navigationBar]; 
		
		// 0 = gray
		// 1 = red
		// 2 = left arrow
		// 3 = blue
		[_navigationBar pushNavigationItem: [[[UINavigationItem alloc] initWithTitle:@"Placements"] autorelease] ];
		[_navigationBar showLeftButton:@"Cancel" withStyle:2 rightButton:@"Done" withStyle:3];
		_table = [[LiteraturePlacementTable alloc] initWithFrame: CGRectMake(0, s.height, rect.size.width, rect.size.height - s.height) 
		                                           entries:entries];
		
        [_table setDelegate: self];
        [_table setDataSource: self];
		[_table enableRowDeletion: YES animated:YES];
		[_table setAutoresizingMask: kMainAreaResizeMask];
		[_table setAutoresizesSubviews: YES];
        [self addSubview: _table];
		[_table reloadData];
    }
    
    return(self);
}

- (void)unselectRow
{
	DEBUG(NSLog(@"unselectRow");)
	// unselect the row
	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
}

- (NSMutableDictionary *)placements
{
	return([[_editingPlacements retain] autorelease]);
}



/******************************************************************
 *
 *   PUBLICATION VIEW CALLBACKS
 *
 ******************************************************************/

- (void)publicationCancelAction: (PublicationView *)publicationView
{
    DEBUG(NSLog(@"LiteraturePlacementView addNewPublicationCancelAction:");)
	int transition = _editingPublication ? 2 : 2;
    [[App getInstance] transition:transition fromView:publicationView toView:self];

	// have the row unselect after the transition back to the LiteraturePlacementView so that the user
	// knows where they were and what they clicked on 
	[self performSelector: @selector(unselectRow) 
			   withObject:self
			   afterDelay:.2];
	
    // release the refcount on ourselves since we are now the main UIView
    [self release];
}

- (void)publicationSaveAction: (PublicationView *)publicationView
{
    DEBUG(NSLog(@"LiteraturePlacementView addNewPublicationSaveAction:");)
    NSMutableDictionary *publication;
	
    if(_editingPublication == -1)
    {
        VERBOSE(NSLog(@"creating a new publication entry and adding it");)
        // if we are adding a publication then create the NSDictionary and add it to the end
        // of the publications array
        publication = [[[NSMutableDictionary alloc] init] autorelease];
        [[_editingPlacements objectForKey:BulkLiteratureArray] addObject:publication];
    }
	else
	{
        publication = [[[NSMutableDictionary alloc] init] autorelease];
        [[_editingPlacements objectForKey:BulkLiteratureArray] replaceObjectAtIndex:_editingPublication withObject:publication ];
	}
	DEBUG(NSLog(@"EditingPlacements %@",_editingPlacements);)
	PublicationPicker *picker = [publicationView publicationPicker];
    [publication setObject:[picker publication] forKey:BulkLiteratureArrayName];
    [publication setObject:[picker publicationTitle] forKey:BulkLiteratureArrayTitle];
    [publication setObject:[picker publicationType] forKey:BulkLiteratureArrayType];
    [publication setObject:[[[NSNumber alloc] initWithInt:[picker year]] autorelease] forKey:BulkLiteratureArrayYear];
    [publication setObject:[[[NSNumber alloc] initWithInt:[picker month]] autorelease] forKey:BulkLiteratureArrayMonth];
    [publication setObject:[[[NSNumber alloc] initWithInt:[picker day]] autorelease] forKey:BulkLiteratureArrayDay];
    [publication setObject:[[[NSNumber alloc] initWithInt:[publicationView count]] autorelease] forKey:BulkLiteratureArrayCount];

    VERBOSE(NSLog(@"publication is = %@", publication);)
	
	[_table reloadData];
    [[App getInstance] transition:2 fromView:publicationView toView:self];
	
	// have the row unselect after the transition back to the LiteraturePlacementView so that the user
	// knows where they were and what they clicked on 
	[self performSelector: @selector(unselectRow) 
			   withObject:self
			   afterDelay:.2];
	
    // release the refcount on ourselves since we are now the main UIView
    [self release];
}


/******************************************************************
 *
 *   DATE PICKER VIEW CALLBACKS
 *
 ******************************************************************/

- (void)changeDateCancelAction: (DatePickerView *)view
{
    DEBUG(NSLog(@"LiteraturePlacementView changeCallDateCancelAction:");)
    [[App getInstance] transition:2 fromView:view toView:self];
	
	// have the row unselect after the transition back to the CallView so that the user
	// knows where they were and what they clicked on 
	[self performSelector: @selector(unselectRow) 
			   withObject:_table
			   afterDelay:.2];
	
    // release the refcount on ourselves since we are now the main UIView
    [self release];
}

- (void)changeDateSaveAction: (DatePickerView *)view
{
    DEBUG(NSLog(@"LiteraturePlacementView changeCallDateSaveAction:");)
    VERBOSE(NSLog(@"date is now = %@", [view date]);)
	
    [_editingPlacements setObject:[view date] forKey:BulkLiteratureDate];
    
	// have the row unselect after the transition back to the CallView so that the user
	// knows where they were and what they clicked on 
	[self performSelector: @selector(unselectRow) 
			   withObject:_table
			   afterDelay:.2];
	
    [[App getInstance] transition:2 fromView:view toView:self];
	
	[_table reloadData];
	
    // release the refcount on ourselves since we are now the main UIView
    [self release];
}



/******************************************************************
 *
 *   NAVIGATION BAR
 *   1 left button                                0 right button
 ******************************************************************/
- (void)navigationBar:(UINavigationBar*)nav buttonClicked:(int)button
{
    VERBOSE(NSLog(@"LiteraturePlacementView navigationBar: buttonClicked:%s", button ? "cancel" : "save");)
	if(button == 1)
	{
        if(_cancelObject != nil)
        {
            [_cancelObject performSelector:_cancelSelector withObject:self];
        }
	}
	else
	{
        if(_saveObject != nil)
        {
            [_saveObject performSelector:_saveSelector withObject:self];
        }
	}
}

/******************************************************************
 *
 *   PREFERENCES TABLE DELEGATE FUNCTIONS
 *
 ******************************************************************/
- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable *)table 
{
    VERBOSE(NSLog(@"LiteraturePlacementView numberOfGroupsInPreferencesTable:");)
	//Date
	//Literature
    return(2);
}

- (int) preferencesTable: (UIPreferencesTable *)table numberOfRowsInGroup: (int) group 
{
    VERBOSE(NSLog(@"LiteraturePlacementView preferencesTable: numberOfRowsInGroup:%d", group);)
	if(group == 0) // Date
	{
		return(1);
	}
	// literature placements plus an add entry
	return([[_editingPlacements objectForKey:BulkLiteratureArray] count] + 1);
}

- (UIPreferencesTableCell *)preferencesTable:(UIPreferencesTable *)aTable cellForGroup:(int)group
{
    VERBOSE(NSLog(@"LiteraturePlacementView preferencesTable: cellForGroup:%d", group);)
    UIPreferencesTableCell *cell = nil;
	
	if(group == 1)
	{
		cell = [[UIPreferencesTableCell alloc] initWithFrame:CGRectZero];
		[cell setTitle:@"Placements:"];
	}

    return(cell);
} 

- (float)preferencesTable: (UIPreferencesTable *)table heightForRow: (int)row inGroup:(int)group withProposedHeight: (float)proposed 
{
    VERBOSE(NSLog(@"LiteraturePlacementView preferencesTable: heightForRow:%d inGroup:%d withProposedHeight:%f", row, group, proposed);)
	if(row == -1 && group == 1)
		return(40.0);
    return proposed;
}

- (BOOL)preferencesTable:(UIPreferencesTable *)aTable isLabelGroup:(int)group 
{
    VERBOSE(NSLog(@"LiteraturePlacementView preferencesTable: isLabelGroup:%d", group);)
	return(NO);
}


- (UIPreferencesTableCell *)preferencesTable: (UIPreferencesTable *)table cellForRow: (int)row inGroup: (int)group 
{
    VERBOSE(NSLog(@"LiteraturePlacementView preferencesTable: cellForRow:%d inGroup:%d", row, group);)
	if(group == 0)
	{
		UIPreferencesTableCell *cell = [[UIPreferencesTableCell alloc] initWithFrame:CGRectZero];
		[cell setShowDisclosure:YES];
		NSCalendarDate *date = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[[_editingPlacements objectForKey:BulkLiteratureDate] timeIntervalSinceReferenceDate]] autorelease];	
		[cell setTitle:[date descriptionWithCalendarFormat:@"%a %b %d, %Y"]];
		return(cell);
	}
	else
	{
		if(row == [[_editingPlacements objectForKey:BulkLiteratureArray] count])
		{
			UIPreferencesTableCell *cell = [[[UIPreferencesTableCell alloc] initWithFrame:CGRectZero] autorelease];
			[cell setShowDisclosure:YES];
			[cell setShowSelection: YES];
			[cell setValue:@"Add a placed publications"];
			return(cell);
		}
		else
		{
			UIPreferencesTableCell *cell = [[[UIPreferencesTableCell alloc ] initWithFrame:CGRectZero ] autorelease];
			[cell setShowDisclosure: YES];
			[cell setShowSelection: YES];
			NSMutableDictionary *entry = [[_editingPlacements objectForKey:BulkLiteratureArray] objectAtIndex:row];
			NSString *name = [entry objectForKey:BulkLiteratureArrayTitle];
			int count = [[entry objectForKey:BulkLiteratureArrayCount] intValue];
			NSString *type = [entry objectForKey:BulkLiteratureArrayType];
			if([type isEqualToString:@"Magazine"])
			{
				[cell setTitle:[NSString stringWithFormat:@"%d: %@", count, name]];
			}
			else
			{
				[cell setTitle:[NSString stringWithFormat:@"%d %@%@: %@", count, type, count == 1 ? @"" : @"s", name]];
			}
			return(cell);
		}
		
	}
}

- (void)tableRowSelected:(NSNotification*)notification
{
    int row = [[notification object] selectedRow];
    DEBUG(NSLog(@"LiteraturePlacementView tableRowSelected: tableRowSelected row=%@ row%d", notification, row);)
	
	if(row == 1)
	{
		DatePickerView *p = [[[DatePickerView alloc] initWithFrame:_rect date:[_editingPlacements objectForKey:BulkLiteratureDate]] autorelease];
		
		// setup the callbacks for save or cancel
		[p setCancelAction: @selector(changeDateCancelAction:) forObject:self];
		[p setSaveAction: @selector(changeDateSaveAction:) forObject:self];
		[p setAutoresizingMask: kMainAreaResizeMask];
		[p setAutoresizesSubviews: YES];
		
		// transition from bottom up sliding ontop of the old view
		// first refcount us so that when we are not the main UIView
		// we dont get deleted prematurely
		[self retain];
		[[App getInstance] transition:1 fromView:self toView:p];
		return;
	}
	else if(row < 3)
	{
		// nothing to do here
		return;
	}
	else
	{
		PublicationView *p;
		if(row == 3 + [[_editingPlacements objectForKey:BulkLiteratureArray] count])
		{
			// they selected to add a new placement
			_editingPublication = -1;
			// make the new call view 
			p = [[[PublicationView alloc] initWithFrame:_rect showCount:YES] autorelease];
		}
		else
		{
			// they selected to change an existing placement
			row -= 3;
			_editingPublication = row;
			// make the new call view 
			// make the new call view 
			NSMutableDictionary *entry = [[_editingPlacements objectForKey:BulkLiteratureArray] objectAtIndex:row];
			p = [[[PublicationView alloc] initWithFrame:_rect 
										    publication: [entry objectForKey:BulkLiteratureArrayName]
												   year: [[entry objectForKey:BulkLiteratureArrayYear] intValue]
											      month: [[entry objectForKey:BulkLiteratureArrayMonth] intValue]
												    day: [[entry objectForKey:BulkLiteratureArrayDay] intValue]
											  showCount: YES
												 number: [[entry objectForKey:BulkLiteratureArrayCount] intValue]] autorelease];
		}
		
		
		// setup the callbacks for save or cancel
		[p setCancelAction: @selector(publicationCancelAction:) forObject:self];
		[p setSaveAction: @selector(publicationSaveAction:) forObject:self];
		[p setAutoresizingMask: kMainAreaResizeMask];
		[p setAutoresizesSubviews: YES];
		
		// transition from bottom up sliding ontop of the old view
		// first refcount us so that when we are not the main UIView
		// we dont get deleted prematurely
		[self retain];
		[[App getInstance] transition:1 fromView:self toView:p];
		return;
	}
}

-(BOOL)table:(UITable*)table canDeleteRow:(int)row
{
    VERBOSE(NSLog(@"LiteraturePlacementView table: canDeleteRow: %d", row);)
	// can only delete placed literature
	if(row < 3 || row == 3 + [[_editingPlacements objectForKey:BulkLiteratureArray] count]) // 3
		return(NO);
	else
		return(YES);
}

-(BOOL)table:(UITable*)table canInsertAtRow:(int)row
{
    VERBOSE(NSLog(@"LiteraturePlacementView table: canInsertAtRow: %d", row);)

	if(row == 3 + [[_editingPlacements objectForKey:BulkLiteratureArray] count])
		return(YES);
	else
		return(NO);
}

-(void)table:(UITable*)table deleteRow:(int)row
{
    DEBUG(NSLog(@"LiteraturePlacementView table: deleteRow:%d", row);)
	
	// cant insert/delete the group title
	[[_editingPlacements objectForKey:BulkLiteratureArray] removeObjectAtIndex:(row - 3)];
	[_table animateDeletionOfCellAtRow:row column:0 viaEdge:1];
}



- (void)setCancelAction: (SEL)aSelector forObject:(NSObject *)obj
{
	VERY_VERBOSE(NSLog(@"LiteraturePlacementView setSaveAction: %s", aSelector);)
    _cancelObject = obj;
    _cancelSelector = aSelector;
}

- (void)setSaveAction: (SEL)aSelector forObject:(NSObject *)obj
{
	VERY_VERBOSE(NSLog(@"LiteraturePlacementView setSaveAction: %s", aSelector);)
    _saveObject = obj;
    _saveSelector = aSelector;
}






/******************************************************************
 *
 *   DEBUGGING UTILITIES
 *
 ******************************************************************/
			
- (BOOL)respondsToSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"LiteraturePlacementView respondsToSelector: %s", selector);)
	return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"LiteraturePlacementView methodSignatureForSelector: %s", selector);)
	return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
	VERY_VERBOSE(NSLog(@"LiteraturePlacementView forwardInvocation: %s", [invocation selector]);)
	[super forwardInvocation:invocation];
}


@end

