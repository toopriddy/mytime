//
//  NotAtHomeStreetDetailViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "GenericTableViewController.h"
#import <AddressBook/AddressBook.h>

@class NotAtHomeHouseViewController;

@protocol NotAtHomeHouseViewControllerDelegate
- (void)notAtHomeHouseViewControllerDone:(NotAtHomeHouseViewController *)notAtHomeStreetViewController;
@end

@interface NotAtHomeHouseViewController : GenericTableViewController 
{
@private	
	NSMutableDictionary *house;
	id<NotAtHomeHouseViewControllerDelegate> delegate;
	int tag;
	BOOL newHouse;
}
@property (nonatomic, readonly) BOOL newHouse;
@property (nonatomic, assign) int tag;
@property (nonatomic, retain) NSMutableDictionary *house;
@property (nonatomic, assign) id<NotAtHomeHouseViewControllerDelegate> delegate;

- (id)initWithHouse:(NSMutableDictionary *)theHouse;

@end
