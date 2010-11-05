// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTSettings.h instead.

#import <CoreData/CoreData.h>



























@interface MTSettingsID : NSManagedObjectID {}
@end

@interface _MTSettings : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTSettingsID*)objectID;



@property (nonatomic, retain) NSNumber *lastLongitude;

@property double lastLongitudeValue;
- (double)lastLongitudeValue;
- (void)setLastLongitudeValue:(double)value_;

//- (BOOL)validateLastLongitude:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *thirdViewTitle;

//- (BOOL)validateThirdViewTitle:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *lastStreet;

//- (BOOL)validateLastStreet:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *mainAlertSheetShown;

@property BOOL mainAlertSheetShownValue;
- (BOOL)mainAlertSheetShownValue;
- (void)setMainAlertSheetShownValue:(BOOL)value_;

//- (BOOL)validateMainAlertSheetShown:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *statisticsAlertSheetShown;

@property BOOL statisticsAlertSheetShownValue;
- (BOOL)statisticsAlertSheetShownValue;
- (void)setStatisticsAlertSheetShownValue:(BOOL)value_;

//- (BOOL)validateStatisticsAlertSheetShown:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *fourthViewTitle;

//- (BOOL)validateFourthViewTitle:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *lastApartmentNumber;

//- (BOOL)validateLastApartmentNumber:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *lastState;

//- (BOOL)validateLastState:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *timeAlertSheetShown;

@property BOOL timeAlertSheetShownValue;
- (BOOL)timeAlertSheetShownValue;
- (void)setTimeAlertSheetShownValue:(BOOL)value_;

//- (BOOL)validateTimeAlertSheetShown:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *passcode;

//- (BOOL)validatePasscode:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *lastBackupDate;

//- (BOOL)validateLastBackupDate:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *secondViewTitle;

//- (BOOL)validateSecondViewTitle:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *lastHouseNumber;

//- (BOOL)validateLastHouseNumber:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *backupEmail;

//- (BOOL)validateBackupEmail:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *backupShouldIncludeAttachment;

@property BOOL backupShouldIncludeAttachmentValue;
- (BOOL)backupShouldIncludeAttachmentValue;
- (void)setBackupShouldIncludeAttachmentValue:(BOOL)value_;

//- (BOOL)validateBackupShouldIncludeAttachment:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *currentUser;

//- (BOOL)validateCurrentUser:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *lastCity;

//- (BOOL)validateLastCity:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *autobackupInterval;

@property int autobackupIntervalValue;
- (int)autobackupIntervalValue;
- (void)setAutobackupIntervalValue:(int)value_;

//- (BOOL)validateAutobackupInterval:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *lastLattitude;

@property double lastLattitudeValue;
- (double)lastLattitudeValue;
- (void)setLastLattitudeValue:(double)value_;

//- (BOOL)validateLastLattitude:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *bulkLiteratureAlertSheetShown;

@property BOOL bulkLiteratureAlertSheetShownValue;
- (BOOL)bulkLiteratureAlertSheetShownValue;
- (void)setBulkLiteratureAlertSheetShownValue:(BOOL)value_;

//- (BOOL)validateBulkLiteratureAlertSheetShown:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *backupShouldCompressLink;

@property BOOL backupShouldCompressLinkValue;
- (BOOL)backupShouldCompressLinkValue;
- (void)setBackupShouldCompressLinkValue:(BOOL)value_;

//- (BOOL)validateBackupShouldCompressLink:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *existingCallAlertSheetShown;

@property BOOL existingCallAlertSheetShownValue;
- (BOOL)existingCallAlertSheetShownValue;
- (void)setExistingCallAlertSheetShownValue:(BOOL)value_;

//- (BOOL)validateExistingCallAlertSheetShown:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *firstViewTitle;

//- (BOOL)validateFirstViewTitle:(id*)value_ error:(NSError**)error_;




@end

@interface _MTSettings (CoreDataGeneratedAccessors)

@end

