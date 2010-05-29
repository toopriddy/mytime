//
//  MTUser+Extensions.m
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "MTUser+Extensions.h"
#import "MTSettings+Extensions.h"
#import "MyTimeAppDelegate.h"


@implementation MTUser(Extensions)
+ (MTUser *)currentUser
{
	MTSettings *settings = [MTSettings settings];
	MTUser *currentUser = nil;
	
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSManagedObjectContext *managedObjectContext = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	[request setPropertiesToFetch:[NSArray arrayWithObject:@"name"]];
	NSError *error;
	NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
	if(array == nil || [array count] == 0) 
	{
		MTUser *user = [NSEntityDescription insertNewObjectForEntityForName:[entity name] 
													 inManagedObjectContext:managedObjectContext];
		user.name = NSLocalizedString(@"Default User", @"Multiple Users: the default user name when the user has not entered a name for themselves");
		settings.currentUser = user.name;

		NSError *error = nil;
		if (![managedObjectContext save:&error]) 
		{
#warning fix me			
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
		
	}
	else
	{
		for(MTUser *user in array)
		{
			if([user.name isEqualToString:settings.currentUser])
			{
				currentUser = user;
				break;
			}
		}
		if(currentUser == nil)
		{
			currentUser = [array objectAtIndex:0];
			settings.currentUser = currentUser.name;
		}
	}
	
	return currentUser;
}

@end
