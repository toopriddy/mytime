//
//  MyTime
//
//  Created by Brent Priddy on 12/29/07.
//  Copyright 2007 PG Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIPreferencesTable.h>
#import "LiteraturePlacementView.h"

@interface BulkLiteraturePlacementTable : UITable {
	NSMutableArray *_entries;
	CGPoint _offset;
}
- (id)initWithFrame:(CGRect) rect entries:(NSMutableArray*) timeEntries;
- (int)swipe:(int)direction withEvent:(struct __GSEvent *)event;



@end


@interface BulkLiteraturePlacementView : UIView {
    CGRect _rect;
    BulkLiteraturePlacementTable *_table;
	UINavigationBar *_navigationBar;
	
	NSMutableArray *_entries;
	int _selectedRow;
}

/**
 * initialize this view with a watchtower at the current month/year
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithFrame: (CGRect)rect settings:(NSMutableDictionary *) settings;
- (void)dealloc;

- (void)entryCancelAction: (LiteraturePlacementView *)view;
- (void)entrySaveAction: (LiteraturePlacementView *)view;

//datasource methods
- (int)numberOfRowsInTable:(UITable*)table;
- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(UITableColumn *)column;
- (BOOL)table:(UITable*)table canDeleteRow:(int)row;
-(BOOL)table:(UITable*)table showDisclosureForRow:(int)row;

- (void)navigationBar:(UINavigationBar*)nav buttonClicked:(int)button;

@end