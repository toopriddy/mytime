// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTStatisticsAdjustment.m instead.

#import "_MTStatisticsAdjustment.h"

@implementation MTStatisticsAdjustmentID
@end

@implementation _MTStatisticsAdjustment

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"StatisticsAdjustment" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"StatisticsAdjustment";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"StatisticsAdjustment" inManagedObjectContext:moc_];
}

- (MTStatisticsAdjustmentID*)objectID {
	return (MTStatisticsAdjustmentID*)[super objectID];
}




@dynamic adjustment;



- (long long)adjustmentValue {
	NSNumber *result = [self adjustment];
	return [result longLongValue];
}

- (void)setAdjustmentValue:(long long)value_ {
	[self setAdjustment:[NSNumber numberWithLongLong:value_]];
}

- (long long)primitiveAdjustmentValue {
	NSNumber *result = [self primitiveAdjustment];
	return [result longLongValue];
}

- (void)setPrimitiveAdjustmentValue:(long long)value_ {
	[self setPrimitiveAdjustment:[NSNumber numberWithLongLong:value_]];
}





@dynamic type;






@dynamic timestamp;



- (int)timestampValue {
	NSNumber *result = [self timestamp];
	return [result intValue];
}

- (void)setTimestampValue:(int)value_ {
	[self setTimestamp:[NSNumber numberWithInt:value_]];
}

- (int)primitiveTimestampValue {
	NSNumber *result = [self primitiveTimestamp];
	return [result intValue];
}

- (void)setPrimitiveTimestampValue:(int)value_ {
	[self setPrimitiveTimestamp:[NSNumber numberWithInt:value_]];
}





@dynamic user;

	





@end
