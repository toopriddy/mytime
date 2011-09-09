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
#import "MTCall.h"

@interface CallViewController : GenericTableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, CLLocationManagerDelegate, UITextFieldDelegate> 
{
	BOOL _initialView;
	BOOL deleteCall;
	
    UITextField *_name;

    MTCall *_call;
	
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
@property (nonatomic, retain) MTCall *call;
@property (nonatomic, assign) id<CallViewControllerDelegate> delegate;
@property (nonatomic, retain) NSIndexPath *currentIndexPath;
@property (nonatomic, assign) BOOL delayedAddReturnVisit;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableSet *allTextFields;

/**
 * initialize this view with a watchtower at the current month/year
 *
 * @param rect - the rect
 * @returns self
 */
- (id)initWithCall:(MTCall *)call newCall:(BOOL)newCall;
- (void)dealloc;
- (void)save;

@end


