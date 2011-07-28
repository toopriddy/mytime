#import "MTUser.h"
#import "MTSettings.h"
#import "MTAdditionalInformationType.h"
#import "MyTimeAppDelegate.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSLocalization.h"

#include "PSRemoveLocalizedString.h"
NSString * const PublisherTypePublisher = NSLocalizedString(@"Publisher", @"publisher type selected in the More->Settings->Publisher Type setting");
NSString * const PublisherTypeAuxilliaryPioneer = NSLocalizedString(@"Auxilliary Pioneer", @"publisher type selected in the More->Settings->Publisher Type setting");
NSString * const PublisherTypePioneer = NSLocalizedString(@"Pioneer", @"publisher type selected in the More->Settings->Publisher Type setting");
NSString * const PublisherTypeSpecialPioneer = NSLocalizedString(@"Special Pioneer", @"publisher type selected in the More->Settings->Publisher Type setting");
NSString * const PublisherTypeTravelingServant = NSLocalizedString(@"Traveling Servant", @"publisher type selected in the More->Settings->Publisher Type setting");
#include "PSAddLocalizedString.h"


NSString *const MTNotificationUserChanged = @"settingsNotificationUserChanged";

@implementation MTUser

+ (MTUser *)userWithName:(NSString *)name
{
	if(name == nil || [name length] == 0)
		return nil;
	NSManagedObjectContext *managedObjectContext = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
	NSArray *objects = [managedObjectContext fetchObjectsForEntityName:[MTUser entityName]
														 withPredicate:@"name like %@", name];
	if(objects && [objects count])
	{
		return [objects objectAtIndex:0];
	}
	return nil;
}

+ (MTUser *)createUserInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	// first find the highest ordering index
	double order = 0;
	for(MTUser *user in [managedObjectContext fetchObjectsForEntityName:[MTUser entityName]
													  propertiesToFetch:[NSArray arrayWithObject:@"order"]
														  withPredicate:nil])
	{
		double userOrder = user.orderValue;
		if (userOrder > order)
			order = userOrder;
	}
	
	
	MTUser *user = [NSEntityDescription insertNewObjectForEntityForName:[MTUser entityName]
												 inManagedObjectContext:managedObjectContext];
	user.orderValue = order + 100.0; // we are using the order to seperate calls and when reordering these will be mobed halfway between users.
	return user;
}

- (void)initalizeUser
{
	[MTAdditionalInformationType initalizeDefaultAdditionalInformationTypesForUser:self];
}

+ (void)setCurrentUser:(MTUser *)user
{
	MTSettings *settings = [MTSettings settings];
	settings.currentUser = user.name;

	NSError *error = nil;
	if (![settings.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:MTNotificationUserChanged object:nil];
}

+ (MTUser *)currentUser
{
	MTSettings *settings = [MTSettings settings];
	return [MTUser currentUserInManagedObjectContext:settings.managedObjectContext];
}

+ (MTUser *)currentUserInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	MTSettings *settings = [MTSettings settingsInManagedObjectContext:managedObjectContext];
	MTUser *currentUser = [MTUser userWithName:settings.currentUser];

	if(currentUser)
		return currentUser;

	// well the current user was not found, so lets check to see if there are any users at all
	NSArray *users = [managedObjectContext fetchObjectsForEntityName:[MTUser entityName]
												   propertiesToFetch:[NSArray arrayWithObject:@"name"]
													   withPredicate:nil];

	if(users && [users count])
	{
		for(MTUser *user in users)
		{
			if([user.name isEqualToString:settings.currentUser])
			{
				currentUser = user;
				break;
			}
		}
		if(currentUser == nil)
		{
			currentUser = [users objectAtIndex:0];
			settings.currentUser = currentUser.name;
		}
	}
	else
	{
		// no users exist, so create one and set it as the default user
		MTUser *user = [NSEntityDescription insertNewObjectForEntityForName:[MTUser entityName]
													 inManagedObjectContext:managedObjectContext];
		user.name = NSLocalizedString(@"Default User", @"Multiple Users: the default user name when the user has not entered a name for themselves");
		currentUser = user;
		settings.currentUser = user.name;
		
		NSError *error = nil;
		if (![managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
	}
	return currentUser;
}

- (void)moveUserAfter:(MTUser *)afterUser beforeUser:(MTUser *)beforeUser
{
	self.orderValue = afterUser.orderValue + (beforeUser.orderValue - afterUser.orderValue)/2.0;
}

@end