#import "_MTFilter.h"

extern NSString * const MTFilterGroupName;
extern NSString * const MTFilterGroupArray;

extern NSString * const MTFilterUntranslatedName;
extern NSString * const MTFilterEntityName;
extern NSString * const MTFilterPath;
extern NSString * const MTFilterSectionIndexPath;
extern NSString * const MTFilterSubFilters;
extern NSString * const MTFilterValues;
extern NSString * const MTFilterValuesUntranslatedTitles;



@interface MTFilter : _MTFilter 
{
}
@property (nonatomic, readonly) NSString *title;

// value is represented by what would be in the value side of the predicate (like "string" where you quote the string or dates, but not numbers)

// Display 
//		title
//      entityName
//      path
//      options  // if this is nil then this is an endpoint 
//      type

+ (NSArray *)displayEntriesForReturnVisits;
+ (NSArray *)displayEntriesForCalls;
+ (NSArray *)displayEntriesForEntityName:(NSString *)entityName;

// Custom logic goes here.
+ (MTFilter *)createFilterForFilter:(MTFilter *)parentFilter;
+ (MTFilter *)createFilterForDisplayRule:(MTDisplayRule *)displayRule;
+ (void)test:(NSManagedObjectContext *)moc;

- (NSAttributeType)typeForPath;
@end
