//
//  NotAtHomeStreetDetailViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "GenericTableViewController.h"
#import <AddressBook/AddressBook.h>

@class NotAtHomeStreetViewController;

@protocol NotAtHomeStreetViewControllerDelegate
- (void)notAtHomeStreetViewControllerDone:(NotAtHomeStreetViewController *)notAtHomeStreetViewController;
@end

@interface NotAtHomeStreetViewController : GenericTableViewController 
{
@private	
	NSMutableDictionary *street;
	id<NotAtHomeStreetViewControllerDelegate> delegate;
	int tag;
	BOOL newStreet;
}
@property (nonatomic, readonly) BOOL newStreet;
@property (nonatomic, assign) int tag;
@property (nonatomic, retain) NSMutableDictionary *street;
@property (nonatomic, assign) id<NotAtHomeStreetViewControllerDelegate> delegate;

- (id)initWithStreet:(NSMutableDictionary *)theStreet;

@end
