//
//  MTSettings+Extensions.m
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "MTSettings+Extensions.h"
#import "MyTimeAppDelegate.h"


@implementation MTSettings(Extensions)
+ (MTSettings *)settings
{
	MTSettings *settings;
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSManagedObjectContext *managedObjectContext = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	NSError *error;
	NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
	if(array == nil || [array count] == 0) 
	{
		settings = [NSEntityDescription insertNewObjectForEntityForName:[entity name] 
												 inManagedObjectContext:managedObjectContext];
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
		settings = [array objectAtIndex:0];
	}
	
	return settings;
}
@end
