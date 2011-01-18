// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTAdditionalInformationType.m instead.

#import "_MTAdditionalInformationType.h"

@implementation MTAdditionalInformationTypeID
@end

@implementation _MTAdditionalInformationType

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"AdditionalInformationType" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"AdditionalInformationType";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"AdditionalInformationType" inManagedObjectContext:moc_];
}

- (MTAdditionalInformationTypeID*)objectID {
	return (MTAdditionalInformationTypeID*)[super objectID];
}




@dynamic type;



- (short)typeValue {
	NSNumber *result = [self type];
	return [result shortValue];
}

- (void)setTypeValue:(short)value_ {
	[self setType:[NSNumber numberWithShort:value_]];
}

- (short)primitiveTypeValue {
	NSNumber *result = [self primitiveType];
	return [result shortValue];
}

- (void)setPrimitiveTypeValue:(short)value_ {
	[self setPrimitiveType:[NSNumber numberWithShort:value_]];
}





@dynamic name;






@dynamic alwaysShown;



- (BOOL)alwaysShownValue {
	NSNumber *result = [self alwaysShown];
	return [result boolValue];
}

- (void)setAlwaysShownValue:(BOOL)value_ {
	[self setAlwaysShown:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveAlwaysShownValue {
	NSNumber *result = [self primitiveAlwaysShown];
	return [result boolValue];
}

- (void)setPrimitiveAlwaysShownValue:(BOOL)value_ {
	[self setPrimitiveAlwaysShown:[NSNumber numberWithBool:value_]];
}





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





@dynamic hidden;



- (BOOL)hiddenValue {
	NSNumber *result = [self hidden];
	return [result boolValue];
}

- (void)setHiddenValue:(BOOL)value_ {
	[self setHidden:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveHiddenValue {
	NSNumber *result = [self primitiveHidden];
	return [result boolValue];
}

- (void)setPrimitiveHiddenValue:(BOOL)value_ {
	[self setPrimitiveHidden:[NSNumber numberWithBool:value_]];
}





@dynamic user;

	

@dynamic additionalInformation;

	
- (NSMutableSet*)additionalInformationSet {
	[self willAccessValueForKey:@"additionalInformation"];
	NSMutableSet *result = [self mutableSetValueForKey:@"additionalInformation"];
	[self didAccessValueForKey:@"additionalInformation"];
	return result;
}
	

@dynamic multipleChoices;

	
- (NSMutableSet*)multipleChoicesSet {
	[self willAccessValueForKey:@"multipleChoices"];
	NSMutableSet *result = [self mutableSetValueForKey:@"multipleChoices"];
	[self didAccessValueForKey:@"multipleChoices"];
	return result;
}
	



@end
