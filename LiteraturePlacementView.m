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
	
	[super dealloc];
}


- (id) initWithFrame: (CGRect)rect placements:(NSMutableDictionary *)placements
{
    if((self = [super initWithFrame: rect])) 
    {
        DEBUG(NSLog(@"LiteraturePlacementView initWithFrame:");)
		
		_editingPlacements = [[NSMutableDictionary alloc] initWithDictionary:placements];
		NSMutableArray *entries = [[NSMutableArray alloc] initWithArray:[placements objectForKey:BulkLiteratureArray]];
		[placements setObject:entries forKey:BulkLiteratureArray];
		[entries release];
		
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
		[_navigationBar showLeftButton:nil withStyle:0 rightButton:@"+" withStyle:3];
		_table = [[LiteraturePlacementTable alloc] initWithFrame: CGRectMake(0, s.height, rect.size.width, rect.size.height - s.height) 
		                                           entries:entries];
		
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

- (void)unselectRow
{
	DEBUG(NSLog(@"unselectRow");)
	// unselect the row
	[_table selectRow:-1 byExtendingSelection:NO withFade:YES];
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
    VERBOSE(NSLog(@"_editingPublication was = %@", publication);)
	PublicationPicker *picker = [publicationView publicationPicker];
	
    [publication setObject:[picker publication] forKey:BulkLiteratureArrayName];
    [publication setObject:[picker publicationTitle] forKey:BulkLiteratureArrayTitle];
    [publication setObject:[picker publicationType] forKey:BulkLiteratureArrayType];
    [publication setObject:[[[NSNumber alloc] initWithInt:[picker year]] autorelease] forKey:BulkLiteratureArrayYear];
    [publication setObject:[[[NSNumber alloc] initWithInt:[picker month]] autorelease] forKey:BulkLiteratureArrayMonth];
    [publication setObject:[[[NSNumber alloc] initWithInt:[picker day]] autorelease] forKey:BulkLiteratureArrayDay];
    [publication setObject:[[[NSNumber alloc] initWithInt:[publicationView count]] autorelease] forKey:BulkLiteratureArrayCount];

    VERBOSE(NSLog(@"_editingPublication is = %@", _editingPublication);)
	
    [_table setKeyboardVisible:NO animated:NO];
	[_table reloadData];
    [[App getInstance] transition:2 fromView:publicationView toView:self];
	
	// have the row unselect after the transition back to the LiteraturePlacementView so that the user
	// knows where they were and what they clicked on 
	[self performSelector: @selector(unselectRow) 
			   withObject:self
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
    VERBOSE(NSLog(@"navigationBar: buttonClicked:%s", button ? "cancel" : "save");)
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

	NSMutableArray *publications = [entry objectForKey:BulkLiteratureArray;
	int i;
	int count = [publications count];
	int number  0;
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
		rowCount = [[info objectForKey:LiteraturePlacementViewSelectedInvocations] count];
		for(i = 0; i < rowCount; ++i)
		{
			if(row == 0)
			{
				DEBUG(NSLog(@"calling invoking handler");)
				[[[info objectForKey:LiteraturePlacementViewSelectedInvocations] objectAtIndex:i] invoke];
				return;
			}
			--row;
		}
	}
	
}

-(BOOL)table:(UITable*)table canDeleteRow:(int)row
{
    VERBOSE(NSLog(@"table: canInsertAtRow: %d", row);)
	//row 0 space
	// row 1 set date
	//row 2 space
	
	// cant insert/delete the group title
	if(row < 3)
		return(NO);
	row -= 2;
	
	return(row < [_entries count]);
}

-(BOOL)table:(UITable*)table canInsertAtRow:(int)row
{
    VERBOSE(NSLog(@"table: canInsertAtRow: %d", row);)
	//row 0 space
	// row 1 set date
	//row 2 space
	
	// cant insert/delete the group title
	if(row < 3)
		return(NO);
	row -= 2;
	
	return(row >= [_entries count]);
}

-(void)table:(UITable*)table deleteRow:(int)row
{
    DEBUG(NSLog(@"table: deleteRow:%d", row);)
	//row 0 space
	// row 1 set date
	//row 2 space
	
	// cant insert/delete the group title
	if(row < 3)
		return(NO);
	row -= 2;
	
	return(row >= [_entries count]);
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

