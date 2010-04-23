//
//  StatisticsCallsTableViewController.h
//  MyTime
//
//  Created by Brent Priddy on 4/22/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StatisticsCallsTableViewController : UITableViewController 
{
	NSArray *calls;
}
@property (nonatomic, retain) NSArray *calls;

- (id)initWithCalls:(NSArray *)theCalls;
@end
