//
//  NotAtHomeTerritoryDetailViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "GenericTableViewController.h"
#import <AddressBook/AddressBook.h>

@class NotAtHomeTerritoryViewController;

@protocol NotAtHomeTerritoryViewControllerDelegate
- (void)notAtHomeTerritoryViewControllerDone:(NotAtHomeTerritoryViewController *)notAtHomeTerritoryViewController;
@end

@interface NotAtHomeTerritoryViewController : GenericTableViewController 
{
@private	
	ABAddressBookRef addressBook;
	
	NSMutableArray *allTextFields;
	NSMutableDictionary *territory;
	id<NotAtHomeTerritoryViewControllerDelegate> delegate;
	UITextField *owner;
	int tag;
	BOOL newTerritory;
	BOOL obtainFocus;
}
@property (nonatomic, assign) BOOL obtainFocus;
@property (nonatomic, readonly) BOOL newTerritory;
@property (nonatomic, assign) int tag;
@property (nonatomic, retain) NSMutableArray *allTextFields;
@property (nonatomic, retain) UITextField *owner;
@property (nonatomic, retain) NSMutableDictionary *territory;
@property (nonatomic, assign) id<NotAtHomeTerritoryViewControllerDelegate> delegate;

- (id)initWithTerritory:(NSMutableDictionary *)theTerritory;

- (NSString *)ownerEmailAddress;

@end
