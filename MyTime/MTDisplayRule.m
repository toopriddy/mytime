#import "MTDisplayRule.h"
#import "MTSettings.h"
#import "MTUser.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "MTSorter.h"

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

static NSArray *sortByStreet(NSArray *previousSorters)
{
	return [previousSorters arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"street" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
														   [NSSortDescriptor psSortDescriptorWithKey:@"houseNumber" ascending:YES selector:@selector(localizedStandardCompare:)],
														   [NSSortDescriptor psSortDescriptorWithKey:@"apartmentNumber" ascending:YES selector:@selector(localizedStandardCompare:)], nil]];
}

static NSArray *sortByName(NSArray *previousSorters)
{
	return [previousSorters arrayByAddingObject:[NSSortDescriptor psSortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
}

static NSArray *sortByCity(NSArray *previousSorters)
{
	return [previousSorters arrayByAddingObject:[NSSortDescriptor psSortDescriptorWithKey:@"city" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
}

static NSArray *sortByDate(NSArray *previousSorters)
{
	return [previousSorters arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"mostRecentReturnVisitDate" ascending:YES], nil]];
}

static NSArray *sortByDeletedFlag(NSArray *previousSorters)
{
	return [previousSorters arrayByAddingObject:[NSSortDescriptor psSortDescriptorWithKey:@"deleted" ascending:NO]];
}

+ (MTDisplayRule *)createDisplayRuleWithUser:(MTUser *)user 
										name:(NSString *)name 
							 sortDescriptors:(NSArray *)sortDescriptors 
								   deletable:(BOOL)deletable 
									internal:(BOOL)internal
{
	NSManagedObjectContext *moc = user.managedObjectContext;
	MTDisplayRule *displayRule = [MTDisplayRule insertInManagedObjectContext:moc];
	displayRule.user = user;
	displayRule.name = name;
	displayRule.deleteableValue = deletable;
	displayRule.internalValue = internal;
	for(NSSortDescriptor *sortDescriptor in sortDescriptors)
	{
		MTSorter *sorter = [MTSorter insertInManagedObjectContext:moc];
		sorter.displayRule = displayRule;
		sorter.name = [MTSorter nameForPath:sortDescriptor.key];
		sorter.path = sortDescriptor.key;
		sorter.ascendingValue = sortDescriptor.ascending;
	}
	return displayRule;
}

+ (void)createDefaultDisplayRulesForUser:(MTUser *)user
{
	MTDisplayRule *displayRule;
	
	NSArray *sortDescriptors = [NSArray array];
	
	// Street Sorted
	displayRule = [MTDisplayRule createDisplayRuleWithUser:user 
													  name:@"Street Sorted"
										   sortDescriptors:sortByName(sortByCity(sortByStreet(sortDescriptors))) 
												 deletable:NO
												  internal:YES];
	user.currentDisplayRule = displayRule;

	// Date Sorted
	[MTDisplayRule createDisplayRuleWithUser:user 
										name:@"Date Sorted"
							 sortDescriptors:sortByName(sortByCity(sortByStreet(sortDescriptors))) 
								   deletable:NO
									internal:YES];
	
	// City Sorted
	[MTDisplayRule createDisplayRuleWithUser:user 
										name:@"City Sorted"
							 sortDescriptors:sortByName(sortByCity(sortByStreet(sortDescriptors))) 
								   deletable:NO
									internal:YES];
	
	// Name Sorted
	[MTDisplayRule createDisplayRuleWithUser:user 
										name:@"Name Sorted"
							 sortDescriptors:sortByName(sortByCity(sortByStreet(sortDescriptors))) 
								   deletable:NO
									internal:YES];
	
	// Study Sorted
	[MTDisplayRule createDisplayRuleWithUser:user 
										name:@"Studies"
							 sortDescriptors:sortByName(sortByCity(sortByStreet(sortDescriptors))) 
								   deletable:NO
									internal:YES];
	
	// Deleted Calls
	[MTDisplayRule createDisplayRuleWithUser:user 
										name:@"Deleted Calls"
							 sortDescriptors:sortByName(sortByCity(sortByStreet(sortDescriptors))) 
								   deletable:NO
									internal:YES];
}

+ (MTDisplayRule *)displayRuleForInternalName:(NSString *)name
{
	MTUser *currentUser = [MTUser currentUser];
	BOOL tryAgain = YES;
	NSArray *displayRules = [currentUser.managedObjectContext fetchObjectsForEntityName:[MTDisplayRule entityName]
																	  propertiesToFetch:nil
																		  withPredicate:@"internal == YES && user == %@ && name == %@", currentUser, name];
	do 
	{
		if([displayRules count])
		{
			return [displayRules lastObject];
		}
		else
		{
			if(tryAgain)
			{
				[self createDefaultDisplayRulesForUser:currentUser];
				tryAgain = NO;
				continue;
			}
		}
	} while(NO);
	
	return nil;
}
@end
