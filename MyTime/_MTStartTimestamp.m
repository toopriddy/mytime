// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTStartTimestamp.m instead.

#import "_MTStartTimestamp.h"

@implementation MTStartTimestampID
@end

@implementation _MTStartTimestamp

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"StartTimestamp" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"StartTimestamp";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"StartTimestamp" inManagedObjectContext:moc_];
}

- (MTStartTimestampID*)objectID {
	return (MTStartTimestampID*)[super objectID];
}




@dynamic type;






@dynamic date;






@dynamic user;

	



@end