@interface _MTSettings (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveLastLongitude;
- (void)setPrimitiveLastLongitude:(NSNumber*)value;

- (double)primitiveLastLongitudeValue;
- (void)setPrimitiveLastLongitudeValue:(double)value_;


- (NSString*)primitiveThirdViewTitle;
- (void)setPrimitiveThirdViewTitle:(NSString*)value;


- (NSString*)primitiveLastStreet;
- (void)setPrimitiveLastStreet:(NSString*)value;


- (NSNumber*)primitiveMainAlertSheetShown;
- (void)setPrimitiveMainAlertSheetShown:(NSNumber*)value;

- (BOOL)primitiveMainAlertSheetShownValue;
- (void)setPrimitiveMainAlertSheetShownValue:(BOOL)value_;


- (NSNumber*)primitiveStatisticsAlertSheetShown;
- (void)setPrimitiveStatisticsAlertSheetShown:(NSNumber*)value;

- (BOOL)primitiveStatisticsAlertSheetShownValue;
- (void)setPrimitiveStatisticsAlertSheetShownValue:(BOOL)value_;


- (NSString*)primitiveFourthViewTitle;
- (void)setPrimitiveFourthViewTitle:(NSString*)value;


- (NSString*)primitiveLastApartmentNumber;
- (void)setPrimitiveLastApartmentNumber:(NSString*)value;


- (NSString*)primitiveLastState;
- (void)setPrimitiveLastState:(NSString*)value;


- (NSNumber*)primitiveTimeAlertSheetShown;
- (void)setPrimitiveTimeAlertSheetShown:(NSNumber*)value;

- (BOOL)primitiveTimeAlertSheetShownValue;
- (void)setPrimitiveTimeAlertSheetShownValue:(BOOL)value_;


- (NSString*)primitivePasscode;
- (void)setPrimitivePasscode:(NSString*)value;


- (NSDate*)primitiveLastBackupDate;
- (void)setPrimitiveLastBackupDate:(NSDate*)value;


- (NSString*)primitiveSecondViewTitle;
- (void)setPrimitiveSecondViewTitle:(NSString*)value;


- (NSString*)primitiveLastHouseNumber;
- (void)setPrimitiveLastHouseNumber:(NSString*)value;


- (NSString*)primitiveBackupEmail;
- (void)setPrimitiveBackupEmail:(NSString*)value;


- (NSNumber*)primitiveBackupShouldIncludeAttachment;
- (void)setPrimitiveBackupShouldIncludeAttachment:(NSNumber*)value;

- (BOOL)primitiveBackupShouldIncludeAttachmentValue;
- (void)setPrimitiveBackupShouldIncludeAttachmentValue:(BOOL)value_;


- (NSString*)primitiveCurrentUser;
- (void)setPrimitiveCurrentUser:(NSString*)value;


- (NSString*)primitiveLastCity;
- (void)setPrimitiveLastCity:(NSString*)value;


- (NSNumber*)primitiveAutobackupInterval;
- (void)setPrimitiveAutobackupInterval:(NSNumber*)value;

- (int)primitiveAutobackupIntervalValue;
- (void)setPrimitiveAutobackupIntervalValue:(int)value_;


- (NSNumber*)primitiveLastLattitude;
- (void)setPrimitiveLastLattitude:(NSNumber*)value;

- (double)primitiveLastLattitudeValue;
- (void)setPrimitiveLastLattitudeValue:(double)value_;


- (NSNumber*)primitiveBulkLiteratureAlertSheetShown;
- (void)setPrimitiveBulkLiteratureAlertSheetShown:(NSNumber*)value;

- (BOOL)primitiveBulkLiteratureAlertSheetShownValue;
- (void)setPrimitiveBulkLiteratureAlertSheetShownValue:(BOOL)value_;


- (NSNumber*)primitiveBackupShouldCompressLink;
- (void)setPrimitiveBackupShouldCompressLink:(NSNumber*)value;

- (BOOL)primitiveBackupShouldCompressLinkValue;
- (void)setPrimitiveBackupShouldCompressLinkValue:(BOOL)value_;


- (NSNumber*)primitiveExistingCallAlertSheetShown;
- (void)setPrimitiveExistingCallAlertSheetShown:(NSNumber*)value;

- (BOOL)primitiveExistingCallAlertSheetShownValue;
- (void)setPrimitiveExistingCallAlertSheetShownValue:(BOOL)value_;


- (NSString*)primitiveFirstViewTitle;
- (void)setPrimitiveFirstViewTitle:(NSString*)value;



@end
