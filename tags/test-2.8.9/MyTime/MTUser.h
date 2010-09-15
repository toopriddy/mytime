#import "_MTUser.h"

@interface MTUser : _MTUser {}
// Custom logic goes here.
+ (MTUser *)userWithName:(NSString *)name;
+ (MTUser *)getOrCreateUserWithName:(NSString *)name;
+ (MTUser *)currentUser;

- (void)moveUserAfter:(MTUser *)afterUser beforeUser:(MTUser *)beforeUser;

@end
