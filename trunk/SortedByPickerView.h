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
#import <UIKit/UIDatePicker.h>
#import "MainView.h"

#define SortByStreet @"Sort by Street"
#define SortByDate   @"Sort by Date"

typedef struct {
	NSString * const name;
	SelectedButtonBarView const value;
} ViewEntry;

extern ViewEntry VIEWS[];


@interface SortedByPickerView : UIView {
    UIPickerView *_picker;
    
    NSObject *_saveObject;
    SEL _saveSelector;
    
    NSObject *_cancelObject;
    SEL _cancelSelector;

	int _entry;
}

// initialize this view given the curent configuration
- (id) initWithFrame: (CGRect)rect value: (NSString *)value title: (NSString *)title;

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

- (NSString *)value;
@end