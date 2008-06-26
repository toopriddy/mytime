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
#import "BulkLiteraturePlacementView.h"
#import "App.h"
#import "TimePickerView.h"

@implementation BulkLiteraturePlacementTable

- (id)initWithFrame:(CGRect) rect entries:(NSMutableArray*) timeEntries;
{
    if((self = [super initWithFrame: rect])) 
    {
		DEBUG(NSLog(@"BulkLiteraturePlacementTable: initWithFrame");)
		_entries = timeEntries;
		_offset = rect.origin;
		[self setSeparatorStyle: 1];
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
	VERY_VERBOSE(NSLog(@"BulkLiteraturePlacementTable respondsToSelector: %s", selector);)
	return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"BulkLiteraturePlacementTable methodSignatureForSelector: %s", selector);)
	return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
	VERY_VERBOSE(NSLog(@"BulkLiteraturePlacementTable forwardInvocation: %s", [invocation selector]);)
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
extern NSString const * const SettingsBulkLiterature;
extern NSString const * const BulkLiteratureDate;
extern NSString const * const BulkLiteratureArray;
extern NSString const * const BulkLiteratureArrayCount;
extern NSString const * const BulkLiteratureArrayTitle;
extern NSString const * const BulkLiteratureArrayName;
extern NSString const * const BulkLiteratureArrayYear;
extern NSString const * const BulkLiteratureArrayMonth;
extern NSString const * const BulkLiteratureArrayDay;
 */





@implementation BulkLiteraturePlacementView

static int sortByDate(id v1, id v2, void *context)
{
	// ok, we need to compare the dates of the calls since we have
	// at least one call for each of 
	NSDate *date1 = [v1 objectForKey:BulkLiteratureDate];
	NSDate *date2 = [v2 objectForKey:BulkLiteratureDate];
	return(-[date1 compare:date2]);
}


// sort the time entries and remove the 3 month old entries
- (void)sort
{
	int i;
	NSArray *sortedArray = [_entries sortedArrayUsingFunction:sortByDate context:NULL];
	[sortedArray retain];
	[_entries setArray:sortedArray];
	[sortedArray release];
	
	// remove all entries that are older than 3 months
	NSCalendarDate *now = [[NSCalendarDate calendarDate] dateByAddingYears:0 months:-3 days:0 hours:0 minutes:0 seconds:0];
	int count = [_entries count];
	for(i = 0; i < count; ++i)
	{
		NSLog(@"Comparing %d to %d", now, [[_entries objectAtIndex:i] objectForKey:BulkLiteratureDate]);
		if([now compare:[[_entries objectAtIndex:i] objectForKey:BulkLiteratureDate]] > 0)
		{
			[_entries removeObjectAtIndex:i];
			--i;
			count = [_entries count];
		}
	}
	
	[_table reloadData];
}

- (void)save
{
	// save the data
	[[App getInstance] saveData];
}

- (void)unselectRow
{
	DEBUG(NSLog(@"unselectRow");)
	// unselect the row
	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
}


- (void)dealloc
{
	[_table release];
	
	[super dealloc];
}


- (id) initWithFrame: (CGRect)rect settings:(NSMutableDictionary *) settings
{
    if((self = [super initWithFrame: rect])) 
    {
        DEBUG(NSLog(@"BulkLiteraturePlacementView initWithFrame:");)
		
		_entries = [[NSMutableArray alloc] initWithArray:[settings objectForKey:SettingsBulkLiterature]];
		[settings setObject:_entries forKey:SettingsBulkLiterature];
		_selectedRow = -1;

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
		[_navigationBar pushNavigationItem: [[[UINavigationItem alloc] initWithTitle:@"Bulk Placements"] autorelease] ];
		[_navigationBar showLeftButton:nil withStyle:0 rightButton:@"+" withStyle:3];
		_table = [[BulkLiteraturePlacementTable alloc] initWithFrame: CGRectMake(0, s.height, rect.size.width, rect.size.height - s.height) 
		                                           entries:_entries];
		
		[_table addTableColumn: [[[UITableColumn alloc] initWithTitle:@"Times" identifier:nil width: rect.size.width] autorelease]];
        [_table setDelegate: self];
        [_table setDataSource: self];
		[_table setAutoresizingMask: kMainAreaResizeMask];
		[_table setAutoresizesSubviews: YES];
        [self addSubview: _table];
		[_table reloadData];
    }
    
    return(self);
}

/******************************************************************
 *
 *   PUBLICATION VIEW CALLBACKS
 *
 ******************************************************************/
- (void)entryCancelAction:(LiteraturePlacementView *)view
{
    DEBUG(NSLog(@"BulkLiteraturePlacementView addNewPublicationCancelAction:");)
	int transition = _selectedRow == -1 ? 9 : 2;
	[[App getInstance] transition:transition fromView:view toView:[[App getInstance] mainView]];
	
	// have the row unselect after the transition back to the CallView so that the user
	// knows where they were and what they clicked on 
	[self performSelector: @selector(unselectRow) 
			   withObject:_table
			   afterDelay:.2];
	
    // release the refcount on ourselves since we are now the main UIView
    [self release];
}

