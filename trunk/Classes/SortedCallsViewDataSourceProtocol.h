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
@property (readonly) NSString *unlocalizedName;
@property (readonly) NSString *name;
@property (readonly) NSString *title;
@property (readonly) NSString *tabBarImageName;
@property (readonly) BOOL showAddNewCall;
@property (readonly) BOOL useNameAsMainLabel;
@property (readonly) BOOL showDisclosureIcon;
@property (readonly) BOOL requiresArraySorting;
@property (readonly) BOOL sectionIndexDisplaysSingleLetter;

// this property determines the style of table view displayed
@property (readonly) UITableViewStyle tableViewStyle;
@property (readonly) NSArray *allSortDescriptors;
@property (readonly) NSArray *coreDataSortDescriptors;
@property (readonly) NSPredicate *predicate;
@property (readonly) NSString *sectionNameKeyPath;
- (NSString *)sectionNameForIndex:(int)index;
- (NSArray *)sectionIndexTitles;

@end
