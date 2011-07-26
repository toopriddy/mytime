#import "_MTDisplayRule.h"
@class MTAdditionalInformationType;

extern NSString *const MTNotificationDisplayRuleChanged;

@interface MTDisplayRule : _MTDisplayRule {}
// Custom logic goes here.
+ (MTDisplayRule *)createDisplayRuleForUser:(MTUser *)user;
+ (void)setCurrentDisplayRule:(MTDisplayRule *)displayRule;
+ (MTDisplayRule *)currentDisplayRule;
+ (MTDisplayRule *)currentDisplayRuleInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)createDefaultDisplayRulesForUser:(MTUser *)user;
+ (MTDisplayRule *)displayRuleForInternalName:(NSString *)name;

+ (MTDisplayRule *)displayRuleForAdditionalInformationType:(MTAdditionalInformationType *)type;

+ (void)fixDisplayRules:(NSManagedObjectContext *)moc;

- (void)restoreDefaults;

- (NSArray *)allSortDescriptors;
- (NSArray *)coreDataSortDescriptors;
- (NSString *)sectionIndexPath;
- (MTSorter *)sectionIndexSorter;
- (BOOL)requiresArraySorting;


- (NSString *)localizedName;

@end
