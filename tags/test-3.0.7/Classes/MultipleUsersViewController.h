//
//  MultipleUsersViewController.h
//  MyTime
//
//  Created by Brent Priddy on 6/12/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <Foundation/Foundation.h>
#import "GenericTableViewController.h"
#import <CoreData/CoreData.h>
#import "MTUser.h"

@class MultipleUsersViewController;

@protocol MultipleUsersViewControllerDelegate
- (void) multipleUsersViewController:(MultipleUsersViewController *)viewController selectedUser:(MTUser *)name;
@end

@interface MultipleUsersViewController : GenericTableViewController
{
	id<NSObject, MultipleUsersViewControllerDelegate> delegate;
	NSManagedObjectContext *managedObjectContext;
}
@property (nonatomic, assign) id<NSObject, MultipleUsersViewControllerDelegate> delegate;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
