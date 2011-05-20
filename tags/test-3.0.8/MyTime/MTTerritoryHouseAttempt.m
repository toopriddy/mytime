#import "MTTerritoryHouseAttempt.h"

@implementation MTTerritoryHouseAttempt

// Custom logic goes here.
- (void) awakeFromInsert 
{
	[super awakeFromInsert];
	self.date = [NSDate date];
}

@end
