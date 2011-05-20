//
//  QuickNotesViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/21/09.
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
#import "NotesViewController.h"
#import <CoreData/CoreData.h>

@interface QuickNotesViewController : GenericTableViewController 
{
	id<NotesViewControllerDelegate> delegate;
	BOOL editOnly;
	NSManagedObjectContext *managedObjectContext;
}
@property (nonatomic, assign) id<NotesViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL editOnly;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
