#import "MTMultipleChoice.h"
#import "MTAdditionalInformationType.h"
#import "NSManagedObjectContext+PriddySoftware.h"

@implementation MTMultipleChoice

// Custom logic goes here.
+ (MTMultipleChoice *)createMTMultipleChoiceForAdditionalInformationType:(MTAdditionalInformationType *)type
{
	// first find the highest ordering index
	int order = 0;
	for(MTMultipleChoice *choice in [type.managedObjectContext fetchObjectsForEntityName:[MTMultipleChoice entityName]
																	   propertiesToFetch:[NSArray arrayWithObject:@"order"]
																		   withPredicate:@"type == %@", type])
	{
		int userOrder = choice.orderValue;
		if (userOrder > order)
			order = userOrder;
	}
	MTMultipleChoice *newChoice = [NSEntityDescription insertNewObjectForEntityForName:[MTMultipleChoice entityName]
																inManagedObjectContext:type.managedObjectContext];
	newChoice.type = type;
	newChoice.orderValue = order + 1; // we are using the order to seperate calls and when reordering these will be mobed halfway between users.
	
	return newChoice;
}


@end
