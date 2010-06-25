//
//  Settings.h
//  MyTime
//
//  Created by Brent Priddy on 7/24/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
//multiple users
extern NSString * const SettingsCalls;
//multiple users
extern NSString * const SettingsDeletedCalls;

	extern NSString * const CallName;
	extern NSString * const CallStreetNumber;
	extern NSString * const CallApartmentNumber;
	extern NSString * const CallStreet;
	extern NSString * const CallCity;
	extern NSString * const CallState;
	extern NSString * const CallLattitudeLongitude;
	extern NSString * const CallLocationType;
	extern NSString * const CallLocationTypeManual;
	extern NSString * const CallLocationTypeGoogleMaps;
	extern NSString * const CallLocationTypeDoNotShow;


	extern NSString * const CallMetadata;
	extern NSString * const CallMetadataName;
	extern NSString * const CallMetadataType;
	extern NSString * const CallMetadataData;
	extern NSString * const CallMetadataValue;
	extern NSString * const CallReturnVisits;
		extern NSString * const CallReturnVisitNotes;
		extern NSString * const CallReturnVisitDate;
		extern NSString * const CallReturnVisitType;
		extern NSString * const CallReturnVisitPublications;
		extern NSString * const CallReturnVisitPublicationTitle;
		extern NSString * const CallReturnVisitPublicationType;
		extern NSString * const CallReturnVisitPublicationName;
		extern NSString * const CallReturnVisitPublicationYear;
		extern NSString * const CallReturnVisitPublicationMonth;
		extern NSString * const CallReturnVisitPublicationDay;

		extern NSString * const CallReturnVisitTypeTransferedStudy;
		extern NSString * const CallReturnVisitTypeTransferedNotAtHome;
		extern NSString * const CallReturnVisitTypeTransferedReturnVisit;
		extern NSString * const CallReturnVisitTypeReturnVisit;
		extern NSString * const CallReturnVisitTypeStudy;
		extern NSString * const CallReturnVisitTypeNotAtHome;

//multiple users
extern NSString * const SettingsBulkLiterature;
	extern NSString * const BulkLiteratureDate;
	extern NSString * const BulkLiteratureArray;
		extern NSString * const BulkLiteratureArrayCount;
		extern NSString * const BulkLiteratureArrayTitle;
		extern NSString * const BulkLiteratureArrayType;
		extern NSString * const BulkLiteratureArrayName;
		extern NSString * const BulkLiteratureArrayYear;
		extern NSString * const BulkLiteratureArrayMonth;
		extern NSString * const BulkLiteratureArrayDay;

#define AlternateLocalizedString(key, comment) (key)
#define PublicationTypeHeading			@""
#define PublicationTypeDVDBible			AlternateLocalizedString(@"Bible DVD", @"Publication Type name")
#define PublicationTypeDVDBook			AlternateLocalizedString(@"DVD", @"Publication Type name")
#define PublicationTypeDVDBrochure		AlternateLocalizedString(@"DVD Brochure", @"Publication Type name")
#define PublicationTypeDVDNotCount		AlternateLocalizedString(@"DVD (not counted)", @"Publication Type name") 
#define PublicationTypeBook				AlternateLocalizedString(@"Book", @"Publication Type name")
#define PublicationTypeBrochure			AlternateLocalizedString(@"Brochure", @"Publication Type name")
#define PublicationTypeTwoMagazine		AlternateLocalizedString(@"TwoMagazine", @"Publication Type name")
#define PublicationTypeMagazine			AlternateLocalizedString(@"Magazine", @"Publication Type name")
#define PublicationTypeTract			AlternateLocalizedString(@"Tract", @"Publication Type name")
#define PublicationTypeCampaignTract	AlternateLocalizedString(@"Campaign Tract", @"Publication Type name")



extern NSString * const SettingsLastLattitude;
extern NSString * const SettingsLastLongitude;

extern NSString * const SettingsLastCallStreetNumber;
extern NSString * const SettingsLastCallApartmentNumber;
extern NSString * const SettingsLastCallStreet;
extern NSString * const SettingsLastCallCity;
extern NSString * const SettingsLastCallState;
extern NSString * const SettingsCurrentButtonBarName;

//multiple users
extern NSString * const SettingsPreferredMetadata;
//multiple users
extern NSString * const SettingsSortedByMetadata;

extern NSString * const SettingsMetadata;
//multiple users
extern NSString * const SettingsOtherMetadata;
	extern NSString * const SettingsMetadataName;
	extern NSString * const SettingsMetadataType;
	extern NSString * const SettingsMetadataValue;
	extern NSString * const SettingsMetadataData;
		// for the MetadataType of multipleChoice, this is an array of NSStrings

//multiple users
extern NSString * const SettingsMonthDisplayCount;

extern NSString * const SettingsMultipleUsersCurrentUser;
extern NSString * const SettingsMultipleUsers;
	extern NSString * const SettingsMultipleUsersName;

