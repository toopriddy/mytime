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






@dynamic uppercaseFirstLetterOfName;






@dynamic apartmentNumber;






@dynamic street;






@dynamic longitude;






@dynamic state;






@dynamic dateSortedSectionIndex;



- (short)dateSortedSectionIndexValue {
	NSNumber *result = [self dateSortedSectionIndex];
	return [result shortValue];
}

- (void)setDateSortedSectionIndexValue:(short)value_ {
	[self setDateSortedSectionIndex:[NSNumber numberWithShort:value_]];
}

- (short)primitiveDateSortedSectionIndexValue {
	NSNumber *result = [self primitiveDateSortedSectionIndex];
	return [result shortValue];
}

- (void)setPrimitiveDateSortedSectionIndexValue:(short)value_ {
	[self setPrimitiveDateSortedSectionIndex:[NSNumber numberWithShort:value_]];
}





@dynamic mostRecentReturnVisitDate;






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






@dynamic lattitude;






@dynamic name;






@dynamic locationLookupType;






@dynamic deletedCall;



- (BOOL)deletedCallValue {
	NSNumber *result = [self deletedCall];
	return [result boolValue];
}

- (void)setDeletedCallValue:(BOOL)value_ {
	[self setDeletedCall:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDeletedCallValue {
	NSNumber *result = [self primitiveDeletedCall];
	return [result boolValue];
}

- (void)setPrimitiveDeletedCallValue:(BOOL)value_ {
	[self setPrimitiveDeletedCall:[NSNumber numberWithBool:value_]];
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





@dynamic uppercaseFirstLetterOfStreet;






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
