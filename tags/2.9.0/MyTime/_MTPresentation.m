// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTPresentation.m instead.

#import "_MTPresentation.h"

@implementation MTPresentationID
@end

@implementation _MTPresentation

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Presentation" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Presentation";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Presentation" inManagedObjectContext:moc_];
}

- (MTPresentationID*)objectID {
	return (MTPresentationID*)[super objectID];
}




@dynamic notes;






@dynamic downloaded;



- (BOOL)downloadedValue {
	NSNumber *result = [self downloaded];
	return [result boolValue];
}

- (void)setDownloadedValue:(BOOL)value_ {
	[self setDownloaded:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDownloadedValue {
	NSNumber *result = [self primitiveDownloaded];
	return [result boolValue];
}

- (void)setPrimitiveDownloadedValue:(BOOL)value_ {
	[self setPrimitiveDownloaded:[NSNumber numberWithBool:value_]];
}





@dynamic user;

	



@end
