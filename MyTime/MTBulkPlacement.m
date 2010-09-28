#import "MTBulkPlacement.h"

@implementation MTBulkPlacement

// Custom logic goes here.
- (void) awakeFromInsert 
{
	[super awakeFromInsert];
	self.date = [NSDate date];
}

@end
