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
#import "AddressView.h"
#import "PublicationView.h"

@interface CallView : UIView {
    UINavigationBar *_navigationBar;
    CGRect _rect;
    UIPreferencesTable *_table;

    NSObject *_deleteObject;
    SEL _deleteSelector;
    
    NSObject *_saveObject;
    SEL _saveSelector;
    
    NSObject *_cancelObject;
    SEL _cancelSelector;

	UIPreferencesTableCell *_addressCell;
    UIPreferencesTextTableCell *_name;

    NSMutableDictionary *_call;
	NSMutableArray *_returnVisitNotes;
	
	NSMutableArray *_displayInformation;
	NSMutableArray *_lastDisplayInformation;
	NSMutableDictionary *_currentGroup;
	
	BOOL _showAddCall;
	BOOL _showDeleteButton;
	BOOL _newCall;
	BOOL _editing;
	BOOL _shouldReloadAll;
	
	int _selectedRow;
	int _setFirstResponderGroup;

    // this will be set to the publication that we are changing
    // or nil when we are adding a publication
    NSMutableDictionary *_editingPublication;
    // this will be set to the particular returnvisit that we are modifying
    NSMutableDictionary *_editingReturnVisit;
}

/**
 * @returns the call we are editing
 */
- (NSMutableDictionary *)call;

/**
 * @returns the call's name
 */
- (NSString *)name;

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
 * initialize this view with a watchtower at the current month/year
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithFrame: (CGRect)rect call:(NSMutableDictionary *)call;
- (id) initWithFrame: (CGRect)rect;
- (void)dealloc;

/**
 * setup a callback for clicking on the delete button
 *
 * @param aSelector - the selector on obj to callback
 * @param obj - the object to callback using the passed in aSelector
 * @returns self
 */
- (void)setDeleteAction: (SEL)aSelector forObject:(NSObject *)obj;

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


- (void)addNewPublicationCancelAction: (PublicationView *)publicationView;
- (void)addNewPublicationSaveAction: (PublicationView *)publicationView;

- (void)editAddressCancelAction: (AddressView *)publicationView;
- (void)editAddressSaveAction: (AddressView *)publicationView;

// used to build and save the notes fields
- (void)saveReturnVisitsNotes;

- (void)setBounds:(CGRect)rect;

// dont use this
- (void)reloadData;


- (void)setFocus:(UIPreferencesTextTableCell *)cell;

// navigation bar callback functions
- (void)navigationBar:(UINavigationBar*)nav buttonClicked:(int)button;

- (int)numberOfGroupsInPreferencesTable:(UIPreferencesTable *)aTable;
- (int)preferencesTable:(UIPreferencesTable *)aTable
  numberOfRowsInGroup:(int)group;
- (UIPreferencesTableCell *)preferencesTable:(UIPreferencesTable *)aTable 
                              cellForGroup:(int)group;
- (float)preferencesTable:(UIPreferencesTable *)aTable 
           heightForRow:(int)row 
                 inGroup:(int)group 
    withProposedHeight:(float)proposed;
- (BOOL)preferencesTable:(UIPreferencesTable *)aTable 
    isLabelGroup:(int)group;
- (UIPreferencesTableCell *)preferencesTable:(UIPreferencesTable *)aTable 
    cellForRow:(int)row 
    inGroup:(int)group;


@end


