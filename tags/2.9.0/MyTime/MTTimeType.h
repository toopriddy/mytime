#import "_MTTimeType.h"

@interface MTTimeType : _MTTimeType {}
// Custom logic goes here.
+ (MTTimeType *)hoursType;
+ (MTTimeType *)hoursTypeForUser:(MTUser *)user;

+ (MTTimeType *)rbcType;
+ (MTTimeType *)rbcTypeForUser:(MTUser *)user;

+ (MTTimeType *)timeTypeWithName:(NSString *)name;
+ (MTTimeType *)timeTypeWithName:(NSString *)name user:(MTUser *)user;
@end
