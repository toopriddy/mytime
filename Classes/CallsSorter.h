//
//  CallsSorter.h
//  MyTime
//
//  Created by Brent Priddy on 7/25/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
	  CALLS_SORTED_BY_STREET
	, CALLS_SORTED_BY_DATE
	, CALLS_SORTED_BY_CITY
	, CALLS_SORTED_BY_NAME
	, CALLS_SORTED_BY_STUDY
	, CALLS_SORTED_BY_METADATA
} SortCallsType;


@interface CallsSorter : NSObject {
	NSMutableArray *calls;
	NSMutableArray *sectionNames;
	NSMutableArray *sectionIndexNames;
	NSMutableArray *sectionRowCount;
	NSMutableArray *sectionOffsets;

	NSMutableArray *_displayArray;
	
	SortCallsType sortedBy;
}

@property (nonatomic, retain) NSMutableArray *calls;
@property (nonatomic, retain) NSMutableArray *sectionNames;
@property (nonatomic, retain) NSMutableArray *sectionIndexNames;
@property (nonatomic, retain) NSMutableArray *sectionRowCount;
@property (nonatomic, retain) NSMutableArray *sectionOffsets;
@property (nonatomic, retain) NSMutableArray *displayArray;
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


