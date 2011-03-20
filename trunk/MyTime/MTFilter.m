#import "MTFilter.h"
#import "MTDisplayRule.h"

@implementation MTFilter

// Custom logic goes here.


+ (MTFilter *)createFilterForDisplayRule:(MTDisplayRule *)displayRule
{
	// first find the highefilterst ordering index
	double order = 0;
	
	for(MTFilter *filter in displayRule.filters)
	{
		double filterOrder = filter.orderValue;
		if (filterOrder > order)
			order = filterOrder;
	}
	
	
	MTFilter *filter = [NSEntityDescription insertNewObjectForEntityForName:[MTFilter entityName]
													 inManagedObjectContext:displayRule.managedObjectContext];
	filter.orderValue = order + 1; // we are using the order to seperate calls and when reordering these will be mobed halfway between displayRules.
	filter.displayRule = displayRule;
	return filter;
}

+ (MTFilter *)createFilterForFilter:(MTDisplayRule *)parentFilter
{
	// first find the highefilterst ordering index
	double order = 0;
	
	for(MTFilter *filter in parentFilter.filters)
	{
		double filterOrder = filter.orderValue;
		if (filterOrder > order)
			order = filterOrder;
	}
	
	
	MTFilter *filter = [NSEntityDescription insertNewObjectForEntityForName:[MTFilter entityName]
													 inManagedObjectContext:parentFilter.managedObjectContext];
	filter.orderValue = order + 1; // we are using the order to seperate calls and when reordering these will be mobed halfway between displayRules.
	filter.parent = parentFilter;
	return filter;
}

@end
