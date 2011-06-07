#import "MTTerritoryStreet.h"

@implementation MTTerritoryStreet

// Custom logic goes here.
- (void) awakeFromInsert 
{
	[super awakeFromInsert];
	[self setPrimitiveDate:[NSDate date]];
}

@end