- (void)entrySaveAction: (LiteraturePlacementView *)view
{
    DEBUG(NSLog(@"BulkLiteraturePlacementView addNewPublicationSaveAction:");)
    
    if(_selectedRow == -1)
    {
        VERBOSE(NSLog(@"creating a new publication entry and adding it");)
        // if we are adding a publication then create the NSDictionary and add it to the end
        // of the publications array
        [_entries addObject:[view placements]];
    }
	else
	{
		[_entries replaceObjectAtIndex:_selectedRow withObject:[view placements]];
	}

	[_table reloadData];
	int transition = _selectedRow == -1 ? 9 : 2;
	[[App getInstance] transition:transition fromView:view toView:[[App getInstance] mainView]];
	
	// have the row unselect after the transition back to the View so that the user
	// knows where they were and what they clicked on 
	[self performSelector: @selector(unselectRow) 
			   withObject:_table
			   afterDelay:.2];
	
    // release the refcount on ourselves since we are now the main UIView
    [self release];
	
	// save the data
	[self save];
}

/******************************************************************
 *
 *   NAVIGATION BAR
 *   1 left button                                0 right button
 ******************************************************************/
- (void)navigationBar:(UINavigationBar*)nav buttonClicked:(int)button
{
	DEBUG(NSLog(@"BulkLiteraturePlacementView navigationBar: buttonClicked");)
	
	switch(button)
	{
		case 0: // Add literature
		{
			[self retain];
			_selectedRow = -1;
			LiteraturePlacementView *p = [[[LiteraturePlacementView alloc] initWithFrame:_rect] autorelease];
			
			// setup the callbacks for save or cancel
			[p setCancelAction: @selector(entryCancelAction:) forObject:self];
			[p setSaveAction: @selector(entrySaveAction:) forObject:self];
			[p setAutoresizingMask: kMainAreaResizeMask];
			[p setAutoresizesSubviews: YES];
			
			// transition from bottom up sliding ontop of the old view
			[[App getInstance] transition:8 fromView:[[App getInstance] mainView] toView:p];
			break;
		}
	}
}

/******************************************************************
 *
 *   TABLE DELEGATE FUNCTIONS
 *
 ******************************************************************/

- (int)numberOfRowsInTable:(UITable*)table
{
    DEBUG(NSLog(@"BulkLiteraturePlacementView numberOfRowsInTable:");)
	int count = [_entries count];
    DEBUG(NSLog(@"BulkLiteraturePlacementView numberOfRowsInTable: %d", count);)
	return(count);
}

- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(UITableColumn *)column
{
    DEBUG(NSLog(@"BulkLiteraturePlacementView table: cellForRow: %d", row);)
	id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
	
	[cell setShowSelection:YES];
	
	NSMutableDictionary *entry = [_entries objectAtIndex:row];

	
	NSCalendarDate *date = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[[entry objectForKey:BulkLiteratureDate] timeIntervalSinceReferenceDate]] autorelease];	
	[cell setTitle:[date descriptionWithCalendarFormat:@"%a %b %d"]];

	NSMutableArray *publications = [entry objectForKey:BulkLiteratureArray];
	int i;
	int count = [publications count];
	int number = 0;
	for(i = 0; i < count; ++i)
	{
		number += [[[publications objectAtIndex:i] objectForKey:BulkLiteratureArrayCount] intValue];
	}
	CGSize s = CGSizeMake( [column width], [table rowHeight] );
	UITextLabel* label = [[[UITextLabel alloc] initWithFrame: CGRectMake(150,0,s.width,s.height)] autorelease];
	float bgColor[] = { 0,0,0,0 };
	[label setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	
	[label setText:[NSString stringWithFormat:@"%d publications", number]];
	
	[cell addSubview: label];
	
	return cell;
}


- (void)tableRowSelected:(NSNotification*)notification
{
    int row = [[notification object] selectedRow];
    DEBUG(NSLog(@"BulkLiteraturePlacementView tableRowSelected: tableRowSelected row=%@ row%d", notification, row);)
	_selectedRow = row;

	if(row < 0 || row >= [_entries count])
		return;
	
	[self retain];
	LiteraturePlacementView *p = [[[LiteraturePlacementView alloc] initWithFrame:_rect placements:[_entries objectAtIndex:_selectedRow]] autorelease];
	
	// setup the callbacks for save or cancel
	[p setCancelAction: @selector(entryCancelAction:) forObject:self];
	[p setSaveAction: @selector(entrySaveAction:) forObject:self];
	[p setAutoresizingMask: kMainAreaResizeMask];
	[p setAutoresizesSubviews: YES];

	// transition to the right
	[[App getInstance] transition:1 fromView:[[App getInstance] mainView] toView:p];
}

-(BOOL)table:(UITable*)table canDeleteRow:(int)row
{
    VERBOSE(NSLog(@"BulkLiteraturePlacementView table: canInsertAtRow: %d", row);)
	return(YES);
}

-(BOOL)table:(UITable*)table canInsertAtRow:(int)row
{
    VERBOSE(NSLog(@"BulkLiteraturePlacementView table: canInsertAtRow: %d", row);)
	return(NO);
}

-(void)table:(UITable*)table deleteRow:(int)row
{
    DEBUG(NSLog(@"table: deleteRow:%d", row);)
	[_entries removeObjectAtIndex:row];
	[self save];
}


-(BOOL)table:(UITable*)table showDisclosureForRow:(int)row
{
    DEBUG(NSLog(@"table: showDisclosureForRow");)
    return(YES);
}

- (BOOL)respondsToSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"BulkLiteraturePlacementView respondsToSelector: %s", selector);)
	return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"BulkLiteraturePlacementView methodSignatureForSelector: %s", selector);)
	return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
	VERY_VERBOSE(NSLog(@"BulkLiteraturePlacementView forwardInvocation: %s", [invocation selector]);)
	[super forwardInvocation:invocation];
}


@end

