#import "_MTDisplayRule.h"

@interface MTDisplayRule : _MTDisplayRule {}
// Custom logic goes here.
+ (MTDisplayRule *)createDisplayRuleForUser:(MTUser *)user;
+ (void)setCurrentDisplayRule:(MTDisplayRule *)displayRule;
+ (MTDisplayRule *)currentDisplayRule;
+ (MTDisplayRule *)currentDisplayRuleInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)createDefaultDisplayRulesForUser:(MTUser *)user;
+ (MTDisplayRule *)displayRuleForInternalName:(NSString *)name;
@end
