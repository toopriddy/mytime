#import "_MTCall.h"

extern NSString *const MTNotificationCallChanged;

extern NSString * const CallLocationTypeManual;
extern NSString * const CallLocationTypeGoogleMaps;
extern NSString * const CallLocationTypeDoNotShow;


@interface MTCall : _MTCall 
{
	NSString *addressNumber_;
	NSString *addressNumberAndStreet_;
	NSString *addressCityAndState_;
	BOOL registeredObservers_;
	BOOL registeredCurrentDisplayRuleObserver_;
}
@property (readonly) NSString *addressNumber;
@property (readonly) NSString *addressNumberAndStreet;
@property (readonly) NSString *addressCityAndState;

+ (NSString *)topLineOfAddressWithHouseNumber:(NSString *)houseNumber apartmentNumber:(NSString *)apartmentNumber street:(NSString *)street;
+ (NSString *)bottomLineOfAddressWithCity:(NSString *)city state:(NSString *)state;

+ (NSArray *)dateSortedSectionIndexTitles;
+ (NSString *)stringForDateSortedIndex:(int)index;

- (void)initializeNewCall;
- (void)initializeNewCallWithoutReturnVisit;

// Custom logic goes here.
@end
