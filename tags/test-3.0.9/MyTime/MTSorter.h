#import "_MTSorter.h"

extern NSString * const MTSorterGroupName;
extern NSString * const MTSorterGroupArray;
extern NSString * const MTSorterEntryPath;
extern NSString * const MTSorterEntryName;
extern NSString * const MTSorterEntrySectionIndexPath;
extern NSString * const MTSorterEntryRequiresArraySorting;

@interface MTSorter : _MTSorter {}
// Custom logic goes here.
+ (MTSorter *)createSorterForDisplayRule:(MTDisplayRule *)displayRule;
+ (NSArray *)sorterInformationArray;
+ (NSString *)nameForPath:(NSString *)path;
+ (NSString *)sectionIndexPathForPath:(NSString *)path;
+ (BOOL)requiresArraySortingForPath:(NSString *)path;

@property (nonatomic, readonly) SEL selector;
@end
