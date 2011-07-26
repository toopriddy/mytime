#import "MTCall.h"
#import "MTUser.h"
#import "MTAdditionalInformationType.h"
#import "MTAdditionalInformation.h"
#import "MTDisplayRule.h"
#import "MTSorter.h"
#import "MTReturnVisit.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSLocalization.h"
NSString *const MTNotificationCallChanged = @"settingsNotificationCallChanged";

#include "PSRemoveLocalizedString.h"
NSString * const CallLocationTypeManual = NSLocalizedString(@"Manually pick Location", @"Label for picking the location lookup type");
NSString * const CallLocationTypeGoogleMaps = NSLocalizedString(@"Locate using google Maps", @"Label for picking the location lookup type");
NSString * const CallLocationTypeDoNotShow = NSLocalizedString(@"Do not show in map", @"Label for picking the location lookup type when they do not want the return visit to show up in the map");
#include "PSAddLocalizedString.h"


NSArray *dateSortedSectionIndexTitlesSingleton = nil;
NSArray *booleanSortedSectionIndexTitlesSingleton = nil;

@implementation MTCall

- (void)addMyObservers
{
	registeredObservers_ = YES;
	[self addObserver:self forKeyPath:@"apartmentNumber" options:0 /*NSKeyValueObservingOptionNew*/ context:nil]; 
	[self addObserver:self forKeyPath:@"houseNumber" options:0 /*NSKeyValueObservingOptionNew*/ context:nil]; 
	[self addObserver:self forKeyPath:@"street" options:0 /*NSKeyValueObservingOptionNew*/ context:nil]; 
	[self addObserver:self forKeyPath:@"city" options:0 /*NSKeyValueObservingOptionNew*/ context:nil]; 
	[self addObserver:self forKeyPath:@"state" options:0 /*NSKeyValueObservingOptionNew*/ context:nil]; 
}

- (void)awakeFromFetch
{
	[super awakeFromFetch];
	[self addMyObservers];
}

- (void)awakeFromInsert 
{ 
	[super awakeFromInsert];
	[self addMyObservers];
}

- (void)initializeNewCall
{
	// lets go ahead and add the "Additional Information" always shown
	MTUser *currentUser = [MTUser currentUser];
	self.user = currentUser;
	self.deletedCallValue = NO;
	for(MTAdditionalInformationType *infoType in currentUser.additionalInformationTypes)
	{
		if(infoType.alwaysShownValue)
		{
			MTAdditionalInformation *info = [MTAdditionalInformation insertInManagedObjectContext:self.managedObjectContext];
			info.call = self;
			info.type = infoType;
		}
	}
	MTReturnVisit *returnVisit = [MTReturnVisit insertInManagedObjectContext:self.managedObjectContext];
	returnVisit.call = self;
	returnVisit.type = CallReturnVisitTypeInitialVisit;
	self.mostRecentReturnVisitDate = returnVisit.date;
}

- (void)initializeNewCallWithoutReturnVisit
{
	// lets go ahead and add the "Additional Information" always shown
	MTUser *currentUser = [MTUser currentUser];
	self.user = currentUser;
	self.deletedCallValue = NO;
	for(MTAdditionalInformationType *infoType in currentUser.additionalInformationTypes)
	{
		if(infoType.alwaysShownValue)
		{
			MTAdditionalInformation *info = [MTAdditionalInformation insertInManagedObjectContext:self.managedObjectContext];
			info.call = self;
			info.type = infoType;
		}
	}
}

- (void)didTurnIntoFault
{
	[super didTurnIntoFault];
	if(registeredObservers_)
	{
		registeredObservers_ = NO;
		[self removeObserver:self forKeyPath:@"apartmentNumber"]; 
		[self removeObserver:self forKeyPath:@"houseNumber"]; 
		[self removeObserver:self forKeyPath:@"street"]; 
		[self removeObserver:self forKeyPath:@"city"]; 
		[self removeObserver:self forKeyPath:@"state"]; 
	}	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// lets just kill all precomputed values so that we dont have to figure out what was changed.
	[addressNumber_ release];
	[addressNumberAndStreet_ release];
	[addressCityAndState_ release];
	
	addressNumber_ = nil;
	addressNumberAndStreet_ = nil;
	addressCityAndState_ = nil;
}


