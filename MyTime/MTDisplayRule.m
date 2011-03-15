#import "MTDisplayRule.h"
#import "MTSettings.h"
#import "MTUser.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "MTSorter.h"

NSString *const MTNotificationDisplayRuleChanged = @"mtNotificationDisplayRuleChanged";

@implementation MTDisplayRule

// Custom logic goes here.
+ (MTDisplayRule *)createDisplayRuleForUser:(MTUser *)user
{
	NSManagedObjectContext *managedObjectContext = user.managedObjectContext;
	// first find the highest ordering index
	double order = 0;
	for(MTDisplayRule *displayRule in [managedObjectContext fetchObjectsForEntityName:[MTDisplayRule entityName]
													  propertiesToFetch:[NSArray arrayWithObject:@"order"]
														  withPredicate:@"user == %@", user])
	{
		double displayRuleOrder = displayRule.orderValue;
		if (displayRuleOrder > order)
			order = displayRuleOrder;
	}
	
	
	MTDisplayRule *displayRule = [NSEntityDescription insertNewObjectForEntityForName:[MTDisplayRule entityName]
												 inManagedObjectContext:managedObjectContext];
	displayRule.orderValue = order + 1; // we are using the order to seperate calls and when reordering these will be mobed halfway between displayRules.
	displayRule.user = user;
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
	else
	{
		currentDisplayRule = [MTDisplayRule displayRuleForInternalName:@"Street Sorted"];
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
	MTDisplayRule *displayRule = [MTDisplayRule createDisplayRuleForUser:user];
	displayRule.user = user;
	displayRule.name = name;
	displayRule.deleteableValue = deletable;
	displayRule.internalValue = internal;
	for(NSSortDescriptor *sortDescriptor in sortDescriptors)
	{
		MTSorter *sorter = [MTSorter createSorterForDisplayRule:displayRule];
		sorter.name = [MTSorter nameForPath:sortDescriptor.key];
		sorter.sectionIndexPath = [MTSorter sectionIndexPathForPath:sortDescriptor.key];
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
							 sortDescriptors:sortByStreet(sortByCity(sortByName(sortByDate(sortDescriptors))))
								   deletable:NO
									internal:YES];
	
	// City Sorted
	[MTDisplayRule createDisplayRuleWithUser:user 
										name:@"City Sorted"
							 sortDescriptors:sortByName(sortByStreet(sortByCity(sortDescriptors)))
								   deletable:NO
									internal:YES];
	
	// Name Sorted
	[MTDisplayRule createDisplayRuleWithUser:user 
										name:@"Name Sorted"
							 sortDescriptors:sortByCity(sortByStreet(sortByName(sortDescriptors)))
								   deletable:NO
									internal:YES];
	
	// Study Sorted
	[MTDisplayRule createDisplayRuleWithUser:user 
										name:@"Studies"
							 sortDescriptors:sortByCity(sortByStreet(sortByName(sortDescriptors)))
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
	while(true)
	{
		NSArray *displayRules = [currentUser.managedObjectContext fetchObjectsForEntityName:[MTDisplayRule entityName]
																		  propertiesToFetch:nil
																			  withPredicate:@"internal == YES && user == %@ && name == %@", currentUser, name];
		if([displayRules count])
		{
			NSLog(@"%@ %@", [[displayRules lastObject] sectionIndexPath], name);
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
		break;
	}
	
	return nil;
}

- (NSArray *)allSortDescriptors
{
	NSArray *sorters = [self.managedObjectContext fetchObjectsForEntityName:[MTSorter entityName]
														  propertiesToFetch:[NSArray arrayWithObjects:@"path", @"ascending", nil]
														withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES]]
															  withPredicate:@"displayRule == %@", self];
	if(sorters.count == 0)
	{
		// at least return something
		return [NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"name" ascending:YES]];
	}
	
	NSMutableArray *sortDescriptors = [NSMutableArray arrayWithCapacity:sorters.count];
	for(MTSorter *sorter in sorters)
	{
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sorter.path ascending:sorter.ascendingValue];
		[sortDescriptors addObject:sortDescriptor];
	}
	return sortDescriptors;
}

- (NSArray *)coreDataSortDescriptors
{
	NSArray *sorters = [self.managedObjectContext fetchObjectsForEntityName:[MTSorter entityName]
														  propertiesToFetch:[NSArray arrayWithObjects:@"path", @"ascending", nil]
														withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES]]
															  withPredicate:@"displayRule == %@ && (requiresArraySorting == NO || requiresArraySorting == nil)", self];
	if(sorters.count == 0)
	{
		// at least return something
		return [NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"name" ascending:YES]];
	}
	
	NSMutableArray *sortDescriptors = [NSMutableArray arrayWithCapacity:sorters.count];
	for(MTSorter *sorter in sorters)
	{
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sorter.path ascending:sorter.ascendingValue];
		[sortDescriptors addObject:sortDescriptor];
	}
	return sortDescriptors;
}

- (NSString *)sectionIndexPath
{
#warning there is a problem here, we cant use the additional information for the section names!
	NSArray *sorters = [self.managedObjectContext fetchObjectsForEntityName:[MTSorter entityName]
														  propertiesToFetch:nil
														withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:NO]]
															  withPredicate:@"displayRule == %@ && (requiresArraySorting == NO || requiresArraySorting == nil)", self];
	if(sorters.count == 0)
		return nil;

	return [[sorters lastObject] sectionIndexPath];
}

@end
