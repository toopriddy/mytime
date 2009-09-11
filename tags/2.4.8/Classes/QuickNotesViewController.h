//
//  QuickNotesViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/21/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericTableViewController.h"


@interface QuickNotesViewController : GenericTableViewController 
{
	NSMutableArray *returnVistHistory;
}
@property (nonatomic, retain) NSMutableArray *returnVistHistory;

@end