// Custom logic goes here.
+ (NSString *)topLineOfAddressWithHouseNumber:(NSString *)houseNumber apartmentNumber:(NSString *)apartmentNumber street:(NSString *)street
{
	if(houseNumber && [houseNumber length] && apartmentNumber && [apartmentNumber length] && street && [street length])
		return [NSString stringWithFormat:NSLocalizedString(@"%@ #%@ %@ ", @"House number, apartment number and Street represented by %1$@ as the house number, %2$@ as the apartment number, notice the # before it that will be there as 'number ...' and then %3$@ as the street name"), houseNumber, apartmentNumber, street];
	else if(houseNumber && [houseNumber length] && street && [street length])
		return [NSString stringWithFormat:NSLocalizedString(@"%@ %@", @"House number and Street represented by %1$@ as the house number and %2$@ as the street name"), houseNumber, street];
	else if(houseNumber && [houseNumber length] && apartmentNumber && [apartmentNumber length])
		return [NSString stringWithFormat:NSLocalizedString(@"%@ #%@", @"House number and apartment number represented by %1$@ as the house number and %2$@ as the apartment number"), houseNumber, apartmentNumber];
	else if(houseNumber && [houseNumber length])
		return [[houseNumber copy] autorelease];
	else if(street && [street length] && apartmentNumber && [apartmentNumber length])
		return [NSString stringWithFormat:NSLocalizedString(@"#%@ %@", @"Apartment Number and street name represented by %1$@ as the apartment number and %2$@ as the street name"), apartmentNumber, street];
	else if(street && [street length])
		return [[street copy] autorelease];
	else if(apartmentNumber && [apartmentNumber length])
		return [[apartmentNumber copy] autorelease];
	else
		return @"";
}

+ (NSString *)bottomLineOfAddressWithCity:(NSString *)city state:(NSString *)state
{
	if(city && city.length && state && state.length)
		return [NSString stringWithFormat:NSLocalizedString(@"%@, %@", @"City and state(or country) as represented in an address (usually right under the house number and street)"), city, state];
	else if(city && city.length)
		return [[city copy] autorelease];
	else if(state && state.length)
		return [[state copy] autorelease];
	else
		return @"";
}

- (NSString *)addressNumber
{
	if(addressNumber_)
		return addressNumber_;
	
	[self willAccessValueForKey:@"houseNumber"];
	[self willAccessValueForKey:@"apartmentNumber"];
	addressNumber_ = [[[self class] topLineOfAddressWithHouseNumber:[self primitiveValueForKey:@"houseNumber"]
													apartmentNumber:[self primitiveValueForKey:@"apartmentNumber"]
															 street:nil] retain];
	[self didAccessValueForKey:@"houseNumber"];
	[self didAccessValueForKey:@"apartmentNumber"];
	return addressNumber_;
}

- (NSString *)addressNumberAndStreet
{
	if(addressNumber_)
		return addressNumber_;
	
	[self willAccessValueForKey:@"houseNumber"];
	[self willAccessValueForKey:@"apartmentNumber"];
	[self willAccessValueForKey:@"street"];
	addressNumberAndStreet_ = [[[self class] topLineOfAddressWithHouseNumber:[self primitiveValueForKey:@"houseNumber"]
															 apartmentNumber:[self primitiveValueForKey:@"apartmentNumber"]
																	  street:[self primitiveValueForKey:@"street"]] retain];
	[self didAccessValueForKey:@"houseNumber"];
	[self didAccessValueForKey:@"apartmentNumber"];
	[self didAccessValueForKey:@"street"];
	return addressNumberAndStreet_;
}

