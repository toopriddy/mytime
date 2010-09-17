// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTCall.m instead.

#import "_MTCall.h"

@implementation MTCallID
@end

@implementation _MTCall

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Call" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Call";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Call" inManagedObjectContext:moc_];
}

- (MTCallID*)objectID {
	return (MTCallID*)[super objectID];
}




@dynamic city;






@dynamic apartmentNumber;






@dynamic street;






@dynamic longitude;



- (double)longitudeValue {
	NSNumber *result = [self longitude];
	return [result doubleValue];
}

- (void)setLongitudeValue:(double)value_ {
	[self setLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLongitudeValue {
	NSNumber *result = [self primitiveLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveLongitudeValue:(double)value_ {
	[self setPrimitiveLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic state;






@dynamic locationAquisitionAttempted;



- (BOOL)locationAquisitionAttemptedValue {
	NSNumber *result = [self locationAquisitionAttempted];
	return [result boolValue];
}

- (void)setLocationAquisitionAttemptedValue:(BOOL)value_ {
	[self setLocationAquisitionAttempted:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveLocationAquisitionAttemptedValue {
	NSNumber *result = [self primitiveLocationAquisitionAttempted];
	return [result boolValue];
}

- (void)setPrimitiveLocationAquisitionAttemptedValue:(BOOL)value_ {
	[self setPrimitiveLocationAquisitionAttempted:[NSNumber numberWithBool:value_]];
}





@dynamic houseNumber;






@dynamic deleted;



- (BOOL)deletedValue {
	NSNumber *result = [self deleted];
	return [result boolValue];
}

- (void)setDeletedValue:(BOOL)value_ {
	[self setDeleted:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDeletedValue {
	NSNumber *result = [self primitiveDeleted];
	return [result boolValue];
}

- (void)setPrimitiveDeletedValue:(BOOL)value_ {
	[self setPrimitiveDeleted:[NSNumber numberWithBool:value_]];
}





@dynamic lattitude;



- (double)lattitudeValue {
	NSNumber *result = [self lattitude];
	return [result doubleValue];
}

- (void)setLattitudeValue:(double)value_ {
	[self setLattitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLattitudeValue {
	NSNumber *result = [self primitiveLattitude];
	return [result doubleValue];
}

- (void)setPrimitiveLattitudeValue:(double)value_ {
	[self setPrimitiveLattitude:[NSNumber numberWithDouble:value_]];
}





@dynamic locationLookupType;



- (short)locationLookupTypeValue {
	NSNumber *result = [self locationLookupType];
	return [result shortValue];
}

- (void)setLocationLookupTypeValue:(short)value_ {
	[self setLocationLookupType:[NSNumber numberWithShort:value_]];
}

- (short)primitiveLocationLookupTypeValue {
	NSNumber *result = [self primitiveLocationLookupType];
	return [result shortValue];
}

- (void)setPrimitiveLocationLookupTypeValue:(short)value_ {
	[self setPrimitiveLocationLookupType:[NSNumber numberWithShort:value_]];
}





@dynamic locationAquired;



- (BOOL)locationAquiredValue {
	NSNumber *result = [self locationAquired];
	return [result boolValue];
}

- (void)setLocationAquiredValue:(BOOL)value_ {
	[self setLocationAquired:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveLocationAquiredValue {
	NSNumber *result = [self primitiveLocationAquired];
	return [result boolValue];
}

- (void)setPrimitiveLocationAquiredValue:(BOOL)value_ {
	[self setPrimitiveLocationAquired:[NSNumber numberWithBool:value_]];
}





@dynamic name;






@dynamic returnVisits;

	
- (NSMutableSet*)returnVisitsSet {
	[self willAccessValueForKey:@"returnVisits"];
	NSMutableSet *result = [self mutableSetValueForKey:@"returnVisits"];
	[self didAccessValueForKey:@"returnVisits"];
	return result;
}
	

@dynamic additionalInformation;

	
- (NSMutableSet*)additionalInformationSet {
	[self willAccessValueForKey:@"additionalInformation"];
	NSMutableSet *result = [self mutableSetValueForKey:@"additionalInformation"];
	[self didAccessValueForKey:@"additionalInformation"];
	return result;
}
	

@dynamic user;

	



@end
