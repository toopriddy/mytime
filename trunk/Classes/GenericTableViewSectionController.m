//
//  GenericTableViewSectionController.m
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

#import "GenericTableViewSectionController.h"

@implementation GenericTableViewSectionController

@synthesize title = _title;
@synthesize cellControllers = _cellControllers;
@synthesize displayCellControllers = _displayCellControllers;

- (id)init
{
	if(self = [super init])
	{
		self.cellControllers = [[NSMutableArray alloc] init];
		[self.cellControllers release]; // get rid of the extra reference count
	}
	
	return self;
}

- (void)dealloc
{
	self.cellControllers = nil;
	self.displayCellControllers = nil;
	[super dealloc];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return [self.displayCellControllers count];
}

- (NSObject<TableViewCellController> *)tableView:(UITableView *)tableView cellControllerAtIndexPath:(NSIndexPath *)indexPath
{
	return [self.displayCellControllers objectAtIndex:indexPath.row];
}

// UITableViewDataSource functions
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return self.title;
}
@end
