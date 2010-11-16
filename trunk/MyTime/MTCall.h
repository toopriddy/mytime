#import "_MTCall.h"

@interface MTCall : _MTCall 
{
	NSString *topAddressLine_;
}

+ (NSString *)topLineOfAddressWithHouseNumber:(NSString *)houseNumber apartmentNumber:(NSString *)apartmentNumber street:(NSString *)street;
+ (NSString *)bottomLineOfAddressWithCity:(NSString *)city state:(NSString *)state;

- (NSString *)addressNumber;
- (NSString *)addressNumberAndStreet;
- (NSString *)addressCityAndState;

// Custom logic goes here.
@end
