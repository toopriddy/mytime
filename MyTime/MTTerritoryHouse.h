#import "_MTTerritoryHouse.h"

@interface MTTerritoryHouse : _MTTerritoryHouse {}
// Custom logic goes here.

// used to lock down an order in the email when people have the same dates
- (NSNumber *)hashedOrder;

@end
