#import "MTDisplayRule.h"
#import "MTSettings.h"
#import "MTUser.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "MTSorter.h"
#import "MTFilter.h"
#import "MTCall.h"
#import "AdditionalInformationSortDescriptor.h"
#import "PSLocalization.h"

NSString *const MTNotificationDisplayRuleChanged = @"mtNotificationDisplayRuleChanged";

@implementation MTDisplayRule

MTDisplayRule *g_currentDisplayRule;

+ (void)fixDisplayRules:(NSManagedObjectContext *)moc
{
	// fix for MyTime < 3.0 to create the filters on the Beta tester's phones
	BOOL deleteInternal = NO;
	for(MTDisplayRule *displayRule in [moc fetchObjectsForEntityName:[MTDisplayRule entityName]
												   propertiesToFetch:[NSArray arrayWithObject:@"order"]
													   withPredicate:nil])
	{
		if(displayRule.filter == nil)
		{
			displayRule.filter = [MTFilter createFilterForDisplayRule:displayRule];
			if(displayRule.internalValue)
			{
				deleteInternal = YES;
			}
		}
	}
	if(deleteInternal)
	{
		[self deleteDefaultDisplayRules];
	}

	NSArray *calls = [moc fetchObjectsForEntityName:[MTCall entityName]
									  withPredicate:nil];
	for(MTCall *call in calls)
	{
		NSLog(@"%@ locateion:%@ deleted:%@", call.name, call.locationAquired, call.deletedCall);
	}
}

- (void)awakeFromFetch
{
	[super awakeFromFetch];
}

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

	displayRule.filter = [MTFilter createFilterForDisplayRule:displayRule];

	return displayRule;
}

+ (void)setCurrentDisplayRule:(MTDisplayRule *)displayRule
{
	MTUser *currentUser = [MTUser currentUser];
	currentUser.currentDisplayRule = displayRule;
	[currentUser.managedObjectContext processPendingChanges];
	[g_currentDisplayRule autorelease];
	g_currentDisplayRule = [displayRule retain];
	
	NSError *error = nil;
	if (![currentUser.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
}

+ (MTDisplayRule *)currentDisplayRule
{
	if(g_currentDisplayRule == nil)
	{
		MTSettings *settings = [MTSettings settings];
		g_currentDisplayRule = [[MTDisplayRule currentDisplayRuleInManagedObjectContext:settings.managedObjectContext] retain];
	}
	return g_currentDisplayRule;
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
	displayRule.filter = [MTFilter createFilterForDisplayRule:displayRule];
	return displayRule;
}

+ (void)deleteDefaultDisplayRules
{
	MTUser *currentUser = [MTUser currentUser];
	NSArray *displayRules = [currentUser.managedObjectContext fetchObjectsForEntityName:[MTDisplayRule entityName]
																	  propertiesToFetch:nil
																		  withPredicate:@"internal == YES", currentUser];
	for(MTDisplayRule *displayRule in displayRules)
	{
		[currentUser.managedObjectContext deleteObject:displayRule];
	}
	NSArray *users = [currentUser.managedObjectContext fetchObjectsForEntityName:[MTUser entityName]
															   propertiesToFetch:nil
																   withPredicate:nil];
	for(MTUser *user in users)
	{
		[self createDefaultDisplayRulesForUser:user];
	}
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
	[MTFilter addDeletedFilter:displayRule.filter deleted:NO];
	user.currentDisplayRule = displayRule;

	// Date Sorted
	displayRule = [MTDisplayRule createDisplayRuleWithUser:user 
													  name:@"Date Sorted"
										   sortDescriptors:sortByStreet(sortByCity(sortByName(sortByDate(sortDescriptors))))
												 deletable:NO
												  internal:YES];
	[MTFilter addDeletedFilter:displayRule.filter deleted:NO];
	
	// City Sorted
	displayRule = [MTDisplayRule createDisplayRuleWithUser:user 
													  name:@"City Sorted"
										   sortDescriptors:sortByName(sortByStreet(sortByCity(sortDescriptors)))
												 deletable:NO
												  internal:YES];
	[MTFilter addDeletedFilter:displayRule.filter deleted:NO];
	
	// Name Sorted
	displayRule = [MTDisplayRule createDisplayRuleWithUser:user 
													  name:@"Name Sorted"
										   sortDescriptors:sortByCity(sortByStreet(sortByName(sortDescriptors)))
												 deletable:NO
												  internal:YES];
	[MTFilter addDeletedFilter:displayRule.filter deleted:NO];
	
	// Study Sorted
	displayRule = [MTDisplayRule createDisplayRuleWithUser:user 
													  name:@"Studies"
										   sortDescriptors:sortByCity(sortByStreet(sortByName(sortDescriptors)))
												 deletable:NO
												  internal:YES];
	[MTFilter addDeletedFilter:displayRule.filter deleted:NO];
	[MTFilter addStudiesFilter:displayRule.filter];
	
	// Deleted Calls
	displayRule = [MTDisplayRule createDisplayRuleWithUser:user 
													  name:@"Deleted Calls"
										   sortDescriptors:sortByName(sortByCity(sortByStreet(sortDescriptors)))
												 deletable:NO
												  internal:YES];
	[MTFilter addDeletedFilter:displayRule.filter deleted:YES];
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
			// check to see if the filters have been created yet or not.
			MTDisplayRule *displayRule = [displayRules lastObject];
			if(displayRule.filter == nil)
			{
			}
			
//			NSLog(@"%@ %@", [[displayRules lastObject] sectionIndexPath], name);
			return displayRule;
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

- (BOOL)requiresArraySorting
{
	return [[self.sorters filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"requiresArraySorting == YES", self]] count];
}

- (NSArray *)allSortDescriptors
{
	NSArray *sorters = [[self.sorters filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"requiresArraySorting == NO || requiresArraySorting == nil", self]] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES]]];

	if(sorters.count == 0)
	{
		// at least return something
		return [NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"name" ascending:YES]];
	}
	
	NSMutableArray *sortDescriptors = [NSMutableArray arrayWithCapacity:sorters.count];
	for(MTSorter *sorter in sorters)
	{
		if(sorter.requiresArraySortingValue)
		{
			NSSortDescriptor *sortDescriptor = [[AdditionalInformationSortDescriptor alloc] initWithName:sorter.name 
																									path:sorter.path 
																							   ascending:sorter.ascendingValue 
																								selector:sorter.selector];
			[sortDescriptors addObject:sortDescriptor];
			[sortDescriptor release];
		}
		else
		{
			NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sorter.path ascending:sorter.ascendingValue];
			[sortDescriptors addObject:sortDescriptor];
			[sortDescriptor release];
		}
	}
	return sortDescriptors;
}

- (NSArray *)coreDataSortDescriptors
{
	NSArray *sorters = [[self.sorters filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"requiresArraySorting == NO || requiresArraySorting == nil"]] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES]]];

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
		[sortDescriptor release];
	}
	return sortDescriptors;
}

- (NSString *)sectionIndexPath
{
	NSArray *sorters = [self.sorters sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:NO]]];

	if(sorters.count == 0)
		return nil;

	return [[sorters lastObject] sectionIndexPath];
}

- (MTSorter *)sectionIndexSorter
{
	NSArray *sorters = [self.sorters sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:NO]]];

	if(sorters.count == 0)
		return nil;
	
	return [sorters lastObject];
}

- (NSString *)localizedName
{
	if(self.internalValue)
	{
		return [[PSLocalization localizationBundle] localizedStringForKey:self.name value:self.name table:nil];
	}
	else
	{
		return self.name;
	}
}

@end