- (NSString *)addressCityAndState
{
	if(addressCityAndState_)
		return addressCityAndState_;
	
	[self willAccessValueForKey:@"city"];
	[self willAccessValueForKey:@"state"];
	addressCityAndState_ = [[[self class] bottomLineOfAddressWithCity:[self primitiveValueForKey:@"city"]
																state:[self primitiveValueForKey:@"state"]] retain];
	[self didAccessValueForKey:@"city"];
	[self didAccessValueForKey:@"state"];
	return addressCityAndState_;
}

- (NSString *)uppercaseFirstLetterOfStreet 
{
    [self willAccessValueForKey:@"uppercaseFirstLetterOfStreet"];
	NSString *value = self.street;
	NSString *stringToReturn = @"";
	if([value length])
	{
		stringToReturn = [[value substringToIndex:1] uppercaseString];
	}
	else
	{
		stringToReturn = @"#";
	}

    [self didAccessValueForKey:@"uppercaseFirstLetterOfStreet"];
    return stringToReturn;
}

- (NSString *)uppercaseFirstLetterOfName
{
    [self willAccessValueForKey:@"uppercaseFirstLetterOfName"];
	NSString *value = self.name;
	NSString *stringToReturn = @"";
	if([value length])
		stringToReturn = [[value substringToIndex:1] uppercaseString];
	else
		stringToReturn = @"#";
	
    [self didAccessValueForKey:@"uppercaseFirstLetterOfName"];
    return stringToReturn;
}

#define DAY_INTERVAL (60 * 60 * 24)
#define WEEK_INTERVAL (DAY_INTERVAL * 7)
#define MONTH_INTERVAL (WEEK_INTERVAL * 4)
#define YEAR_INTERVAL (DAY_INTERVAL * 365)

+ (NSArray *)dateSortedSectionIndexTitles
{
	if(dateSortedSectionIndexTitlesSingleton)
	{
		return dateSortedSectionIndexTitlesSingleton;
	}
	dateSortedSectionIndexTitlesSingleton = [[NSArray arrayWithObjects:
											 NSLocalizedString(@"Very Old", @"section title for calls older than this time interval"), 
											 NSLocalizedString(@"Years Old", @"section title for calls older than this time interval"),
											 NSLocalizedString(@"Months Old", @"section title for calls older than this time interval"),
											 NSLocalizedString(@"Weeks Old", @"section title for calls older than this time interval"),
											 NSLocalizedString(@"Days Old", @"section title for calls older than this time interval"),
											 NSLocalizedString(@"Day Old", @"section title for calls older than this time interval"),
											 nil] retain];
	return dateSortedSectionIndexTitlesSingleton;
}

+ (NSString *)stringForDateSortedIndex:(int)index
{
	return [[[self class] dateSortedSectionIndexTitles] objectAtIndex:index];
}


+ (NSArray *)booleanSortedSectionIndexTitles
{
	if(booleanSortedSectionIndexTitlesSingleton)
	{
		return booleanSortedSectionIndexTitlesSingleton;
	}
	booleanSortedSectionIndexTitlesSingleton = [[NSArray arrayWithObjects:
												 NSLocalizedString(@"?", @"Sorted by ... view section index for unknown values which coresponds to the 'Unknown' section header"),
												 NSLocalizedString(@"OFF", @"section title for calls older than this time interval"), 
												 NSLocalizedString(@"ON", @"section title for calls older than this time interval"),
											  nil] retain];
	return booleanSortedSectionIndexTitlesSingleton;
}

+ (NSString *)stringForBooleanSortedValue:(NSString *)value
{
	if([value isEqualToString:@"1"])
	{
		return NSLocalizedString(@"ON", @"section title for calls older than this time interval");
	}
	else if([value isEqualToString:@"0"])
	{
		return NSLocalizedString(@"OFF", @"section title for calls older than this time interval");
	}
	return NSLocalizedString(@"Unknown", @"Sorted by ... view section header for unknown values");
}

