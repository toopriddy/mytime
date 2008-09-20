//
//  BaseSortedCallsDataSource.h
//  MyTime
//
//  Created by Brent Priddy on 8/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SortedCallsViewDataSourceProtocol.h"
#import "CallsSorter.h"


@interface BaseSortedCallsDataSource : NSObject <UITableViewDataSource,SortedCallsViewDataSourceProtocol>  
{
	CallsSorter *callsSorter;
}
@property (nonatomic, retain) CallsSorter *callsSorter;

- (id)initSortedBy:(SortCallsType)sortedBy;
- (void)dealloc;

@end

