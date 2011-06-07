#import "MTTimeEntry.h"

@implementation MTTimeEntry

// Custom logic goes here.
- (void) awakeFromInsert 
{
	[super awakeFromInsert];
	[self setPrimitiveDate:[NSDate date]];
}
@end
