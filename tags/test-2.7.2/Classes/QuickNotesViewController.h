//
//  QuickNotesViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/21/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericTableViewController.h"
#import "NotesViewController.h"

@interface QuickNotesViewController : GenericTableViewController 
{
	NSMutableArray *returnVisitHistory;
	id<NotesViewControllerDelegate> delegate;
	BOOL editOnly;
}
@property (nonatomic, retain) NSMutableArray *returnVisitHistory;
@property (nonatomic, assign) id<NotesViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL editOnly;

@end
