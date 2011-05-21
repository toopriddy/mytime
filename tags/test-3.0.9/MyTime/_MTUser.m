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

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"monthDisplayCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"monthDisplayCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic pioneerStartDate;






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





@dynamic name;






@dynamic secretaryEmailAddress;






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





@dynamic selectedSortByAdditionalInformation;






@dynamic secretaryEmailNotes;






@dynamic publisherType;






@dynamic displayRules;

	
- (NSMutableSet*)displayRulesSet {
	[self willAccessValueForKey:@"displayRules"];
	NSMutableSet *result = [self mutableSetValueForKey:@"displayRules"];
	[self didAccessValueForKey:@"displayRules"];
	return result;
}
	

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
	

@dynamic currentDisplayRule;

	

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
	





@end
