//
//  NotAtHomeViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotAtHomeTerritoryViewController.h"

@interface NotAtHomeViewController : UITableViewController <NotAtHomeTerritoryViewControllerDelegate>
{
@private
	NSMutableArray *entries;
}
@property (nonatomic, readonly) NSMutableArray *entries;
@end
