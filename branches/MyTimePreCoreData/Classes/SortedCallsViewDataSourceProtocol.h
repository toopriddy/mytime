//
//  SortedCallsViewDataSourceProtocol.h
//  MyTime
//
//  Created by Brent Priddy on 7/24/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

@protocol SortedCallsViewDataSourceProtocol <NSObject>
 
@required

// these properties are used by the view controller
// for the navigation and tab bar
@property (readonly) NSString *name;
@property (readonly) NSString *title;
@property (readonly) UIImage *tabBarImageName;
@property (readonly) BOOL showAddNewCall;
@property (readonly) BOOL useNameAsMainLabel;

// this property determines the style of table view displayed
@property (readonly) UITableViewStyle tableViewStyle;

// provides a standardized means of asking for the element at the specific
// index path, regardless of the sorting or display technique for the specific
// datasource
- (NSMutableDictionary *)callForIndexPath:(NSIndexPath *)indexPath;

- (void)setCall:(NSMutableDictionary *)call forIndexPath:(NSIndexPath *)indexPath;
- (void)addCall:(NSMutableDictionary *)call;
- (void)deleteCallAtIndexPath:(NSIndexPath *)indexPath keepInformation:(BOOL)keepInformation;
- (void)restoreCallAtIndexPath:(NSIndexPath *)indexPath;
- (void)filterUsingSearchText:(NSString *)searchText;



// this optional protocol allows us to send the datasource this message, since it has the 
// required information
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;

- (void)refreshData;

@end
