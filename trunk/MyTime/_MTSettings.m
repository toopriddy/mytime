// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTSettings.m instead.

#import "_MTSettings.h"

@implementation MTSettingsID
@end

@implementation _MTSettings

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Settings";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:moc_];
}

- (MTSettingsID*)objectID {
	return (MTSettingsID*)[super objectID];
}




@dynamic lastApartmentNumber;






@dynamic lastCity;






@dynamic lastHouseNumber;






@dynamic backupEmail;






@dynamic autobackupInterval;



- (int)autobackupIntervalValue {
	NSNumber *result = [self autobackupInterval];
	return [result intValue];
}

- (void)setAutobackupIntervalValue:(int)value_ {
	[self setAutobackupInterval:[NSNumber numberWithInt:value_]];
}

- (int)primitiveAutobackupIntervalValue {
	NSNumber *result = [self primitiveAutobackupInterval];
	return [result intValue];
}

- (void)setPrimitiveAutobackupIntervalValue:(int)value_ {
	[self setPrimitiveAutobackupInterval:[NSNumber numberWithInt:value_]];
}





@dynamic secretaryEmailAddress;






@dynamic lastLattitude;



- (double)lastLattitudeValue {
	NSNumber *result = [self lastLattitude];
	return [result doubleValue];
}

- (void)setLastLattitudeValue:(double)value_ {
	[self setLastLattitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLastLattitudeValue {
	NSNumber *result = [self primitiveLastLattitude];
	return [result doubleValue];
}

- (void)setPrimitiveLastLattitudeValue:(double)value_ {
	[self setPrimitiveLastLattitude:[NSNumber numberWithDouble:value_]];
}





@dynamic lastStreet;






@dynamic lastState;






@dynamic lastLongitude;



- (double)lastLongitudeValue {
	NSNumber *result = [self lastLongitude];
	return [result doubleValue];
}

- (void)setLastLongitudeValue:(double)value_ {
	[self setLastLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLastLongitudeValue {
	NSNumber *result = [self primitiveLastLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveLastLongitudeValue:(double)value_ {
	[self setPrimitiveLastLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic backupShouldIncludeAttachment;



- (BOOL)backupShouldIncludeAttachmentValue {
	NSNumber *result = [self backupShouldIncludeAttachment];
	return [result boolValue];
}

- (void)setBackupShouldIncludeAttachmentValue:(BOOL)value_ {
	[self setBackupShouldIncludeAttachment:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveBackupShouldIncludeAttachmentValue {
	NSNumber *result = [self primitiveBackupShouldIncludeAttachment];
	return [result boolValue];
}

- (void)setPrimitiveBackupShouldIncludeAttachmentValue:(BOOL)value_ {
	[self setPrimitiveBackupShouldIncludeAttachment:[NSNumber numberWithBool:value_]];
}





@dynamic passcode;






@dynamic currentUser;






@dynamic secretaryEmailNotes;






@dynamic lastBackupDate;








@end
