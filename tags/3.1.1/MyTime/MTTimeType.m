#import "MTTimeType.h"
#import "MTUser.h"
#import "MyTimeAppDelegate.h"
#import "NSManagedObjectContext+PriddySoftware.h"

@implementation MTTimeType

+ (MTTimeType *)timeTypeWithName:(NSString *)name user:(MTUser *)user
{
	NSManagedObjectContext *managedObjectContext = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
	
	NSArray *objects = [managedObjectContext fetchObjectsForEntityName:@"TimeType"
														 withPredicate:@"(user == %@) AND (name like %@)", user, name];
	if(objects && [objects count])
		return [objects objectAtIndex:0];
	return nil;
}

+ (MTTimeType *)timeTypeWithName:(NSString *)name
{
	if([name isEqualToString:@"Hours"])
	{
		return [MTTimeType hoursTypeForUser:[MTUser currentUser]];
	}
	else if([name isEqualToString:@"RBC"])
	{
		return [MTTimeType rbcTypeForUser:[MTUser currentUser]];
	}
	return [MTTimeType timeTypeWithName:name user:[MTUser currentUser]];
}

+ (MTTimeType *)rbcTypeForUser:(MTUser *)user
{
	NSString *name = @"RBC";
	NSLocalizedString(@"RBC", @"'RBC Hours' ButtonBar View text, Label for the amount of hours spent doing quick builds");
	
	MTTimeType *type = [MTTimeType timeTypeWithName:name user:user];
	if(type == nil)
	{
		NSManagedObjectContext *managedObjectContext = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
		type = [NSEntityDescription insertNewObjectForEntityForName:@"TimeType" 
											 inManagedObjectContext:managedObjectContext];
		type.name = @"RBC";
		type.imageFileName = @"rbc";
		type.deleteable = [NSNumber numberWithBool:NO];
		type.user = user;
		
		NSError *error = nil;
		if (![managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		
	}
	return type;
}

+ (MTTimeType *)rbcType
{
	return [MTTimeType rbcTypeForUser:[MTUser currentUser]];
}

+ (MTTimeType *)hoursTypeForUser:(MTUser *)user
{
	NSString *name = @"Hours";
	NSLocalizedString(@"Hours", @"'Hours' ButtonBar View text, Label for the amount of hours spend in the ministry, and Expanded name when on the More view");
	
	MTTimeType *type = [MTTimeType timeTypeWithName:name user:user];
	if(type == nil)
	{
		NSManagedObjectContext *managedObjectContext = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
		type = [NSEntityDescription insertNewObjectForEntityForName:@"TimeType" 
											 inManagedObjectContext:managedObjectContext];
		type.name = name;
		type.imageFileName = @"timer";
		type.deleteable = [NSNumber numberWithBool:NO];
		type.user = user;
		
		NSError *error = nil;
		if (![managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
	}	
	return type;	
}

+ (MTTimeType *)hoursType
{
	return [MTTimeType hoursTypeForUser:[MTUser currentUser]];
}
@end
