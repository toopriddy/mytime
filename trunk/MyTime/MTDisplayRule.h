#import "_MTDisplayRule.h"

extern NSString *const MTNotificationDisplayRuleChanged;

@interface MTDisplayRule : _MTDisplayRule {}
// Custom logic goes here.
+ (MTDisplayRule *)createDisplayRuleForUser:(MTUser *)user;
+ (void)setCurrentDisplayRule:(MTDisplayRule *)displayRule;
+ (MTDisplayRule *)currentDisplayRule;
+ (MTDisplayRule *)currentDisplayRuleInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)createDefaultDisplayRulesForUser:(MTUser *)user;
+ (MTDisplayRule *)displayRuleForInternalName:(NSString *)name;

- (NSArray *)allSortDescriptors;
- (NSArray *)coreDataSortDescriptors;
- (NSString *)sectionIndexPath;
@end
