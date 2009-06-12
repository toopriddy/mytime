//
//  GenericTableViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/11/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <UIKit/UIKit.h>

@interface GenericTableViewController : UITableViewController
{
@private	
	NSMutableArray *_sectionControllers;
	NSMutableArray *_displaySectionControllers;
}
@property (nonatomic, retain) NSMutableArray *sectionControllers;
@property (nonatomic, assign) BOOL editing;

- (void)constructSectionControllers;
- (void)updateAndReload;

@end
