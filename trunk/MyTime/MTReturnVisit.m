#import "MTReturnVisit.h"
#import "MTCall.h"

@implementation MTReturnVisit

// Custom logic goes here.
- (void)addMyObservers
{
	registeredObservers_ = YES;
	[self addObserver:self forKeyPath:@"date" options:NSKeyValueObservingOptionNew context:nil]; 
}

- (void) awakeFromInsert 
{
	[super awakeFromInsert];
	self.date = [NSDate date];
	[self addMyObservers];
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
		if(newValue != [NSNull null] && 
		   newValue == [newValue laterDate:self.call.mostRecentReturnVisitDate])
		{
		   self.call.mostRecentReturnVisitDate = newValue;
		}
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
