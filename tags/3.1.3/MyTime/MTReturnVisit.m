#import "MTReturnVisit.h"
#import "MTCall.h"
#import "NSManagedObjectContext+PriddySoftware.h"

#include "PSRemoveLocalizedString.h"
NSString * const CallReturnVisitTypeTransferedStudy = NSLocalizedString(@"Transfered Study", @"return visit type name when this call is transfered from another witness");
NSString * const CallReturnVisitTypeTransferedNotAtHome = NSLocalizedString(@"Transfered Not At Home", @"return visit type name when this call is transfered from another witness");
NSString * const CallReturnVisitTypeTransferedReturnVisit = NSLocalizedString(@"Transfered Return Visit", @"return visit type name when this call is transfered from another witness");
NSString * const CallReturnVisitTypeTransferedInitialVisit = NSLocalizedString(@"Transfered Initial Visit", @"return visit type name when this call is transfered from another witness");
NSString * const CallReturnVisitTypeReturnVisit = NSLocalizedString(@"Return Visit", @"return visit type name");
NSString * const CallReturnVisitTypeInitialVisit = NSLocalizedString(@"Initial Visit", @"This is used to signify the first visit which is not counted as a return visit.  This is in the view where you get to pick the visit type");
NSString * const CallReturnVisitTypeStudy = NSLocalizedString(@"Study", @"return visit type name");
NSString * const CallReturnVisitTypeNotAtHome = NSLocalizedString(@"Not At Home", @"return visit type name");
#include "PSAddLocalizedString.h"

@implementation MTReturnVisit

// Custom logic goes here.
- (void)addMyObservers
{
	registeredObservers_ = YES;
	[self addObserver:self forKeyPath:@"date" options:NSKeyValueObservingOptionNew context:nil]; 
}

- (void)awakeFromInsert 
{
	[super awakeFromInsert];
	[self addMyObservers];
	[self setPrimitiveDate:[NSDate date]];
}

- (void)awakeFromFetch
{
	[super awakeFromFetch];
	[self addMyObservers];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// lets just kill all precomputed values so that we dont have to figure out what was changed.
	if([keyPath isEqual:@"date"]) 
	{
		id newValue = [change objectForKey:NSKeyValueChangeNewKey];
		if(newValue != [NSNull null] && newValue == [newValue laterDate:self.call.mostRecentReturnVisitDate])
		{
			self.call.mostRecentReturnVisitDate = newValue;
		}
		else
		{
			// since this was the previous newest, lookup and see what the latest is
			NSArray *returnVisits = [self.managedObjectContext fetchObjectsForEntityName:[MTReturnVisit entityName]
																	   propertiesToFetch:[NSArray arrayWithObject:@"date"]
																	 withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:NO]]
																		   withPredicate:@"(call == %@)", self.call];
			if(returnVisits.count)
			{
				self.call.mostRecentReturnVisitDate = [[returnVisits objectAtIndex:0] date];
			}
		}
    }
}

- (void)setCall:(MTCall *)newCall
{
	[self willChangeValueForKey:@"call"];
	[self setPrimitiveCall:newCall];
	[self didChangeValueForKey:@"call"];
	
	if(newCall && self.date == [self.date laterDate:newCall.mostRecentReturnVisitDate])
	{
		newCall.mostRecentReturnVisitDate = self.date;
	}
}

- (void)didTurnIntoFault
{
	[super didTurnIntoFault];
	if(registeredObservers_)
	{
		registeredObservers_ = NO;
		[self removeObserver:self forKeyPath:@"date"]; 
	}	
}

@end
