// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTUser.m instead.

#import "_MTUser.h"

@implementation MTUserID
@end

@implementation _MTUser

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"User";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc_];
}

- (MTUserID*)objectID {
	return (MTUserID*)[super objectID];
}




@dynamic monthDisplayCount;



- (short)monthDisplayCountValue {
	NSNumber *result = [self monthDisplayCount];
	return [result shortValue];
}

- (void)setMonthDisplayCountValue:(short)value_ {
	[self setMonthDisplayCount:[NSNumber numberWithShort:value_]];
}

- (short)primitiveMonthDisplayCountValue {
	NSNumber *result = [self primitiveMonthDisplayCount];
	return [result shortValue];
}

- (void)setPrimitiveMonthDisplayCountValue:(short)value_ {
	[self setPrimitiveMonthDisplayCount:[NSNumber numberWithShort:value_]];
}





@dynamic firstViewTitle;






@dynamic name;






@dynamic order;



- (double)orderValue {
	NSNumber *result = [self order];
	return [result doubleValue];
}

- (void)setOrderValue:(double)value_ {
	[self setOrder:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveOrderValue {
	NSNumber *result = [self primitiveOrder];
	return [result doubleValue];
}

- (void)setPrimitiveOrderValue:(double)value_ {
	[self setPrimitiveOrder:[NSNumber numberWithDouble:value_]];
}





@dynamic thirdViewTitle;






@dynamic fourthViewTitle;






@dynamic secondViewTitle;






@dynamic publisherType;






@dynamic timeTypes;

	
- (NSMutableSet*)timeTypesSet {
	[self willAccessValueForKey:@"timeTypes"];
	NSMutableSet *result = [self mutableSetValueForKey:@"timeTypes"];
	[self didAccessValueForKey:@"timeTypes"];
	return result;
}
	

@dynamic statisticsAdjustments;

	
- (NSMutableSet*)statisticsAdjustmentsSet {
	[self willAccessValueForKey:@"statisticsAdjustments"];
	NSMutableSet *result = [self mutableSetValueForKey:@"statisticsAdjustments"];
	[self didAccessValueForKey:@"statisticsAdjustments"];
	return result;
}
	

@dynamic bulkPlacements;

	
- (NSMutableSet*)bulkPlacementsSet {
	[self willAccessValueForKey:@"bulkPlacements"];
	NSMutableSet *result = [self mutableSetValueForKey:@"bulkPlacements"];
	[self didAccessValueForKey:@"bulkPlacements"];
	return result;
}
	

@dynamic territories;

	
- (NSMutableSet*)territoriesSet {
	[self willAccessValueForKey:@"territories"];
	NSMutableSet *result = [self mutableSetValueForKey:@"territories"];
	[self didAccessValueForKey:@"territories"];
	return result;
}
	

@dynamic presentations;

	
- (NSMutableSet*)presentationsSet {
	[self willAccessValueForKey:@"presentations"];
	NSMutableSet *result = [self mutableSetValueForKey:@"presentations"];
	[self didAccessValueForKey:@"presentations"];
	return result;
}
	

@dynamic additionalInformationTypes;

	
- (NSMutableSet*)additionalInformationTypesSet {
	[self willAccessValueForKey:@"additionalInformationTypes"];
	NSMutableSet *result = [self mutableSetValueForKey:@"additionalInformationTypes"];
	[self didAccessValueForKey:@"additionalInformationTypes"];
	return result;
}
	

@dynamic calls;

	
- (NSMutableSet*)callsSet {
	[self willAccessValueForKey:@"calls"];
	NSMutableSet *result = [self mutableSetValueForKey:@"calls"];
	[self didAccessValueForKey:@"calls"];
	return result;
}
	

@dynamic startTimestamps;

	
- (NSMutableSet*)startTimestampsSet {
	[self willAccessValueForKey:@"startTimestamps"];
	NSMutableSet *result = [self mutableSetValueForKey:@"startTimestamps"];
	[self didAccessValueForKey:@"startTimestamps"];
	return result;
}
	



@end