extern NSString * const SettingsTimeAlertSheetShown;
extern NSString * const SettingsStatisticsAlertSheetShown;
extern NSString * const SettingsSecretaryEmailAddress;
extern NSString * const SettingsSecretaryEmailNotes;

extern NSString * const SettingsMainAlertSheetShown;
extern NSString * const SettingsBulkLiteratureAlertSheetShown;
extern NSString * const SettingsExistingCallAlertSheetShown;

//multiple users
extern NSString * const SettingsQuickNotes;

//multiple users
extern NSString * const SettingsTimeStartDate;
//multiple users
extern NSString * const SettingsRBCTimeStartDate;
//multiple users
extern NSString * const SettingsTimeEntries;
//multiple users
extern NSString * const SettingsRBCTimeEntries;
	extern NSString * const SettingsTimeEntryDate;
	extern NSString * const SettingsTimeEntryMinutes;

//multiple users
extern NSString * const SettingsStatisticsAdjustments;

extern NSString * const SettingsPasscode;

extern NSString * const SettingsLastBackupDate;
extern NSString * const SettingsAutoBackupInterval;
extern NSString * const SettingsBackupEmailAddress;
extern NSString * const SettingsBackupEmailDontIncludeAttachment;
extern NSString * const SettingsBackupEmailUncompressedLink;

extern NSString * const SettingsDonated;
extern NSString * const SettingsFirstView;
extern NSString * const SettingsSecondView;
extern NSString * const SettingsThirdView;
extern NSString * const SettingsFourthView;

//multiple users
extern NSString * const SettingsNotAtHomeTerritories;
	extern NSString * const NotAtHomeTerritoryName;
	extern NSString * const NotAtHomeTerritoryOwnerId;
	extern NSString * const NotAtHomeTerritoryOwnerEmailId;
	extern NSString * const NotAtHomeTerritoryOwnerEmailAddress;
	extern NSString * const NotAtHomeTerritoryStreets;
	extern NSString * const NotAtHomeTerritoryCity;
	extern NSString * const NotAtHomeTerritoryState;
	extern NSString * const NotAtHomeTerritoryNotes;
		extern NSString * const NotAtHomeTerritoryStreetName;
		extern NSString * const NotAtHomeTerritoryStreetDate;
		extern NSString * const NotAtHomeTerritoryStreetNotes;
		extern NSString * const NotAtHomeTerritoryHouses;
			extern NSString * const NotAtHomeTerritoryHouseNumber;
			extern NSString * const NotAtHomeTerritoryHouseApartment;
			extern NSString * const NotAtHomeTerritoryHouseNotes;
			extern NSString * const NotAtHomeTerritoryHouseAttempts;


//multiple users
extern NSString * const SettingsPublisherType;

	extern NSString * const PublisherTypePublisher;
	extern NSString * const PublisherTypeAuxilliaryPioneer;
	extern NSString * const PublisherTypePioneer;
	extern NSString * const PublisherTypeSpecialPioneer;
	extern NSString * const PublisherTypeTravelingServant;


// these are in the UserDefaults

extern NSString *const UserDefaultsClearMapCache;
extern NSString *const UserDefaultsEmailBackupInstantly;
extern NSString *const UserDefaultsRemovePasscode;



// notifications

extern NSString *const SettingsNotificationUserChanged;


#define REVERSE_GEOCODING_ACCURACY 70

extern int debugging;

#define DEBUG(a) if(debugging) { a }
#define VERBOSE(a) if(debugging > 1) { a }
#define VERY_VERBOSE(a) if(debugging > 2) { a }

NSString *emailFormattedStringForCall(NSDictionary *_call);
NSString *emailFormattedStringForNotAtHomeTerritory(NSDictionary *territory);

@interface Settings : NSObject 
{
	NSMutableDictionary *settings;
	NSMutableDictionary *userSettings;
}
+ (Settings *)sharedInstance;
+ (id)initWithZone:(NSZone *)zone;
+ (BOOL)isInitialized;

+ (MFMailComposeViewController *)sendEmailBackup;
+ (MFMailComposeViewController *)sendPrintableEmailBackup;

+ (void)formatStreetNumber:(NSString *)houseNumber apartment:(NSString *)apartmentNumber topLine:(NSMutableString *)top;
+ (void)formatStreetNumber:(NSString *)houseNumber apartment:(NSString *)apartmentNumber street:(NSString *)street topLine:(NSMutableString *)top;
+ (void)formatStreetNumber:(NSString *)houseNumber apartment:(NSString *)apartmentNumber street:(NSString *)street city:(NSString *)city state:(NSString *)state topLine:(NSMutableString *)top bottomLine:(NSMutableString *)bottom;

+ (NSString *)filename;
- (void)readData;
- (void)saveData;

- (void)changeSettingsToUser:(NSString *)username save:(BOOL)save;

- (id)copyWithZone:(NSZone *)zone;
- (id)retain;
- (unsigned)retainCount;
- (void)release;
- (id)autorelease;

@property (nonatomic, retain) NSMutableDictionary *userSettings;
@property (nonatomic, retain) NSMutableDictionary *settings;
@end
