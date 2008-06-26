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
#import "PublicationView.h"
#import "DatePickerView.h"

@interface LiteraturePlacementTable : UIPreferencesTable {
	NSMutableArray *_entries;
	CGPoint _offset;
}
- (id)initWithFrame:(CGRect) rect entries:(NSMutableArray*) timeEntries;
- (int)swipe:(int)direction withEvent:(struct __GSEvent *)event;



@end


@interface LiteraturePlacementView : UIView {
    CGRect _rect;
    LiteraturePlacementTable *_table;
	UINavigationBar *_navigationBar;
	
	NSMutableDictionary *_editingPlacements;
	int _editingPublication;

    NSObject *_saveObject;
    SEL _saveSelector;
    
    NSObject *_cancelObject;
    SEL _cancelSelector;
}

/**
 * initialize this view with a watchtower at the current month/year
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithFrame: (CGRect)rect;
- (id) initWithFrame: (CGRect)rect placements:(NSMutableDictionary *)placements;
- (void)dealloc;

/**
 * get the placements from this view
 * @return placements from this view
 */
- (NSMutableDictionary *)placements;
 
/**
 * setup a callback for clicking on the cancel button
 *
 * @param aSelector - the selector on obj to callback
 * @param obj - the object to callback using the passed in aSelector
 * @returns self
 */
- (void)setCancelAction: (SEL)aSelector forObject:(NSObject *)obj;

/**
 * setup a callback for clicking on the save button
 *
 * @param aSelector - the selector on obj to callback
 * @param obj - the object to callback using the passed in aSelector
 * @returns self
 */
- (void)setSaveAction: (SEL)aSelector forObject:(NSObject *)obj;


- (void)changeDateCancelAction: (DatePickerView *)view;
- (void)changeDateSaveAction: (DatePickerView *)view;

- (void)publicationCancelAction: (PublicationView *)view;
- (void)publicationSaveAction: (PublicationView *)view;


- (void)navigationBar:(UINavigationBar*)nav buttonClicked:(int)button;

@end