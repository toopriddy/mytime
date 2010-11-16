#import "MTCall.h"

@implementation MTCall

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
	if(city && state)
		return [NSString stringWithFormat:NSLocalizedString(@"%@, %@", @"City and state(or country) as represented in an address (usually right under the house number and street)"), city, state];
	else if(city)
		return [[city copy] autorelease];
	else if(state)
		return [[state copy] autorelease];
	else
		return @"";
}

- (NSString *)addressNumber
{
	[self willAccessValueForKey:@"houseNumber"];
	[self willAccessValueForKey:@"apartmentNumber"];
	NSString *ret = [[self class] topLineOfAddressWithHouseNumber:[self primitiveValueForKey:@"houseNumber"]
												  apartmentNumber:[self primitiveValueForKey:@"apartmentNumber"]
														   street:nil];
	[self didAccessValueForKey:@"houseNumber"];
	[self didAccessValueForKey:@"apartmentNumber"];
	return ret;
}

- (NSString *)addressNumberAndStreet
{
	[self willAccessValueForKey:@"houseNumber"];
	[self willAccessValueForKey:@"apartmentNumber"];
	[self willAccessValueForKey:@"street"];
	NSString *ret = [[self class] topLineOfAddressWithHouseNumber:[self primitiveValueForKey:@"houseNumber"]
												  apartmentNumber:[self primitiveValueForKey:@"apartmentNumber"]
														   street:[self primitiveValueForKey:@"street"]];
	[self didAccessValueForKey:@"houseNumber"];
	[self didAccessValueForKey:@"apartmentNumber"];
	[self didAccessValueForKey:@"street"];
	return ret;
}

- (NSString *)addressCityAndState
{
	[self willAccessValueForKey:@"city"];
	[self willAccessValueForKey:@"state"];
	NSString *ret = [[self class] bottomLineOfAddressWithCity:[self primitiveValueForKey:@"city"]
														state:[self primitiveValueForKey:@"street"]];
	[self didAccessValueForKey:@"city"];
	[self didAccessValueForKey:@"state"];
	return ret;
}


@end
