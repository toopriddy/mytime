#import "MTPresentation.h"
#import "MTUser.h"
#import "NSManagedObjectContext+PriddySoftware.h"

@implementation MTPresentation

// Custom logic goes here.
+ (MTPresentation *)createPresentationInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	// first find the highest ordering index
	int order = 0;
	for(MTPresentation *presentation in [managedObjectContext fetchObjectsForEntityName:[MTPresentation entityName]
																	  propertiesToFetch:[NSArray arrayWithObject:@"order"]
																		  withPredicate:@"user == %@", [MTUser currentUser]])
	{
		int userOrder = presentation.orderValue;
		if (userOrder > order)
			order = userOrder;
	}
	
	MTPresentation *newPresentation = [NSEntityDescription insertNewObjectForEntityForName:[MTPresentation entityName]
																	inManagedObjectContext:managedObjectContext];
	newPresentation.orderValue = order + 1; // we are using the order to seperate calls and when reordering these will be mobed halfway between users.
	
	return newPresentation;
}

@end
