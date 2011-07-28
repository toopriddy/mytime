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
	
	if ([key isEqualToString:@"typeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"type"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"diacriticInsensitiveValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"diacriticInsensitive"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"caseInsensitiveValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"caseInsensitive"];
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




@dynamic filterEntityName;






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






@dynamic diacriticInsensitive;



- (BOOL)diacriticInsensitiveValue {
	NSNumber *result = [self diacriticInsensitive];
	return [result boolValue];
}

- (void)setDiacriticInsensitiveValue:(BOOL)value_ {
	[self setDiacriticInsensitive:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDiacriticInsensitiveValue {
	NSNumber *result = [self primitiveDiacriticInsensitive];
	return [result boolValue];
}

- (void)setPrimitiveDiacriticInsensitiveValue:(BOOL)value_ {
	[self setPrimitiveDiacriticInsensitive:[NSNumber numberWithBool:value_]];
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






@dynamic caseInsensitive;



- (BOOL)caseInsensitiveValue {
	NSNumber *result = [self caseInsensitive];
	return [result boolValue];
}

- (void)setCaseInsensitiveValue:(BOOL)value_ {
	[self setCaseInsensitive:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveCaseInsensitiveValue {
	NSNumber *result = [self primitiveCaseInsensitive];
	return [result boolValue];
}

- (void)setPrimitiveCaseInsensitiveValue:(BOOL)value_ {
	[self setPrimitiveCaseInsensitive:[NSNumber numberWithBool:value_]];
}





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






@dynamic untranslatedValueTitle;






@dynamic untranslatedName;






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
