//
//  MTTimeType+Extensions.m
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "MTTimeType+Extensions.h"
#import "MTUser+Extensions.h"
#import "MyTimeAppDelegate.h"
#import "NSManagedObjectContext+PriddySoftware.h"

@implementation MTTimeType(Extensions)

+ (MTTimeType *)timeTypeWithName:(NSString *)name
{
	MTUser *currentUser = [MTUser currentUser];
	MTTimeType *type = nil;
	NSManagedObjectContext *managedObjectContext = [[MyTimeAppDelegate sharedInstance] managedObjectContext];

	type = [[managedObjectContext fetchObjectsForEntityName:@"TimeType"
											  withPredicate:@"(user == %@) AND (name like %@)", currentUser, name] objectAtIndex:0];
	return type;
}

+ (MTTimeType *)hoursType
{
	NSString *name = @"RBC";
	NSLocalizedString(@"RBC", @"'RBC Hours' ButtonBar View text, Label for the amount of hours spent doing quick builds");

	MTTimeType *type = [MTTimeType timeTypeWithName:name];
	if(type == nil)
	{
		MTUser *currentUser = [MTUser currentUser];
		NSManagedObjectContext *managedObjectContext = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
		type = [NSEntityDescription insertNewObjectForEntityForName:@"TimeType" 
											 inManagedObjectContext:managedObjectContext];
		type.name = @"RBC";
		type.imageFile = @"rbc.png";
		type.deleteable = [NSNumber numberWithBool:NO];
		type.user = currentUser;

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
	return type;
}

+ (MTTimeType *)rbcType
{
	NSString *name = @"Hours";
	NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view");
	
	MTTimeType *type = [MTTimeType timeTypeWithName:name];
	if(type == nil)
	{
		MTUser *currentUser = [MTUser currentUser];
		NSManagedObjectContext *managedObjectContext = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
		type = [NSEntityDescription insertNewObjectForEntityForName:@"TimeType" 
											 inManagedObjectContext:managedObjectContext];
		type.name = name;
		type.imageFile = @"timer.png";
		type.deleteable = [NSNumber numberWithBool:NO];
		type.user = currentUser;

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
	return type;	
}
@end
