//
//  CallsSorter.h
//  MyTime
//
//  Created by Brent Priddy on 7/25/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
	  CALLS_SORTED_BY_STREET
	, CALLS_SORTED_BY_DATE
	, CALLS_SORTED_BY_CITY
	, CALLS_SORTED_BY_NAME
	, CALLS_SORTED_BY_STUDY
} SortCallsType;


@interface CallsSorter : NSObject {
	NSMutableArray *calls;
	NSMutableArray *streetSections;
	NSMutableArray *citySections;
	NSMutableArray *streetRowCount;
	NSMutableArray *cityRowCount;
	NSMutableArray *streetOffsets;
	NSMutableArray *cityOffsets;
	
	SortCallsType sortedBy;
}

@property (nonatomic, retain) NSMutableArray *calls;
@property (nonatomic, retain) NSMutableArray *streetSections;
@property (nonatomic, retain) NSMutableArray *citySections;
@property (nonatomic, retain) NSMutableArray *streetRowCount;
@property (nonatomic, retain) NSMutableArray *cityRowCount;
@property (nonatomic, retain) NSMutableArray *streetOffsets;
@property (nonatomic, retain) NSMutableArray *cityOffsets;
@property (nonatomic, assign) SortCallsType sortedBy;

- (id)initSortedBy:(SortCallsType)theSortedBy;
- (NSInteger)numberOfSections;
- (NSArray *)sectionIndexTitles;
- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (NSMutableDictionary *)callForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)refreshData;
- (void)deleteCallAtIndexPath:(NSIndexPath *)indexPath;

- (void)setCall:(NSMutableDictionary *)call forIndexPath:(NSIndexPath *)indexPath;
- (void)addCall:(NSMutableDictionary *)call;

@end


