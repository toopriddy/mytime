#import "_MTUser.h"

extern NSString *const MTNotificationUserChanged;

@interface MTUser : _MTUser {}
// Custom logic goes here.
+ (MTUser *)userWithName:(NSString *)name;
+ (MTUser *)getOrCreateUserWithName:(NSString *)name;
+ (MTUser *)currentUser;
+ (void)setCurrentUser:(MTUser *)user;

- (void)moveUserAfter:(MTUser *)afterUser beforeUser:(MTUser *)beforeUser;

@end
