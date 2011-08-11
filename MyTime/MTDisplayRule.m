#import "MTDisplayRule.h"
#import "MTSettings.h"
#import "MTUser.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "MTSorter.h"
#import "MTFilter.h"
#import "MTCall.h"
#import "MTAdditionalInformationType.h"
#import "AdditionalInformationSortDescriptor.h"
#import "NSString+PriddySoftware.h"
#import "PSLocalization.h"

NSString *const MTNotificationDisplayRuleChanged = @"mtNotificationDisplayRuleChanged";

@implementation MTDisplayRule

MTDisplayRule *g_currentDisplayRule;

+ (void)fixDisplayRules:(NSManagedObjectContext *)moc
{
	// fix for MyTime < 3.0 to create the filters on the Beta tester's phones
	for(MTDisplayRule *displayRule in [moc fetchObjectsForEntityName:[MTDisplayRule entityName]
												   propertiesToFetch:nil
													   withPredicate:nil])
	{
		if(displayRule.filter == nil)
		{
			displayRule.filter = [MTFilter createFilterForDisplayRule:displayRule];
			if(displayRule.internalValue)
			{
				[displayRule restoreDefaults];
			}
		}
		if(displayRule.additionalInformationTypeUuid == nil)
		{
			displayRule.additionalInformationTypeUuid = [NSString stringFromGeneratedUUID];
		}
		
		// fix the city and state sorters
		for(MTSorter *sorter in displayRule.sorters)
		{
			if([sorter.sectionIndexPath isEqualToString:@"city"])
			{
				sorter.sectionIndexPath = @"uppercaseFirstLetterOfCity";
			}
			else if([sorter.sectionIndexPath isEqualToString:@"state"])
			{
				sorter.sectionIndexPath = @"uppercaseFirstLetterOfState";
			}
		}
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

// Custom logic goes here.
+ (MTDisplayRule *)displayRuleForAdditionalInformationType:(MTAdditionalInformationType *)type
{
	MTUser *user = type.user;
	MTDisplayRule *displayRule;
	NSArray *objects = [type.managedObjectContext fetchObjectsForEntityName:[MTDisplayRule entityName]
														  propertiesToFetch:nil
															  withPredicate:@"user == %@ && additionalInformationTypeUuid == %@", user, type.uuid];
	if([objects count])
	{
		return [objects objectAtIndex:0];
	}
	displayRule = [MTDisplayRule createDisplayRuleForUser:user];
	displayRule.additionalInformationTypeUuid = type.uuid;
	displayRule.name = type.name;
	
	// need to add deleted calls filter
	[MTFilter addDeletedFilter:displayRule.filter deleted:NO];
	
	displayRule.deleteableValue = YES;
	displayRule.internalValue = NO;
	displayRule.sorters = nil;

	MTSorter *sorter = [MTSorter createSorterForDisplayRule:displayRule];
	[sorter setFromAdditionalInformationType:type];

	return displayRule;
}

+ (void)setCurrentDisplayRule:(MTDisplayRule *)displayRule
{
	MTUser *currentUser = [MTUser currentUser];
	currentUser.currentDisplayRule = displayRule;
	[currentUser.managedObjectContext processPendingChanges];
	[g_currentDisplayRule autorelease];
	g_currentDisplayRule = [displayRule retain];
	
	if(g_currentDisplayRule != nil)
	{
		NSError *error = nil;
		if (![currentUser.managedObjectContext save:&error]) 
		{
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
		}
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

+ (MTDisplayRule *)createDisplayRuleForUser:(MTUser *)user 
									   name:(NSString *)name 
{
	MTDisplayRule *displayRule = [MTDisplayRule createDisplayRuleForUser:user];
	displayRule.user = user;
	displayRule.name = name;
	displayRule.internalValue = YES;
	return displayRule;
}

+ (MTDisplayRule *)createDisplayRuleForUser:(MTUser *)user 
									   name:(NSString *)name 
							sortDescriptors:(NSArray *)sortDescriptors 
								  deletable:(BOOL)deletable 
								   internal:(BOOL)internal
{
	MTDisplayRule *displayRule = [MTDisplayRule createDisplayRuleForUser:user name:name];
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

+ (void)createDefaultDisplayRulesForUser:(MTUser *)user
{
	MTDisplayRule *displayRule;
	
	// Street Sorted
	displayRule = [MTDisplayRule createDisplayRuleForUser:user 
													 name:@"Street Sorted"];
	[displayRule restoreDefaults];
	user.currentDisplayRule = displayRule;
	
	// Date Sorted
	displayRule = [MTDisplayRule createDisplayRuleForUser:user 
													 name:@"Date Sorted"];
	[displayRule restoreDefaults];
	
	// City Sorted
	displayRule = [MTDisplayRule createDisplayRuleForUser:user 
													 name:@"City Sorted"];
	[displayRule restoreDefaults];
	
	// Name Sorted
	displayRule = [MTDisplayRule createDisplayRuleForUser:user 
													 name:@"Name Sorted"];
	[displayRule restoreDefaults];
	
	// Study Sorted
	displayRule = [MTDisplayRule createDisplayRuleForUser:user 
													 name:@"Studies"];
	[displayRule restoreDefaults];
	
	// Deleted Calls
	displayRule = [MTDisplayRule createDisplayRuleForUser:user 
													 name:@"Deleted Calls"];
	[displayRule restoreDefaults];
}

- (MTDisplayRule *)setSortDescriptors:(NSArray *)sortDescriptors 
							deletable:(BOOL)deletable 
							 internal:(BOOL)internal
{
	self.deleteableValue = deletable;
	self.internalValue = internal;
	self.sorters = nil;
	for(NSSortDescriptor *sortDescriptor in sortDescriptors)
	{
		MTSorter *sorter = [MTSorter createSorterForDisplayRule:self];
		sorter.name = [MTSorter nameForPath:sortDescriptor.key];
		sorter.sectionIndexPath = [MTSorter sectionIndexPathForPath:sortDescriptor.key];
		sorter.path = sortDescriptor.key;
		sorter.ascendingValue = sortDescriptor.ascending;
	}
	self.filter = nil;
	self.filter = [MTFilter createFilterForDisplayRule:self];
	return self;
}


- (void)restoreDefaults
{
	NSMutableArray *sortDescriptors = [NSMutableArray array];
	if([self.name isEqualToString:@"Street Sorted"])
	{
		[self setSortDescriptors:sortByName(sortByCity(sortByStreet(sortDescriptors)))
					   deletable:NO
						internal:YES];
		[MTFilter addDeletedFilter:self.filter deleted:NO];
	}
	else if([self.name isEqualToString:@"Date Sorted"])
	{
		[self setSortDescriptors:sortByStreet(sortByCity(sortByName(sortByDate(sortDescriptors))))
					   deletable:NO
						internal:YES];
		[MTFilter addDeletedFilter:self.filter deleted:NO];
	}
	else if([self.name isEqualToString:@"City Sorted"])
	{
		[self setSortDescriptors:sortByName(sortByStreet(sortByCity(sortDescriptors)))
					   deletable:NO
						internal:YES];
		[MTFilter addDeletedFilter:self.filter deleted:NO];
	}
	else if([self.name isEqualToString:@"Name Sorted"])
	{
		[self setSortDescriptors:sortByCity(sortByStreet(sortByName(sortDescriptors)))
					   deletable:NO
						internal:YES];
		[MTFilter addDeletedFilter:self.filter deleted:NO];
	}
	else if([self.name isEqualToString:@"Studies"])
	{
		[self setSortDescriptors:sortByCity(sortByStreet(sortByName(sortDescriptors)))
					   deletable:NO
						internal:YES];
		[MTFilter addDeletedFilter:self.filter deleted:NO];
		[MTFilter addStudiesFilter:self.filter];
	}
	else if([self.name isEqualToString:@"Deleted Calls"])
	{
		[self setSortDescriptors:sortByName(sortByCity(sortByStreet(sortDescriptors)))
					   deletable:NO
						internal:YES];
		[MTFilter addDeletedFilter:self.filter deleted:YES];
	}
	else
	{
		assert(NO); // this is not an internal view
	}
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
	NSArray *sorters = [self.sorters sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES]]];

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
			NSSortDescriptor *sortDescriptor = [[AdditionalInformationSortDescriptor alloc] initWithName:sorter.additionalInformationTypeUuid 
																									path:sorter.path 
																							   ascending:sorter.ascendingValue 
																								selector:sorter.selector];
			[sortDescriptors addObject:sortDescriptor];
			[sortDescriptor release];
		}
		else
		{
			NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sorter.path ascending:sorter.ascendingValue selector:sorter.selector];
			[sortDescriptors addObject:sortDescriptor];
			[sortDescriptor release];
		}
	}
	return sortDescriptors;
}

- (NSArray *)coreDataSortDescriptors
{
	NSSet *filteredSet = [self.sorters filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"requiresArraySorting == NO || requiresArraySorting == nil"]];
	NSArray *sorters = [filteredSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES]]];

	if(sorters.count == 0)
	{
		// at least return something
		return [NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
	}
	
	NSMutableArray *sortDescriptors = [NSMutableArray arrayWithCapacity:sorters.count];
	for(MTSorter *sorter in sorters)
	{
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sorter.path ascending:sorter.ascendingValue  selector:sorter.selector];
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
