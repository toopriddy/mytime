#import "MTReturnVisit.h"

@implementation MTReturnVisit

// Custom logic goes here.
- (void) awakeFromInsert 
{
	[super awakeFromInsert];
	self.date = [NSDate date];
}

@end
