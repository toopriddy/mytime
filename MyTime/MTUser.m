#import "MTUser.h"
#import "MTSettings.h"
#import "MyTimeAppDelegate.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "Settings.h"

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

#warning need to initialize the user with MTAdditionalInformationType defaults

+ (MTUser *)getOrCreateUserWithName:(NSString *)name
{
	MTUser *user = [MTUser userWithName:name];
	if(user == nil)
	{
		// no users exist, so create one and set it as the default user
		NSManagedObjectContext *managedObjectContext = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
		
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
		
		
		user = [NSEntityDescription insertNewObjectForEntityForName:[MTUser entityName]
											 inManagedObjectContext:managedObjectContext];
		user.name = name;
		user.orderValue = order + 100.0; // we are using the order to seperate calls and when reordering these will be mobed halfway between users.
		
		// find the last user index
		
		NSError *error = nil;
		if (![managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
	}
	return user;
}

+ (void)setCurrentUser:(MTUser *)user
{
	MTSettings *settings = [MTSettings settings];
	settings.currentUser = user.name;

	NSError *error = nil;
	if (![user.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:MTNotificationUserChanged object:nil];
}

+ (MTUser *)currentUser
{
	MTSettings *settings = [MTSettings settings];
	MTUser *currentUser = [MTUser userWithName:settings.currentUser];

	if(currentUser)
		return currentUser;

	// well the current user was not found, so lets check to see if there are any users at all
	NSManagedObjectContext *managedObjectContext = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
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
