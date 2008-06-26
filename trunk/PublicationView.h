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
#import <UIKit/UIPickerView.h>
#import "PublicationPicker.h"
#import "NumberedPicker.h"

@interface PublicationView : UIView {
    PublicationPicker *_picker;
	NumberedPicker *_countPicker;
	
    NSObject *_saveObject;
    SEL _saveSelector;
    
    NSObject *_cancelObject;
    SEL _cancelSelector;
}

/**
 * get the publiction picker 
 */
- (PublicationPicker *)publicationPicker;

- (int)count;



/**
 * initialize this view with a watchtower at the current month/year
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithFrame: (CGRect)rect;
- (id) initWithFrame: (CGRect)rect showCount:(BOOL)showCount;

/**
 * initialize this view given the curent configuration
 *
 * @param rect - the rect
 * @param publication - NSString of the publication
 * @param year - the year of our common era
 * @param month - the month where 0 = Jan
 * @param day - the day of the month for a watchtower or awake
 * @param showCount - show a picker for the number of publications placed
 * @returns self
 */
- (id) initWithFrame: (CGRect)rect publication: (NSString *)publication year: (int)year month: (int)month day: (int)day showCount:(BOOL)showCount number:(int)_number;
- (id) initWithFrame: (CGRect)rect publication: (NSString *)publication year: (int)year month: (int)month day: (int)day;


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

@end

