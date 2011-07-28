#import "MTTerritory.h"

@implementation MTTerritory

// Custom logic goes here.
- (void) awakeFromInsert 
{
	[super awakeFromInsert];
	[self setPrimitiveDate:[NSDate date]];
}
@end
