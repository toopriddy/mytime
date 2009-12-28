//
//  NotAtHomeTerritoryDetailViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "GenericTableViewController.h"
#import <AddressBook/AddressBook.h>

@class NotAtHomeTerritoryDetailViewController;

@protocol NotAtHomeTerritoryDetailViewControllerDelegate
- (void)notAtHomeTerritoryDetailViewControllerDone:(NotAtHomeTerritoryDetailViewController *)notAtHomeTerritoryDetailViewController;
@end

@interface NotAtHomeTerritoryDetailViewController : GenericTableViewController 
{
@private	
	ABAddressBookRef addressBook;
	
	NSMutableDictionary *territory;
	id<NotAtHomeTerritoryDetailViewControllerDelegate> delegate;
	UITextField *owner;
	int tag;
	BOOL newTerritory;
}
@property (nonatomic, readonly) BOOL newTerritory;
@property (nonatomic, assign) int tag;
@property (nonatomic, retain) UITextField *owner;
@property (nonatomic, retain) NSMutableDictionary *territory;
@property (nonatomic, assign) id<NotAtHomeTerritoryDetailViewControllerDelegate> delegate;

- (id)initWithTerritory:(NSMutableDictionary *)theTerritory;

- (NSString *)ownerEmailAddress;

@end
