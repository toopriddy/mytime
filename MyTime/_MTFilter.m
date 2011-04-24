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
	
	if ([key isEqualToString:@"andValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"and"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"typeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"type"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"listValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"list"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
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





@dynamic value;






@dynamic operator;






@dynamic name;






@dynamic filterEntityName;






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
