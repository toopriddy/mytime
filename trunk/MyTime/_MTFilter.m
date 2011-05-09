// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTFilter.m instead.

#import "_MTFilter.h"

@implementation MTFilterID
@end

@implementation _MTFilter

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Filter" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Filter";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Filter" inManagedObjectContext:moc_];
}

- (MTFilterID*)objectID {
	return (MTFilterID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"diacriticSensitiveValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"diacriticSensitive"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"typeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"type"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"caseSensitiveValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"caseSensitive"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"listValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"list"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"andValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"and"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"notValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"not"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic diacriticSensitive;



- (BOOL)diacriticSensitiveValue {
	NSNumber *result = [self diacriticSensitive];
	return [result boolValue];
}

- (void)setDiacriticSensitiveValue:(BOOL)value_ {
	[self setDiacriticSensitive:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDiacriticSensitiveValue {
	NSNumber *result = [self primitiveDiacriticSensitive];
	return [result boolValue];
}

- (void)setPrimitiveDiacriticSensitiveValue:(BOOL)value_ {
	[self setPrimitiveDiacriticSensitive:[NSNumber numberWithBool:value_]];
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





@dynamic path;






@dynamic caseSensitive;



- (BOOL)caseSensitiveValue {
	NSNumber *result = [self caseSensitive];
	return [result boolValue];
}

- (void)setCaseSensitiveValue:(BOOL)value_ {
	[self setCaseSensitive:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveCaseSensitiveValue {
	NSNumber *result = [self primitiveCaseSensitive];
	return [result boolValue];
}

- (void)setPrimitiveCaseSensitiveValue:(BOOL)value_ {
	[self setPrimitiveCaseSensitive:[NSNumber numberWithBool:value_]];
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





@dynamic operator;






@dynamic filterEntityName;






@dynamic list;



- (BOOL)listValue {
	NSNumber *result = [self list];
	return [result boolValue];
}

- (void)setListValue:(BOOL)value_ {
	[self setList:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveListValue {
	NSNumber *result = [self primitiveList];
	return [result boolValue];
}

- (void)setPrimitiveListValue:(BOOL)value_ {
	[self setPrimitiveList:[NSNumber numberWithBool:value_]];
}





@dynamic and;



- (BOOL)andValue {
	NSNumber *result = [self and];
	return [result boolValue];
}

- (void)setAndValue:(BOOL)value_ {
	[self setAnd:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveAndValue {
	NSNumber *result = [self primitiveAnd];
	return [result boolValue];
}

- (void)setPrimitiveAndValue:(BOOL)value_ {
	[self setPrimitiveAnd:[NSNumber numberWithBool:value_]];
}





@dynamic value;






@dynamic name;






@dynamic not;



- (BOOL)notValue {
	NSNumber *result = [self not];
	return [result boolValue];
}

- (void)setNotValue:(BOOL)value_ {
	[self setNot:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveNotValue {
	NSNumber *result = [self primitiveNot];
	return [result boolValue];
}

- (void)setPrimitiveNotValue:(BOOL)value_ {
	[self setPrimitiveNot:[NSNumber numberWithBool:value_]];
}





@dynamic parent;

	

@dynamic filters;

	
- (NSMutableSet*)filtersSet {
	[self willAccessValueForKey:@"filters"];
	NSMutableSet *result = [self mutableSetValueForKey:@"filters"];
	[self didAccessValueForKey:@"filters"];
	return result;
}
	

@dynamic displayRule;

	





@end
