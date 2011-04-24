#import "_MTFilter.h"

@interface MTFilter : _MTFilter {}
// value is represented by what would be in the value side of the predicate (like "string" where you quote the string or dates, but not numbers)

// Display 
//		title
//      entityName
//      path
//      options  // if this is nil then this is an endpoint 
//      type

extern NSString * const MTFilterGroupName;
extern NSString * const MTFilterGroupArray;

extern NSString * const MTFilterEntryTitle;
extern NSString * const MTFilterEntityName;
extern NSString * const MTFilterEntryPath;
extern NSString * const MTFilterEntrySectionIndexPath;
extern NSString * const MTFilterSubFilters;
extern NSString * const MTFilterValues;
extern NSString * const MTFilterValuesTitles;


+ (NSArray *)displayEntriesForReturnVisits;
+ (NSArray *)displayEntriesForCalls;

// Custom logic goes here.
+ (MTFilter *)createFilterForFilter:(MTDisplayRule *)parentFilter;
+ (MTFilter *)createFilterForDisplayRule:(MTFilter *)displayRule;
+ (void)test:(NSManagedObjectContext *)moc;
@end
