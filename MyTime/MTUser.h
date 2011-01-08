#import "_MTUser.h"

extern NSString * const PublisherTypePublisher;
extern NSString * const PublisherTypeAuxilliaryPioneer;
extern NSString * const PublisherTypePioneer;
extern NSString * const PublisherTypeSpecialPioneer;
extern NSString * const PublisherTypeTravelingServant;


extern NSString *const MTNotificationUserChanged;

@interface MTUser : _MTUser {}
// Custom logic goes here.
+ (MTUser *)userWithName:(NSString *)name;
+ (MTUser *)getOrCreateUserWithName:(NSString *)name;
+ (MTUser *)currentUser;
+ (MTUser *)currentUserInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)setCurrentUser:(MTUser *)user;

- (void)moveUserAfter:(MTUser *)afterUser beforeUser:(MTUser *)beforeUser;

@end
