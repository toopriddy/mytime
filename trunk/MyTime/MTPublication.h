#import "_MTPublication.h"

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

#define PublicationTypePluralDVDBible			AlternateLocalizedString(@"Bible DVDs", @"Publication Type name")
#define PublicationTypePluralDVDBook			AlternateLocalizedString(@"DVDs", @"Publication Type name")
#define PublicationTypePluralDVDBrochure		AlternateLocalizedString(@"DVD Brochures", @"Publication Type name")
#define PublicationTypePluralDVDNotCount		AlternateLocalizedString(@"DVDs (not counted)", @"Publication Type name") 
#define PublicationTypePluralBook				AlternateLocalizedString(@"Books", @"Publication Type name")
#define PublicationTypePluralBrochure			AlternateLocalizedString(@"Brochures", @"Publication Type name")
#define PublicationTypePluralTwoMagazine		AlternateLocalizedString(@"Magazines", @"Publication Type name")
#define PublicationTypePluralMagazine			AlternateLocalizedString(@"Magazines", @"Publication Type name")
#define PublicationTypePluralTract			AlternateLocalizedString(@"Tracts", @"Publication Type name")
#define PublicationTypePluralCampaignTract	AlternateLocalizedString(@"Campaign Tracts", @"Publication Type name")


@class MTReturnVisit;
@class MTBulkPlacement;

@interface MTPublication : _MTPublication {}
// Custom logic goes here.
+ (MTPublication *)createPublicationForReturnVisit:(MTReturnVisit *)returnVisit;
+ (MTPublication *)createPublicationForBulkPlacement:(MTBulkPlacement *)bulkPlacement;

+ (NSString *)pluralFormForPublicationType:(NSString *)publicationType;

@end
