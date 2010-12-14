#import "MTAdditionalInformationType.h"
#import "MyTimeAppDelegate.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "MTUser.h"

#define ORDER_INCREMENT 100.0
@implementation MTAdditionalInformationType

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
	mtAdditionalInformationType.orderValue = order + ORDER_INCREMENT;
	mtAdditionalInformationType.alwaysShownValue = NO;
	mtAdditionalInformationType.user = user;
	
	return mtAdditionalInformationType;
}

@end
