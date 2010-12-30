//
//  NotAtHomeTerritoryDetailViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "GenericTableViewController.h"
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "MTTerritory.h"

@class NotAtHomeTerritoryViewController;

@protocol NotAtHomeTerritoryViewControllerDelegate
- (void)notAtHomeTerritoryViewControllerDone:(NotAtHomeTerritoryViewController *)notAtHomeTerritoryViewController;
@end

@interface NotAtHomeTerritoryViewController : GenericTableViewController <UIActionSheetDelegate,
																		  MFMailComposeViewControllerDelegate>
{
@private	
	ABAddressBookRef addressBook;
	
	NSMutableArray *allTextFields;
	MTTerritory *territory;
	id<NotAtHomeTerritoryViewControllerDelegate> delegate;
	UITextField *owner;
	int tag;
	BOOL obtainFocus;
	BOOL deleteAfterEmailing;
}
@property (nonatomic, assign) BOOL obtainFocus;
@property (nonatomic, assign) int tag;
@property (nonatomic, retain) NSMutableArray *allTextFields;
@property (nonatomic, retain) UITextField *owner;
@property (nonatomic, retain) MTTerritory *territory;
@property (nonatomic, assign) id<NotAtHomeTerritoryViewControllerDelegate> delegate;

- (id)initWithTerritory:(MTTerritory *)theTerritory;
- (id)initWithTerritory:(MTTerritory *)theTerritory newTerritory:(BOOL)newTerritory;

- (NSString *)ownerEmailAddress;

@end
