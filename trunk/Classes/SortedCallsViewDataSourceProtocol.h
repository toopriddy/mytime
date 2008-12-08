//
//  SortedCallsViewDataSourceProtocol.h
//  MyTime
//
//  Created by Brent Priddy on 7/24/08.
//  Copyright 2008 PG Software. All rights reserved.
//

@protocol SortedCallsViewDataSourceProtocol <NSObject>
 
@required

// these properties are used by the view controller
// for the navigation and tab bar
@property (readonly) NSString *name;
@property (readonly) NSString *title;
@property (readonly) UIImage *tabBarImage;
@property (readonly) BOOL showAddNewCall;

// this property determines the style of table view displayed
@property (readonly) UITableViewStyle tableViewStyle;

// provides a standardized means of asking for the element at the specific
// index path, regardless of the sorting or display technique for the specific
// datasource
- (NSMutableDictionary *)callForIndexPath:(NSIndexPath *)indexPath;

- (void)setCall:(NSMutableDictionary *)call forIndexPath:(NSIndexPath *)indexPath;
- (void)addCall:(NSMutableDictionary *)call;
- (void)deleteCallAtIndexPath:(NSIndexPath *)indexPath keepInformation:(BOOL)keepInformation;



// this optional protocol allows us to send the datasource this message, since it has the 
// required information
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;

- (void)refreshData;

@end
