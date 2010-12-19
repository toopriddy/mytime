#import "MTPublication.h"
#import "MTBulkPlacement.h"
#import "MTReturnVisit.h"
#import "NSManagedObjectContext+PriddySoftware.h"

@implementation MTPublication

// Custom logic goes here.
+ (MTPublication *)createPublicationForReturnVisit:(MTReturnVisit *)returnVisit
{
	// first find the highest ordering index
	int order = 0;
	for(MTPublication *publication in [returnVisit.managedObjectContext fetchObjectsForEntityName:[MTPublication entityName]
																				propertiesToFetch:[NSArray arrayWithObject:@"order"]
																					withPredicate:@"returnVisit == %@", returnVisit])
	{
		int userOrder = publication.orderValue;
		if (userOrder > order)
			order = userOrder;
	}
	
	MTPublication *newPublication = [NSEntityDescription insertNewObjectForEntityForName:[MTPublication entityName]
																  inManagedObjectContext:returnVisit.managedObjectContext];
	newPublication.returnVisit = returnVisit;
	newPublication.orderValue = order + 1; // we are using the order to seperate calls and when reordering these will be mobed halfway between users.
	
	return newPublication;
}

+ (MTPublication *)createPublicationForBulkPlacement:(MTBulkPlacement *)bulkPlacement
{
	// first find the highest ordering index
	int order = 0;
	for(MTPublication *publication in [bulkPlacement.managedObjectContext fetchObjectsForEntityName:[MTPublication entityName]
																				  propertiesToFetch:[NSArray arrayWithObject:@"order"]
																					  withPredicate:@"bulkPlacement == %@", bulkPlacement])
	{
		int userOrder = publication.orderValue;
		if (userOrder > order)
			order = userOrder;
	}
	
	MTPublication *newPublication = [NSEntityDescription insertNewObjectForEntityForName:[MTPublication entityName]
																  inManagedObjectContext:bulkPlacement.managedObjectContext];
	newPublication.bulkPlacement = bulkPlacement;
	newPublication.orderValue = order + 1; // we are using the order to seperate calls and when reordering these will be mobed halfway between users.
	
	return newPublication;
}

@end
