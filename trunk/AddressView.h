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
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UIPreferencesTable.h>

@interface AddressView : UIView {
    UINavigationBar *_navigationBar;
    CGRect _rect;
    UIPreferencesTable *_table;

    NSObject *_saveObject;
    SEL _saveSelector;
    
    NSObject *_cancelObject;
    SEL _cancelSelector;

	UIPreferencesTextTableCell *_streetNumber;
    UIPreferencesTextTableCell *_street;
    UIPreferencesTextTableCell *_city;
    UIPreferencesTextTableCell *_state;
}

/**
 * @returns the call's street number
 */
- (NSString *)streetNumber;

/**
 * @returns the call's street
 */
- (NSString *)street;    

/**
 * @returns the call's city
 */
- (NSString *)city;

/**
 * @returns the call's state
 */
- (NSString *)state;

/**
 * initialize this view 
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithFrame: (CGRect)rect;

/**
 * initialize this view with the address information
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithFrame: (CGRect)rect streetNumber:(NSString *)streetNumber street:(NSString *)street city:(NSString *)city state:(NSString *)state;


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


// navigation bar callback functions
- (void)navigationBar:(UINavigationBar*)nav buttonClicked:(int)button;

- (int)numberOfGroupsInPreferencesTable:(UIPreferencesTable *)aTable;
- (int)preferencesTable:(UIPreferencesTable *)aTable numberOfRowsInGroup:(int)group;
- (UIPreferencesTableCell *)preferencesTable:(UIPreferencesTable *)aTable cellForGroup:(int)group;
- (float)preferencesTable:(UIPreferencesTable *)aTable heightForRow:(int)row inGroup:(int)group withProposedHeight:(float)proposed;
- (BOOL)preferencesTable:(UIPreferencesTable *)aTable isLabelGroup:(int)group;
- (UIPreferencesTableCell *)preferencesTable:(UIPreferencesTable *)aTable cellForRow:(int)row inGroup:(int)group;


@end



