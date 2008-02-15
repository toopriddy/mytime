//
//  SortedCallsView.h
//  MyTime
//
//  Created by Brent Priddy on 12/29/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UIPreferencesTable.h>
#import <GraphicsServices/GraphicsServices.h>


typedef enum {
	CALLS_SORTED_BY_STREET,
	CALLS_SORTED_BY_DATE,
} SortCallsType;

@interface SortedCallsView : UIView {
    UINavigationBar *_navigationBar;
    CGRect _rect;
    UISectionTable *_table;
	UISectionList *_section;
	UISectionIndex *_sectionIndex;
	
	SortCallsType _sortBy;
    int _selectedCall;
	
	CGPoint _tableOffset;

    NSMutableArray *_savedCalls;
    NSMutableArray *_calls;
	NSMutableArray *_streetSections;
	NSMutableArray *_streetOffsets;
}

- (id) initWithFrame: (CGRect)rect calls:(NSMutableArray *)calls sortBy:(SortCallsType) sortBy;

- (void)updateSections;

- (SortCallsType)sortBy;
- (void)setSortBy: (SortCallsType)sortBy;


// delegate methods for the UISelectorList
//- (int)numberOfRowsInTable:(UITable*)table;
//- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(UITableColumn *)column;
//- (BOOL)table:(UITable*)table canDeleteRow:(int)row;
//- (void)table:(UITable*)table deleteRow:(int)row;
//- (void)table:(UITable*)table movedRow:(int)fromRow toRow:(int)toRow;
//- (void)tableRowSelected:(NSNotification*)notification;

@end

