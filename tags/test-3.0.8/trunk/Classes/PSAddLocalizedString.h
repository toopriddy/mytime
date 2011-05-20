#undef NSLocalizedString
#undef NSLocalizedStringFromTable
#undef NSLocalizedStringFromTableInBundle
#undef NSLocalizedStringWithDefaultValue
#define NSLocalizedString(key, comment)										[psLocalizationBundle localizedStringForKey:(key) value:@"" table:nil]
#define NSLocalizedStringFromTable(key, tbl, comment)						[psLocalizationBundle localizedStringForKey:(key) value:@"" table:(tbl)]
#define NSLocalizedStringFromTableInBundle(key, tbl, bundle, comment)		[psLocalizationBundle localizedStringForKey:(key) value:@"" table:(tbl)]
#define NSLocalizedStringWithDefaultValue(key, tbl, bundle, val, comment)	[psLocalizationBundle localizedStringForKey:(key) value:(val) table:(tbl)]
