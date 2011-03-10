// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTTimeType.m instead.

#import "_MTTimeType.h"

@implementation MTTimeTypeID
@end

@implementation _MTTimeType

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TimeType" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TimeType";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TimeType" inManagedObjectContext:moc_];
}

- (MTTimeTypeID*)objectID {
	return (MTTimeTypeID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"deleteableValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"deleteable"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic name;






@dynamic imageFileName;






@dynamic deleteable;



- (BOOL)deleteableValue {
	NSNumber *result = [self deleteable];
	return [result boolValue];
}

- (void)setDeleteableValue:(BOOL)value_ {
	[self setDeleteable:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDeleteableValue {
	NSNumber *result = [self primitiveDeleteable];
	return [result boolValue];
}

- (void)setPrimitiveDeleteableValue:(BOOL)value_ {
	[self setPrimitiveDeleteable:[NSNumber numberWithBool:value_]];
}





@dynamic startTimerDate;






@dynamic timeEntries;

	
- (NSMutableSet*)timeEntriesSet {
	[self willAccessValueForKey:@"timeEntries"];
	NSMutableSet *result = [self mutableSetValueForKey:@"timeEntries"];
	[self didAccessValueForKey:@"timeEntries"];
	return result;
}
	

@dynamic user;

	





@end
