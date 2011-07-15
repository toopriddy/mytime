// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTTimeEntry.m instead.

#import "_MTTimeEntry.h"

@implementation MTTimeEntryID
@end

@implementation _MTTimeEntry

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TimeEntry" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TimeEntry";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TimeEntry" inManagedObjectContext:moc_];
}

- (MTTimeEntryID*)objectID {
	return (MTTimeEntryID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"minutesValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"minutes"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic notes;






@dynamic minutes;



- (long long)minutesValue {
	NSNumber *result = [self minutes];
	return [result longLongValue];
}

- (void)setMinutesValue:(long long)value_ {
	[self setMinutes:[NSNumber numberWithLongLong:value_]];
}

- (long long)primitiveMinutesValue {
	NSNumber *result = [self primitiveMinutes];
	return [result longLongValue];
}

- (void)setPrimitiveMinutesValue:(long long)value_ {
	[self setPrimitiveMinutes:[NSNumber numberWithLongLong:value_]];
}





@dynamic date;






@dynamic type;

	





@end
