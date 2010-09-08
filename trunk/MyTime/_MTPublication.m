// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTPublication.m instead.

#import "_MTPublication.h"

@implementation MTPublicationID
@end

@implementation _MTPublication

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Publication" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Publication";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Publication" inManagedObjectContext:moc_];
}

- (MTPublicationID*)objectID {
	return (MTPublicationID*)[super objectID];
}




@dynamic month;



- (short)monthValue {
	NSNumber *result = [self month];
	return [result shortValue];
}

- (void)setMonthValue:(short)value_ {
	[self setMonth:[NSNumber numberWithShort:value_]];
}

- (short)primitiveMonthValue {
	NSNumber *result = [self primitiveMonth];
	return [result shortValue];
}

- (void)setPrimitiveMonthValue:(short)value_ {
	[self setPrimitiveMonth:[NSNumber numberWithShort:value_]];
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






@dynamic year;



- (short)yearValue {
	NSNumber *result = [self year];
	return [result shortValue];
}

- (void)setYearValue:(short)value_ {
	[self setYear:[NSNumber numberWithShort:value_]];
}

- (short)primitiveYearValue {
	NSNumber *result = [self primitiveYear];
	return [result shortValue];
}

- (void)setPrimitiveYearValue:(short)value_ {
	[self setPrimitiveYear:[NSNumber numberWithShort:value_]];
}





@dynamic day;



- (short)dayValue {
	NSNumber *result = [self day];
	return [result shortValue];
}

- (void)setDayValue:(short)value_ {
	[self setDay:[NSNumber numberWithShort:value_]];
}

- (short)primitiveDayValue {
	NSNumber *result = [self primitiveDay];
	return [result shortValue];
}

- (void)setPrimitiveDayValue:(short)value_ {
	[self setPrimitiveDay:[NSNumber numberWithShort:value_]];
}





@dynamic title;






@dynamic returnVisit;

	

@dynamic newRelationship;

	



@end
