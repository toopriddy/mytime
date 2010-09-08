#import "MTSettings.h"
#import "MyTimeAppDelegate.h"
#import "NSManagedObjectContext+PriddySoftware.h"

@implementation MTSettings

+ (MTSettings *)settings
{
	MTSettings *settings;
	NSManagedObjectContext *managedObjectContext = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
	NSArray *array = [managedObjectContext fetchObjectsForEntityName:[MTSettings entityName] withPredicate:nil];

	if(array == nil || [array count] == 0) 
	{
		settings = [NSEntityDescription insertNewObjectForEntityForName:[MTSettings entityName]
												 inManagedObjectContext:managedObjectContext];
		NSError *error = nil;
		if (![managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
	}
	else
	{
		settings = [array objectAtIndex:0];
	}
	
	return settings;
}
@end
