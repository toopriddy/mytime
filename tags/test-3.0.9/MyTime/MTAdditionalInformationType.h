#import "_MTAdditionalInformationType.h"

extern NSString * const MTNotificationAdditionalInformationTypeChanged;

typedef enum {
	// do not reorder!!! dont add in the middle!!!
	EMAIL,
	PHONE,
	STRING,
	NOTES,
	NUMBER,
	DATE,
	URL,
	CHOICE,
	SWITCH,
	LAST_METADATA_TYPE
} MetadataType;


typedef struct 
{
	NSString *name;
	MetadataType type;
} MetadataInformation;

@interface MTAdditionalInformationType : _MTAdditionalInformationType {}
// Custom logic goes here.
+ (MTAdditionalInformationType *)additionalInformationType:(int)type name:(NSString *)name user:(MTUser *)user;
+ (MTAdditionalInformationType *)insertAdditionalInformationType:(int)type name:(NSString *)name user:(MTUser *)user;
+ (MTAdditionalInformationType *)insertAdditionalInformationTypeForUser:(MTUser *)user;
+ (void)initalizeDefaultAdditionalInformationTypesForUser:(MTUser *)user;
+ (void)initalizeOldStyleStorageDefaultAdditionalInformationTypesForUser:(NSMutableDictionary *)user;
@end
