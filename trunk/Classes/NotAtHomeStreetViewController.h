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

@class NotAtHomeStreetViewController;

@protocol NotAtHomeStreetViewControllerDelegate
- (void)notAtHomeStreetViewControllerDone:(NotAtHomeStreetViewController *)notAtHomeStreetViewController;
@end

@interface NotAtHomeStreetViewController : GenericTableViewController 
{
@private	
	NSMutableDictionary *street;
	NSDictionary *territory;
	id<NotAtHomeStreetViewControllerDelegate> delegate;
	int tag;
	BOOL newStreet;
	NSMutableArray *allTextFields;
	BOOL obtainFocus;
}
@property (nonatomic, readonly) BOOL newStreet;
@property (nonatomic, assign) int tag;
@property (nonatomic, retain) NSMutableDictionary *street;
@property (nonatomic, retain) NSDictionary *territory;
@property (nonatomic, assign) BOOL obtainFocus;
@property (nonatomic, retain) NSMutableArray *allTextFields;
@property (nonatomic, assign) id<NotAtHomeStreetViewControllerDelegate> delegate;

- (id)initWithStreet:(NSMutableDictionary *)theStreet territory:(NSDictionary *)territory;
- (id)initWithTerritory:(NSDictionary *)theTerritory;

@end
