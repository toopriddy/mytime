#import "_MTSorter.h"
@class MTAdditionalInformationType;

extern NSString * const MTSorterGroupName;
extern NSString * const MTSorterGroupArray;
extern NSString * const MTSorterEntryPath;
extern NSString * const MTSorterEntryName;
extern NSString * const MTSorterEntryUUID;
extern NSString * const MTSorterEntrySectionIndexPath;
extern NSString * const MTSorterEntryRequiresArraySorting;
extern NSString * const MTSorterEntryRequiresLocalizedCaseInsensitiveCompare;

@interface MTSorter : _MTSorter {}
// Custom logic goes here.
+ (MTSorter *)createSorterForDisplayRule:(MTDisplayRule *)displayRule;
+ (NSArray *)sorterInformationArray;
+ (NSString *)nameForPath:(NSString *)path;
+ (NSString *)sectionIndexPathForPath:(NSString *)path;
+ (BOOL)requiresArraySortingForPath:(NSString *)path;
+ (BOOL)requiresLocalizedCaseInsensitiveCompareForPath:(NSString *)path;
+ (BOOL)sectionIndexDisplaysSingleLetterForPath:(NSString *)path;

+ (void)updateSortersForAdditionalInformationType:(MTAdditionalInformationType *)type;

- (void)setFromAdditionalInformationType:(MTAdditionalInformationType *)type;

@property (nonatomic, readonly) SEL selector;
@end
