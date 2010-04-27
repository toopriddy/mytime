//
//  NotAtHomeStreetDetailViewController.h
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

@class NotAtHomeHouseViewController;

@protocol NotAtHomeHouseViewControllerDelegate
- (void)notAtHomeHouseViewControllerDone:(NotAtHomeHouseViewController *)notAtHomeStreetViewController;
- (void)notAtHomeHouseViewControllerDeleteHouse:(NotAtHomeHouseViewController *)notAtHomeHouseViewController;
@end

@interface NotAtHomeHouseViewController : GenericTableViewController 
{
@private	
	NSMutableDictionary *house;
	NSDictionary *territory;
	NSDictionary *street;
	NSObject<NotAtHomeHouseViewControllerDelegate> *delegate;
	int tag;
	BOOL newHouse;
	NSMutableArray *allTextFields;
	BOOL obtainFocus;
}
@property (nonatomic, readonly) BOOL newHouse;
@property (nonatomic, assign) int tag;
@property (nonatomic, retain) NSMutableDictionary *house;
@property (nonatomic, assign) BOOL obtainFocus;
@property (nonatomic, retain) NSMutableArray *allTextFields;
@property (nonatomic, retain) NSDictionary *territory;
@property (nonatomic, retain) NSDictionary *street;
@property (nonatomic, assign) NSObject<NotAtHomeHouseViewControllerDelegate> *delegate;

- (id)initWithHouse:(NSMutableDictionary *)theHouse street:(NSDictionary *)theStreet territory:(NSDictionary *)theTerritory;
- (id)initWithStreet:(NSDictionary *)theStreet territory:(NSDictionary *)theTerritory;

@end
