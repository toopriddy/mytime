#import "_MTFilter.h"

@interface MTFilter : _MTFilter {}
// Custom logic goes here.
+ (MTFilter *)createFilterForFilter:(MTDisplayRule *)parentFilter;
+ (MTFilter *)createFilterForDisplayRule:(MTDisplayRule *)displayRule;
@end