+ (NSString *)indexStringForBooleanSortedValue:(NSString *)value
{
	if([value isEqualToString:@"1"])
	{
		return NSLocalizedString(@"ON", @"section title for calls older than this time interval");
	}
	else if([value isEqualToString:@"0"])
	{
		return NSLocalizedString(@"OFF", @"section title for calls older than this time interval");
	}
	return NSLocalizedString(@"?", @"Sorted by ... view section index for unknown values which coresponds to the 'Unknown' section header");
}

- (NSNumber *)dateSortedSectionIndex
{
    [self willAccessValueForKey:@"dateSortedSectionIndex"];
	NSTimeInterval interval = -[self.mostRecentReturnVisitDate timeIntervalSinceNow];
	int index;
	if(interval < DAY_INTERVAL)
	{
		index = 5;
	}
	else if(interval < WEEK_INTERVAL)
	{
		index = 4;
	}
	else if(interval < MONTH_INTERVAL)
	{
		index = 3;
	}
	else if(interval < YEAR_INTERVAL)
	{
		index = 2;
	}
	else if(interval < 2 * YEAR_INTERVAL)
	{
		index = 1;
	}
	else
	{
		index = 0;
	}
	
    [self didAccessValueForKey:@"dateSortedSectionIndex"];
    return [NSNumber numberWithInt:index];
}

- (NSString *)sectionIndexString
{
	MTSorter *sorter = [[MTDisplayRule currentDisplayRule] sectionIndexSorter];
    [self willAccessValueForKey:@"sectionIndexString"];
	NSString *stringToReturn = nil;
	if(sorter)
	{
		if(sorter.requiresArraySortingValue)
		{
			id additionalInformations = [self.additionalInformation filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"type.name == %@", sorter.name]];
			for(MTAdditionalInformation *entry in additionalInformations)
			{
				// only interested in the first one
				stringToReturn = entry.value;
				break;
			}
		}
		else
		{
			stringToReturn = [self valueForKey:sorter.path];
		}

	}
    [self didAccessValueForKey:@"sectionIndexString"];
    return stringToReturn;
}

- (NSNumber *)sectionIndexNumber
{
	MTSorter *sorter = [[MTDisplayRule currentDisplayRule] sectionIndexSorter];
    [self willAccessValueForKey:@"sectionIndexNumber"];
	NSNumber *valueToReturn = nil;
	if(sorter)
	{
		if(sorter.requiresArraySortingValue)
		{
			id additionalInformations = [self.additionalInformation filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"type.name == %@", sorter.name]];
			for(MTAdditionalInformation *entry in additionalInformations)
			{
				// only interested in the first one
				valueToReturn = entry.number;
				break;
			}
		}
		else
		{
			valueToReturn = [self valueForKey:sorter.path];
		}
		
	}
    [self didAccessValueForKey:@"sectionIndexNumber"];
    return valueToReturn;
}

- (NSNumber *)sectionIndexBoolean
{
	MTSorter *sorter = [[MTDisplayRule currentDisplayRule] sectionIndexSorter];
    [self willAccessValueForKey:@"sectionIndexBoolean"];
	NSNumber *valueToReturn = nil;
	if(sorter)
	{
		if(sorter.requiresArraySortingValue)
		{
			id additionalInformations = [self.additionalInformation filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"type.name == %@", sorter.name]];
			for(MTAdditionalInformation *entry in additionalInformations)
			{
				// only interested in the first one
				valueToReturn = entry.boolean;
				break;
			}
		}
		else
		{
			valueToReturn = [self valueForKey:sorter.path];
		}
		
	}
    [self didAccessValueForKey:@"sectionIndexBoolean"];
    return valueToReturn;
}




@end
