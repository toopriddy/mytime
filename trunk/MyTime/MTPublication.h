#import "_MTPublication.h"

@class MTReturnVisit;
@class MTBulkPlacement;

@interface MTPublication : _MTPublication {}
// Custom logic goes here.
+ (MTPublication *)createPublicationForReturnVisit:(MTReturnVisit *)returnVisit;
+ (MTPublication *)createPublicationForBulkPlacement:(MTBulkPlacement *)bulkPlacement;
@end
