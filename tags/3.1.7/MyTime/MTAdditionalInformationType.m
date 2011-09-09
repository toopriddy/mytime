#import "MTAdditionalInformationType.h"
#import "MyTimeAppDelegate.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "MTUser.h"
#import "Settings.h"
#import "NSString+PriddySoftware.h"
#import "PSLocalization.h"

NSString * const MTNotificationAdditionalInformationTypeChanged = @"MTNotificationAdditionalInformationTypeChanged";

#include "PSRemoveLocalizedString.h"
static MetadataInformation commonInformation[] = {
	{NSLocalizedString(@"Email", @"Call Metadata"), EMAIL}
	,	{NSLocalizedString(@"Phone", @"Call Metadata"), PHONE}
	,	{NSLocalizedString(@"Mobile Phone", @"Call Metadata"), PHONE}
	,	{NSLocalizedString(@"Notes", @"Call Metadata"), NOTES}
};
#include "PSAddLocalizedString.h"

#define ORDER_INCREMENT 100.0
@implementation MTAdditionalInformationType

+ (void)fixAdditionalInformationTypes:(NSManagedObjectContext *)managedObjectContext
{
	NSArray *objects = [managedObjectContext fetchObjectsForEntityName:[MTAdditionalInformationType entityName]
														 withPredicate:nil];
	for(MTAdditionalInformationType *type in objects)
	{
		if(type.uuid == nil)
		{
			type.uuid = [NSString stringFromGeneratedUUID];
		}
	}
}

+ (MTAdditionalInformationType *)additionalInformationType:(int)type name:(NSString *)name user:(MTUser *)user
{
	NSManagedObjectContext *managedObjectContext = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
	
	NSArray *objects = [managedObjectContext fetchObjectsForEntityName:[MTAdditionalInformationType entityName]
														 withPredicate:@"(type == %d) AND (user == %@) AND (name like %@)", type, user, name];
	if(objects && [objects count])
		return [objects objectAtIndex:0];
	return nil;
}

+ (MTAdditionalInformationType *)insertAdditionalInformationType:(int)type name:(NSString *)name user:(MTUser *)user
{
	MTAdditionalInformationType *mtAdditionalInformationType = [MTAdditionalInformationType insertAdditionalInformationTypeForUser:user];
	mtAdditionalInformationType.uuid = [NSString stringFromGeneratedUUID];

	mtAdditionalInformationType.typeValue = type;
	mtAdditionalInformationType.name = name;
	
	return mtAdditionalInformationType;
}

+ (MTAdditionalInformationType *)insertAdditionalInformationTypeForUser:(MTUser *)user
{
	double order = 0;
	for(MTAdditionalInformationType *type in [user.managedObjectContext fetchObjectsForEntityName:[MTAdditionalInformationType entityName]
																				propertiesToFetch:[NSArray arrayWithObject:@"order"]
																					withPredicate:@"(user == %@)", user])
	{
		double userOrder = type.orderValue;
		if (userOrder > order)
			order = userOrder;
	}
	
	MTAdditionalInformationType *mtAdditionalInformationType = [MTAdditionalInformationType insertInManagedObjectContext:user.managedObjectContext];
	mtAdditionalInformationType.uuid = [NSString stringFromGeneratedUUID];
	mtAdditionalInformationType.orderValue = order + ORDER_INCREMENT;
	mtAdditionalInformationType.alwaysShownValue = NO;
	mtAdditionalInformationType.user = user;
	
	return mtAdditionalInformationType;
}

+ (void)initalizeOldStyleStorageDefaultAdditionalInformationTypesForUser:(NSMutableDictionary *)user
{
	NSMutableArray *preferredMetadata = [user objectForKey:SettingsPreferredMetadata];
	NSMutableArray *otherMetadata = [user objectForKey:SettingsOtherMetadata];
	NSMutableArray *metadata = [user objectForKey:SettingsMetadata];
	if(metadata != nil || otherMetadata == nil)
	{
		otherMetadata = [NSMutableArray array];
		for(int i = 0; i < ARRAY_SIZE(commonInformation); i++)
		{
			[otherMetadata addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[[PSLocalization localizationBundle] localizedStringForKey:commonInformation[i].name value:commonInformation[i].name table:@""], SettingsMetadataName, 
									  [NSNumber numberWithInt:commonInformation[i].type], SettingsMetadataType,
									  nil]];
		}
		[(NSMutableDictionary *)user setObject:otherMetadata forKey:SettingsOtherMetadata];
		[(NSMutableDictionary *)user removeObjectForKey:SettingsMetadata];
	}
	if(preferredMetadata == nil)
	{
		preferredMetadata = [NSMutableArray array];
		[(NSMutableDictionary *)user setObject:preferredMetadata forKey:SettingsPreferredMetadata];
	}
}

+ (void)initalizeDefaultAdditionalInformationTypesForUser:(MTUser *)user
{
	for(int i = 0; i < ARRAY_SIZE(commonInformation); i++)
	{
		[MTAdditionalInformationType insertAdditionalInformationType:commonInformation[i].type 
																name:[[PSLocalization localizationBundle] localizedStringForKey:commonInformation[i].name value:commonInformation[i].name table:@""]
																user:user];
	}
}

- (void) awakeFromInsert 
{
	[super awakeFromInsert];
	[self setPrimitiveUuid:[NSString stringFromGeneratedUUID]];
}

@end
