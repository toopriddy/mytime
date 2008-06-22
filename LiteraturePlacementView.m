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

@implementation LiteraturePlacementTable

- (id)initWithFrame:(CGRect) rect entries:(NSMutableArray*) timeEntries;
{
    if((self = [super initWithFrame: rect])) 
    {
		DEBUG(NSLog(@"TimeTable: initWithFrame");)
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
	VERY_VERBOSE(NSLog(@"TimeTable respondsToSelector: %s", selector);)
	return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	VERY_VERBOSE(NSLog(@"TimeTable methodSignatureForSelector: %s", selector);)
	return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
	VERY_VERBOSE(NSLog(@"TimeTable forwardInvocation: %s", [invocation selector]);)
	[super forwardInvocation:invocation];
}
@end





@implementation LiteraturePlacementView

static int sortByDate(id v1, id v2, void *context)
{
	// ok, we need to compare the dates of the calls since we have
	// at least one call for each of 
	NSDate *date1 = [v1 objectForKey:LiteraturePlacementDate];
	NSDate *date2 = [v2 objectForKey:LiteraturePlacementDate];
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
		NSLog(@"Comparing %d to %d", now, [[_entries objectAtIndex:i] objectForKey:LiteraturePlacementDate]);
		if([now compare:[[_entries objectAtIndex:i] objectForKey:LiteraturePlacementDate]] > 0)
		{
			[_entries removeObjectAtIndex:i];
			--i;
			count = [_entries count];
		}
	}
	
	[_table reloadData];
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
        DEBUG(NSLog(@"LiteraturePlacementView initWithFrame:");)
		
		_entries = [[NSMutableArray alloc] initWithArray:[settings objectForKey:SettingsLiteraturePlacements]];
		[settings setObject:_entries forKey:SettingsLiteraturePlacements];
		
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
		[_navigationBar pushNavigationItem: [[[UINavigationItem alloc] initWithTitle:@"Anonymous Placements"] autorelease] ];
		[_navigationBar showLeftButton:nil withStyle:0 rightButton:"+" withStyle:3];
		_table = [[LiteraturePlacementTable alloc] initWithFrame: CGRectMake(0, s.height, rect.size.width, rect.size.height - s.height) 
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

- (void)addNewPublicationCancelAction: (PublicationView *)publicationView
{
    DEBUG(NSLog(@"CallView addNewPublicationCancelAction:");)
    [[App getInstance] transition:2 fromView:publicationView toView:self];
    [_table setKeyboardVisible:NO animated:NO];

	if(_selectedRow)
	// have the row unselect after the transition back to the CallView so that the user
	// knows where they were and what they clicked on 
	[self performSelector: @selector(unselectRow) 
			   withObject:_name
			   afterDelay:.2];
	
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
	PublicationPicker *picker = [publicationView publicationPicker];
    [_editingPublication setObject:[picker publication] forKey:CallReturnVisitPublicationName];
    [_editingPublication setObject:[picker publicationTitle] forKey:CallReturnVisitPublicationTitle];
    [_editingPublication setObject:[picker publicationType] forKey:CallReturnVisitPublicationType];
    [_editingPublication setObject:[[[NSNumber alloc] initWithInt:[picker year]] autorelease] forKey:CallReturnVisitPublicationYear];
    [_editingPublication setObject:[[[NSNumber alloc] initWithInt:[picker month]] autorelease] forKey:CallReturnVisitPublicationMonth];
    [_editingPublication setObject:[[[NSNumber alloc] initWithInt:[picker day]] autorelease] forKey:CallReturnVisitPublicationDay];
    VERBOSE(NSLog(@"_editingPublication is = %@", _editingPublication);)
	
    [_table setKeyboardVisible:NO animated:NO];
	[self reloadData];
    [[App getInstance] transition:2 fromView:publicationView toView:self];
	
	// have the row unselect after the transition back to the CallView so that the user
	// knows where they were and what they clicked on 
	[self performSelector: @selector(unselectRow) 
			   withObject:_name
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
	DEBUG(NSLog(@"navigationBar: buttonClicked:%s", button == 0? "Start/Stop time" : "Add Time");)
	
	switch(button)
	{
		case 0: // Add literature
		{
			[self retain];
			BulkLiteraturePlacementView *p = [[[BulkLiteraturePlacementView alloc] initWithFrame:_rect] autorelease];
			
			// setup the callbacks for save or cancel
			[p setCancelAction: @selector(addPlacementCancelAction:) forObject:self];
			[p setSaveAction: @selector(addPlacementSaveAction:) forObject:self];
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
    DEBUG(NSLog(@"numberOfRowsInTable:");)
	int count = [_entries count];
    DEBUG(NSLog(@"numberOfRowsInTable: %d", count);)
	return(count);
}

- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(UITableColumn *)column
{
    DEBUG(NSLog(@"table: cellForRow: %d", row);)
	id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
	
	[cell setShowSelection:NO];
	
	NSMutableDictionary *entry = [_entries objectAtIndex:row];
	
	NSNumber *time = [entry objectForKey:SettingsTimeEntryMinutes];
	
	NSCalendarDate *date = [[[NSCalendarDate alloc] initWithTimeIntervalSinceReferenceDate:[[entry objectForKey:SettingsTimeEntryDate] timeIntervalSinceReferenceDate]] autorelease];	
	[cell setTitle:[date descriptionWithCalendarFormat:@"%a %b %d"]];
	
	CGSize s = CGSizeMake( [column width], [table rowHeight] );
	UITextLabel* label = [[[UITextLabel alloc] initWithFrame: CGRectMake(150,0,s.width,s.height)] autorelease];
	float bgColor[] = { 0,0,0,0 };
	[label setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	
	int minutes = [time intValue];
	int hours = minutes / 60;
	minutes %= 60;
	if(hours && minutes)
		[label setText:[NSString stringWithFormat:@"%d %s %d %s", hours, hours == 1 ? "hour" : "hours", minutes, minutes == 1 ? "minute" : "minutes"]];
	else if(hours)
		[label setText:[NSString stringWithFormat:@"%d %s", hours, hours == 1 ? "hour" : "hours"]];
	else if(minutes)
		[label setText:[NSString stringWithFormat:@"%d %s", minutes, minutes == 1 ? "minute" : "minutes"]];
	
	[cell addSubview: label];
	
	return cell;
}

-(BOOL)table:(UITable*)table deleteRow:(int)row
{
    DEBUG(NSLog(@"table: deleteRow: %d", row);)
	[_entries removeObjectAtIndex:row];
	[[App getInstance] saveData];
	
}

-(BOOL)table:(UITable*)table showDisclosureForRow:(int)row
{
    DEBUG(NSLog(@"table: showDisclosureForRow");)
    return(NO);
}

-(BOOL)table:(UITable*)table canDeleteRow:(int)row
{
    DEBUG(NSLog(@"table: canDeleteRow");)
	return YES;
}

-(void)table:(UITable*)table movedRow:(int)fromRow toRow:(int)toRow
{
    DEBUG(NSLog(@"table: movedRow");)
}


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

