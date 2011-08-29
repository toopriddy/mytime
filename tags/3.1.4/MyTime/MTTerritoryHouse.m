#import "MTTerritoryHouse.h"
#import "MTTerritoryHouseAttempt.h"

@implementation MTTerritoryHouse

// Custom logic goes here.
- (void) awakeFromInsert 
{
	[super awakeFromInsert];
	[self setPrimitiveDate:[NSDate date]];
}

- (NSNumber *)hashedOrder
{
	NSUInteger hash = 0;
	hash += [self.number hash];
	hash += [self.apartment hash];
	hash += [self.notes hash];
	
	for(MTTerritoryHouseAttempt *attempt in self.attempts)
	{
		hash += [attempt.date hash];
	}
	
	return [NSNumber numberWithUnsignedInteger:hash];
}

@end
