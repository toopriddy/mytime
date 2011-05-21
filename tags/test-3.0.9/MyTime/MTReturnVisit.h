#import "_MTReturnVisit.h"

extern NSString * const CallReturnVisitTypeTransferedStudy;
extern NSString * const CallReturnVisitTypeTransferedNotAtHome;
extern NSString * const CallReturnVisitTypeTransferedInitialVisit;
extern NSString * const CallReturnVisitTypeTransferedReturnVisit;
extern NSString * const CallReturnVisitTypeInitialVisit;
extern NSString * const CallReturnVisitTypeReturnVisit;
extern NSString * const CallReturnVisitTypeStudy;
extern NSString * const CallReturnVisitTypeNotAtHome;

@interface MTReturnVisit : _MTReturnVisit 
{
	BOOL registeredObservers_;
}
// Custom logic goes here.
@end

 