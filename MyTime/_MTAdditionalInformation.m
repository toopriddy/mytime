// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTAdditionalInformation.m instead.

#import "_MTAdditionalInformation.h"

@implementation MTAdditionalInformationID
@end

@implementation _MTAdditionalInformation

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"AdditionalInformation" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"AdditionalInformation";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"AdditionalInformation" inManagedObjectContext:moc_];
}

- (MTAdditionalInformationID*)objectID {
	return (MTAdditionalInformationID*)[super objectID];
}




@dynamic boolean;



- (BOOL)booleanValue {
	NSNumber *result = [self boolean];
	return [result boolValue];
}

- (void)setBooleanValue:(BOOL)value_ {
	[self setBoolean:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveBooleanValue {
	NSNumber *result = [self primitiveBoolean];
	return [result boolValue];
}

- (void)setPrimitiveBooleanValue:(BOOL)value_ {
	[self setPrimitiveBoolean:[NSNumber numberWithBool:value_]];
}





@dynamic value;






@dynamic number;



- (long long)numberValue {
	NSNumber *result = [self number];
	return [result longLongValue];
}

- (void)setNumberValue:(long long)value_ {
	[self setNumber:[NSNumber numberWithLongLong:value_]];
}

- (long long)primitiveNumberValue {
	NSNumber *result = [self primitiveNumber];
	return [result longLongValue];
}

- (void)setPrimitiveNumberValue:(long long)value_ {
	[self setPrimitiveNumber:[NSNumber numberWithLongLong:value_]];
}





@dynamic date;






@dynamic type;

	

@dynamic call;

	





@end
