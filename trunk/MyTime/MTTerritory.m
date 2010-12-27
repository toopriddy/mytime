#import "MTTerritory.h"

@implementation MTTerritory

// Custom logic goes here.
- (void) awakeFromInsert 
{
	[super awakeFromInsert];
	self.date = [NSDate date];
}
@end
