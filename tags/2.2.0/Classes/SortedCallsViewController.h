//
//  SortedByStreetViewController.h
//  MyTime
//
//  Created by Brent Priddy on 7/24/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SortedCallsViewDataSourceProtocol.h"
#import "CallViewController.h"

@interface SortedCallsViewController : UIViewController <UITableViewDelegate, CallViewControllerDelegate, UISearchBarDelegate> 
{
	UITableView *theTableView;
	id<SortedCallsViewDataSourceProtocol,UITableViewDataSource> dataSource;
	NSIndexPath *indexPath;
}

@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) id<SortedCallsViewDataSourceProtocol,UITableViewDataSource> dataSource;
@property (nonatomic,retain) NSIndexPath *indexPath;

- (id)initWithDataSource:(id<SortedCallsViewDataSourceProtocol,UITableViewDataSource>)theDataSource;

@end
