//
//  CallsSorter.h
//  MyTime
//
//  Created by Brent Priddy on 7/25/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <UIKit/UIKit.h>


typedef enum {
	  CALLS_SORTED_BY_STREET = 1
	, CALLS_SORTED_BY_DATE
	, CALLS_SORTED_BY_CITY
	, CALLS_SORTED_BY_NAME
	, CALLS_SORTED_BY_DELETED
	, CALLS_SORTED_BY_STUDY
	, CALLS_SORTED_BY_METADATA
} SortCallsType;


@interface CallsSorter : NSObject {
	NSMutableArray *calls;
	NSString *callsName;
	NSMutableArray *sectionNames;
	NSMutableArray *sectionIndexNames;
	NSMutableArray *sectionRowCount;
	NSMutableArray *sectionOffsets;

	NSMutableArray *_displayArray;
	
	NSString *_searchText;
	SortCallsType sortedBy;
	NSString *_metadata;
}

@property (nonatomic, retain) NSMutableArray *calls;
@property (nonatomic, retain) NSString *callsName;
@property (nonatomic, retain) NSMutableArray *sectionNames;
@property (nonatomic, retain) NSMutableArray *sectionIndexNames;
@property (nonatomic, retain) NSMutableArray *sectionRowCount;
@property (nonatomic, retain) NSMutableArray *sectionOffsets;
@property (nonatomic, retain) NSMutableArray *displayArray;
@property (nonatomic, assign) SortCallsType sortedBy;
@property (nonatomic, retain) NSString *searchText;
@property (nonatomic, retain) NSString *metadata;

- (id)initSortedBy:(SortCallsType)theSortedBy withMetadata:(NSString *)metadata callsName:(NSString *)callsName;
- (id)initSortedBy:(SortCallsType)theSortedBy withMetadata:(NSString *)metadata;
- (void)filterUsingSearchText:(NSString *)searchText;
- (NSInteger)numberOfSections;
- (NSArray *)sectionIndexTitles;
- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (NSMutableDictionary *)callForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)refreshData;
- (void)deleteCallAtIndexPath:(NSIndexPath *)indexPath;
- (void)restoreCallAtIndexPath:(NSIndexPath *)indexPath;

- (void)setCall:(NSMutableDictionary *)call forIndexPath:(NSIndexPath *)indexPath;
- (void)addCall:(NSMutableDictionary *)call;

@end


