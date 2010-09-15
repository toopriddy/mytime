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
#import "CallViewControllerDelegate.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "CoreLocation/CoreLocation.h"

@interface CallViewController : GenericTableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, CLLocationManagerDelegate> 
{
	BOOL _initialView;
	BOOL deleteCall;
	
    UITextField *_name;

    NSMutableDictionary *_call;
	
	NSIndexPath *currentIndexPath;
	
	BOOL _showAddReturnVisit;
	BOOL _showDeleteButton;
	BOOL _newCall;
	BOOL _shouldReloadAll;
	
	BOOL _actionSheetSource;
	BOOL delayedAddReturnVisit;
	
	int _selectedRow;
	int _setFirstResponderGroup;

	id<CallViewControllerDelegate> delegate;
}
@property (nonatomic, retain) NSMutableDictionary *call;
@property (nonatomic, assign) id<CallViewControllerDelegate> delegate;
@property (nonatomic, retain) NSIndexPath *currentIndexPath;
@property (nonatomic, assign) BOOL delayedAddReturnVisit;
@property (nonatomic, retain) CLLocationManager *locationManager;

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


