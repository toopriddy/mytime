//
//  StatisticsCallsTableViewController.m
//  MyTime
//
//  Created by Brent Priddy on 4/22/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "StatisticsCallsTableViewController.h"
#import "Settings.h"

@implementation StatisticsCallsTableViewController
@synthesize calls;

#pragma mark -
#pragma mark Initialization

- (void)dealloc 
{
	self.calls = nil;
    [super dealloc];
}

- (id)initWithCalls:(NSArray *)theCalls
{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:UITableViewStylePlain])) 
	{
		self.title = NSLocalizedString(@"Studies", @"title of the Statistics->Study Individuals-> list of studies");
		self.hidesBottomBarWhenPushed = YES;
		self.calls = theCalls;
    }
    return self;
}


#pragma mark -
#pragma mark View lifecycle

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    // Return the number of rows in the section.
    return self.calls.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = [[self.calls objectAtIndex:indexPath.row] objectForKey:CallName];
	if(cell.textLabel.text.length == 0)
	{
		cell.textLabel.text = NSLocalizedString(@"(Study not named?)", @"name you see if you have a study who is not named yet and you go to Statistics->Study Individuals->");
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}



@end

