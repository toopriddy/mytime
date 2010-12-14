#import "_MTSettings.h"

@interface MTSettings : _MTSettings {}
// Custom logic goes here.
+ (MTSettings *)settings;
+ (MTSettings *)settingsInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
@end
