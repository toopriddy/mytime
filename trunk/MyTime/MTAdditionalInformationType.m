#import "MTAdditionalInformationType.h"
#import "MyTimeAppDelegate.h"
#import "NSManagedObjectContext+PriddySoftware.h"

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

+ (MTAdditionalInformationType *)insertAdditionalInformationType:(int)type name:(NSString *)name data:(NSData *)data user:(MTUser *)user
{
	double order = 0;
	NSManagedObjectContext *managedObjectContext = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
	for(MTAdditionalInformationType *type in [managedObjectContext fetchObjectsForEntityName:[MTAdditionalInformationType entityName]
																		   propertiesToFetch:[NSArray arrayWithObject:@"order"]
																			   withPredicate:@"(user == %@)", user])
	{
		double userOrder = type.orderValue;
		if (userOrder > order)
			order = userOrder;
	}
	
	MTAdditionalInformationType *mtAdditionalInformationType = [MTAdditionalInformationType insertInManagedObjectContext:managedObjectContext];
	mtAdditionalInformationType.typeValue = type;
	mtAdditionalInformationType.name = name;
	mtAdditionalInformationType.name = [[data copy] autorelease];
	mtAdditionalInformationType.orderValue = order;
	mtAdditionalInformationType.alwaysShownValue = NO;
	mtAdditionalInformationType.user = user;
	
	return mtAdditionalInformationType;
}

@end
