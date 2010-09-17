#import "_MTAdditionalInformationType.h"

@interface MTAdditionalInformationType : _MTAdditionalInformationType {}
// Custom logic goes here.
+ (MTAdditionalInformationType *)additionalInformationType:(int)type name:(NSString *)name user:(MTUser *)user;
+ (MTAdditionalInformationType *)insertAdditionalInformationType:(int)type name:(NSString *)name data:(NSData *)data user:(MTUser *)user;
@end
