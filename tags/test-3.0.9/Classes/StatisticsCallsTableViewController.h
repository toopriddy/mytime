//
//  StatisticsCallsTableViewController.h
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

#import <UIKit/UIKit.h>


@interface StatisticsCallsTableViewController : UITableViewController 
{
	NSArray *calls;
}
@property (nonatomic, retain) NSArray *calls;

- (id)initWithCalls:(NSArray *)theCalls;
@end
