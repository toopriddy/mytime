#undef NSLocalizedString
#undef NSLocalizedStringFromTable
#undef NSLocalizedStringFromTableInBundle
#undef NSLocalizedStringWithDefaultValue
#define NSLocalizedString(key, comment) (key)
#define NSLocalizedStringFromTable(key, tbl, comment) (key)
#define NSLocalizedStringFromTableInBundle(key, tbl, bundle, comment) (key)
#define NSLocalizedStringWithDefaultValue(key, tbl, bundle, val, comment) (key)
