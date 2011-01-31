#import "MTDisplayRule.h"
#import "MTSettings.h"
#import "MTUser.h"
#import "NSManagedObjectContext+PriddySoftware.h"

@implementation MTDisplayRule

// Custom logic goes here.
+ (MTDisplayRule *)createDisplayRuleInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	// first find the highest ordering index
	double order = 0;
	for(MTDisplayRule *displayRule in [managedObjectContext fetchObjectsForEntityName:[MTDisplayRule entityName]
													  propertiesToFetch:[NSArray arrayWithObject:@"order"]
														  withPredicate:nil])
	{
		double displayRuleOrder = displayRule.orderValue;
		if (displayRuleOrder > order)
			order = displayRuleOrder;
	}
	
	
	MTDisplayRule *displayRule = [NSEntityDescription insertNewObjectForEntityForName:[MTDisplayRule entityName]
												 inManagedObjectContext:managedObjectContext];
	displayRule.orderValue = order + 100.0; // we are using the order to seperate calls and when reordering these will be mobed halfway between displayRules.
	return displayRule;
}

+ (void)setCurrentDisplayRule:(MTDisplayRule *)displayRule
{
	MTUser *currentUser = [MTUser currentUser];
	currentUser.currentDisplayRule = displayRule;
	
	NSError *error = nil;
	if (![currentUser.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
}

+ (MTDisplayRule *)currentDisplayRule
{
	MTSettings *settings = [MTSettings settings];
	return [MTDisplayRule currentDisplayRuleInManagedObjectContext:settings.managedObjectContext];
}

+ (MTDisplayRule *)currentDisplayRuleInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	MTUser *currentUser = [MTUser currentUserInManagedObjectContext:managedObjectContext];
	MTDisplayRule *currentDisplayRule = currentUser.currentDisplayRule;
	
	if(currentDisplayRule)
		return currentDisplayRule;
	
	// well the current displayRule was not found, so lets check to see if there are any displayRules at all
	NSArray *displayRules = [managedObjectContext fetchObjectsForEntityName:[MTDisplayRule entityName]
												   propertiesToFetch:[NSArray arrayWithObject:@"name"]
													   withPredicate:nil];
	
	if(displayRules && [displayRules count])
	{
		for(MTDisplayRule *displayRule in displayRules)
		{
			if(displayRule == currentUser.currentDisplayRule)
			{
				currentDisplayRule = displayRule;
				break;
			}
		}
		if(currentDisplayRule == nil)
		{
			currentDisplayRule = [displayRules objectAtIndex:0];
			currentUser.currentDisplayRule = currentDisplayRule;
		}
	}
	return currentDisplayRule;
}


@end
