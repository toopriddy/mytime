#import "_MTSorter.h"

extern NSString * const MTSorterGroupName;
extern NSString * const MTSorterGroupArray;
extern NSString * const MTSorterEntryPath;
extern NSString * const MTSorterEntryName;

@interface MTSorter : _MTSorter {}
// Custom logic goes here.
+ (NSArray *)sorterInformationArray;
+ (NSString *)nameForPath:(NSString *)path;
@end
