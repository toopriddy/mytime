#import "MTTerritoryHouse.h"

@implementation MTTerritoryHouse

// Custom logic goes here.
- (void) awakeFromInsert 
{
	[super awakeFromInsert];
	[self setPrimitiveDate:[NSDate date]];
}

@end
