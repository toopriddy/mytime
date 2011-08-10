#import "MTTerritoryHouseAttempt.h"

@implementation MTTerritoryHouseAttempt

// Custom logic goes here.
- (void) awakeFromInsert 
{
	[super awakeFromInsert];
	[self setPrimitiveDate:[NSDate date]];
}

@end
