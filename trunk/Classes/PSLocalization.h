//
//  PSLocalization.h
//
//  Created by Brent Priddy on 9/14/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

extern NSBundle *psLocalizationBundle;
#undef NSLocalizedString
#undef NSLocalizedStringFromTable
#undef NSLocalizedStringFromTableInBundle
#undef NSLocalizedStringWithDefaultValue
#define NSLocalizedString(key, comment)										[psLocalizationBundle localizedStringForKey:(key) value:@"" table:nil]
#define NSLocalizedStringFromTable(key, tbl, comment)						[psLocalizationBundle localizedStringForKey:(key) value:@"" table:(tbl)]
#define NSLocalizedStringFromTableInBundle(key, tbl, bundle, comment)		[psLocalizationBundle localizedStringForKey:(key) value:@"" table:(tbl)]
#define NSLocalizedStringWithDefaultValue(key, tbl, bundle, val, comment)	[psLocalizationBundle localizedStringForKey:(key) value:(val) table:(tbl)]


@interface PSLocalization : NSObject
{
}

+ (void)initalizeCustomLocalization;
+ (NSBundle *)localizationBundle;

@end
