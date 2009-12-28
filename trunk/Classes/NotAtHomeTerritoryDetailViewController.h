//
//  NotAtHomeTerritoryDetailViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "GenericTableViewController.h"
@class NotAtHomeTerritoryDetailViewController;

@protocol NotAtHomeTerritoryDetailViewControllerDelegate
- (void)notAtHomeTerritoryDetailViewControllerDone:(NotAtHomeTerritoryDetailViewController *)notAtHomeTerritoryDetailViewController;
@end

@interface NotAtHomeTerritoryDetailViewController : GenericTableViewController 
{
@private	
	NSMutableDictionary *territory;
	id<NotAtHomeTerritoryDetailViewControllerDelegate> delegate;
}
@property (nonatomic, retain) NSMutableDictionary *territory;
@property (nonatomic, retain) id<NotAtHomeTerritoryDetailViewControllerDelegate> delegate;

@end
