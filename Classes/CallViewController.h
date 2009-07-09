//
//  CallViewController.h
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <UIKit/UIKit.h>
#import "GenericTableViewController.h"
#import "UITableViewTextFieldCell.h"
#import "AddressViewController.h"
#import "AddressViewControllerDelegate.h"
#import "PublicationViewControllerDelegate.h"
#import "PublicationTypeViewController.h"
#import "CallViewControllerDelegate.h"
#import "DatePickerViewControllerDelegate.h"
#import "UITableViewTextFieldCellDelegate.h"
#import "NotesViewControllerDelegate.h"
#import "ReturnVisitTypeViewController.h"
#import "MetadataViewController.h"
#import "MetadataEditorViewController.h"
#import "LocationPickerViewController.h"
#import "SelectPositionMapViewController.h"
#import "GeocacheViewController.h"

@interface CallViewController : GenericTableViewController <UIActionSheetDelegate> 
{
	BOOL _initialView;
	
    UITextField *_name;

    NSMutableDictionary *_call;
	
	NSIndexPath *currentIndexPath;
	
	BOOL _showAddReturnVisit;
	BOOL _showDeleteButton;
	BOOL _newCall;
	BOOL _shouldReloadAll;
	
	BOOL _actionSheetSource;
	
	int _selectedRow;
	int _setFirstResponderGroup;

	id<CallViewControllerDelegate> delegate;
}
@property (nonatomic, assign) id<CallViewControllerDelegate> delegate;
@property (nonatomic, retain) NSIndexPath *currentIndexPath;

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
- (id) initWithCall:(NSMutableDictionary *)call;
- (id) init;
- (void)dealloc;

- (void)save;

- (GenericTableViewSectionController *)genericTableViewSectionControllerForReturnVisit:(NSMutableDictionary *)returnVisit;

@end


