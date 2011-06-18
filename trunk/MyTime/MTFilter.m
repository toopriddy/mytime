#import "MTFilter.h"
#import "MTDisplayRule.h"
#import "MTCall.h"
#import "MTUser.h"
#import "MTReturnVisit.h"
#import "PSLocalization.h"

#define AlternateLocalizedString(key, comment) (key)

NSString * const MTFilterGroupName = @"group";
NSString * const MTFilterGroupArray = @"array";

NSString * const MTFilterUntranslatedName = @"title";
NSString * const MTFilterEntityName = @"entityName";
NSString * const MTFilterPath = @"path";
NSString * const MTFilterSectionIndexPath = @"sectionIndexPath";
NSString * const MTFilterSubFilters = @"filters";
NSString * const MTFilterType = @"type";
NSString * const MTFilterValues = @"values";
NSString * const MTFilterValuesUntranslatedTitles = @"valueTitles";

NSString *translate(NSString *value)
{
	return [[PSLocalization localizationBundle] localizedStringForKey:value value:value table:@""];
}


@implementation MTFilter

// Custom logic goes here.

+ (MTFilter *)createFilterForDisplayRule:(MTDisplayRule *)displayRule
{	
	MTFilter *filter = [NSEntityDescription insertNewObjectForEntityForName:[MTFilter entityName]
													 inManagedObjectContext:displayRule.managedObjectContext];
	filter.orderValue = 0; // we are using the order to seperate calls and when reordering these will be mobed halfway between displayRules.
	filter.displayRule = displayRule;
	filter.filterEntityName = [MTCall entityName];
	filter.listValue = YES;
	filter.andValue = YES;

	return filter;
}

+ (MTFilter *)createFilterForFilter:(MTFilter *)parentFilter
{
	// first find the highefilterst ordering index
	double order = 0;
	
	for(MTFilter *filter in parentFilter.filters)
	{
		double filterOrder = filter.orderValue;
		if (filterOrder > order)
			order = filterOrder;
	}
	
	
	MTFilter *filter = [NSEntityDescription insertNewObjectForEntityForName:[MTFilter entityName]
													 inManagedObjectContext:parentFilter.managedObjectContext];
	filter.orderValue = order + 1; // we are using the order to seperate calls and when reordering these will be mobed halfway between displayRules.
	filter.parent = parentFilter;
	return filter;
}

+ (void)addStudiesFilter:(MTFilter *)filter
{
	MTFilter *newFilter = [MTFilter createFilterForFilter:filter];
	newFilter.listValue = YES;
	newFilter.filterEntityName = [MTReturnVisit entityName];
	newFilter.andValue = YES;
	newFilter.untranslatedName = @"User";
	newFilter.path = @"returnVisits";
	newFilter.untranslatedName = AlternateLocalizedString(@"Return Visit Information", @"Title for the Display Rules 'pick a sort rule' screen");

	newFilter = [MTFilter createFilterForFilter:newFilter];
	newFilter.listValue = NO;
	newFilter.filterEntityName = [MTReturnVisit entityName];
	newFilter.untranslatedName = AlternateLocalizedString(@"Type", @"Title for the Display Rules 'pick a sort rule' screen");
	newFilter.path = @"type";
	newFilter.operator = @"==";
	newFilter.untranslatedValueTitle = CallReturnVisitTypeStudy;
	newFilter.value = CallReturnVisitTypeStudy;
}

+ (void)addDeletedFilter:(MTFilter *)filter deleted:(BOOL)deleted
{
	MTFilter *newFilter = [MTFilter createFilterForFilter:filter];
	newFilter.listValue = NO;
	newFilter.filterEntityName = [MTCall entityName];
	newFilter.untranslatedName = AlternateLocalizedString(@"Deleted", @"Title for the Display Rules 'pick a sort rule' screen");
	newFilter.path = @"deletedCall";
	newFilter.operator = @"==";
	newFilter.value = deleted ? @"YES" : @"NO";
}

+ (NSArray *)displayEntriesForReturnVisits
{
	NSArray *typeArray = [NSArray arrayWithObjects:CallReturnVisitTypeInitialVisit, CallReturnVisitTypeReturnVisit, CallReturnVisitTypeStudy, CallReturnVisitTypeNotAtHome, CallReturnVisitTypeTransferedStudy, CallReturnVisitTypeTransferedNotAtHome, CallReturnVisitTypeTransferedInitialVisit, CallReturnVisitTypeTransferedReturnVisit, nil];
	NSString *entityName = [MTReturnVisit entityName];
	NSArray *returnArray = 
	[[NSArray alloc] initWithObjects:
	 [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Return Visit", @"category in the Display Rules when picking sorting rules"), MTFilterGroupName,
	  entityName, MTFilterEntityName,
	  [NSArray arrayWithObjects:
	   [NSDictionary dictionaryWithObjectsAndKeys:@"type", MTFilterPath, AlternateLocalizedString(@"Type", @"Title for the Display Rules 'pick a sort rule' screen"), MTFilterUntranslatedName, typeArray, MTFilterValues, typeArray, MTFilterValuesUntranslatedTitles, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"date", MTFilterPath, AlternateLocalizedString(@"Date", @"Title for the Display Rules 'pick a sort rule' screen"), MTFilterUntranslatedName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"notes", MTFilterPath, AlternateLocalizedString(@"Notes", @"Title for the Display Rules 'pick a sort rule' screen"), MTFilterUntranslatedName, nil],
	   nil], MTFilterGroupArray, nil],
	 nil];
	
	return [returnArray autorelease];
}

+ (NSArray *)displayEntriesForCalls
{
	NSArray *locationLookupArray = [NSArray arrayWithObjects:CallLocationTypeGoogleMaps, CallLocationTypeManual, CallLocationTypeDoNotShow, nil];
	NSString *entityName = [MTCall entityName];
	NSArray *returnArray = 
	[[NSArray alloc] initWithObjects:
	 [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Call", @"category in the Display Rules when picking sorting rules"), MTFilterGroupName,
	  entityName, MTFilterEntityName,
	  [NSArray arrayWithObjects:
	   [NSDictionary dictionaryWithObjectsAndKeys:@"name", MTFilterPath, @"uppercaseFirstLetterOfName", MTFilterSectionIndexPath, AlternateLocalizedString(@"Name", @"Title for the Display Rules 'pick a sort rule' screen"), MTFilterUntranslatedName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"locationLookupType", MTFilterPath, AlternateLocalizedString(@"Location Lookup Type", @"Title for the Display Rules 'pick a sort rule' screen"), MTFilterUntranslatedName, locationLookupArray, MTFilterValues, locationLookupArray, MTFilterValuesUntranslatedTitles, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"deletedCall", MTFilterPath, AlternateLocalizedString(@"Deleted", @"Title for the Display Rules 'pick a sort rule' screen"), MTFilterUntranslatedName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"locationAquired", MTFilterPath, AlternateLocalizedString(@"Location Aquired", @"Title for the Display Rules 'pick a sort rule' screen"), MTFilterUntranslatedName, nil],
	   nil], MTFilterGroupArray, nil],
	 [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Address", @"category in the Display Rules when picking sorting rules"), MTFilterGroupName,
	  entityName, MTFilterEntityName,
	  [NSArray arrayWithObjects:
	   [NSDictionary dictionaryWithObjectsAndKeys:@"houseNumber", MTFilterPath, @"houseNumber", MTFilterSectionIndexPath, AlternateLocalizedString(@"House Number", @"Title for the Display Rules 'pick a sort rule' screen"), MTFilterUntranslatedName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"apartmentNumber", MTFilterPath, @"apartmentNumber", MTFilterSectionIndexPath, AlternateLocalizedString(@"Apt/Floor", @"Title for the Display Rules 'pick a sort rule' screen"), MTFilterUntranslatedName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"street", MTFilterPath, @"uppercaseFirstLetterOfStreet", MTFilterSectionIndexPath, AlternateLocalizedString(@"Street", @"Title for the Display Rules 'pick a sort rule' screen"), MTFilterUntranslatedName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"city", MTFilterPath, @"city", MTFilterSectionIndexPath, AlternateLocalizedString(@"City", @"Title for the Display Rules 'pick a sort rule' screen"), MTFilterUntranslatedName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"state", MTFilterPath, @"state", MTFilterSectionIndexPath, AlternateLocalizedString(@"State or Country", @"Title for the Display Rules 'pick a sort rule' screen"), MTFilterUntranslatedName, nil],
	   nil], MTFilterGroupArray, nil],
	 [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Return Visit", @"category in the Display Rules when picking sorting rules"), MTFilterGroupName,
	  entityName, MTFilterEntityName,
	  [NSArray arrayWithObjects:
	   [NSDictionary dictionaryWithObjectsAndKeys:@"mostRecentReturnVisitDate", MTFilterPath, @"dateSortedSectionIndex", MTFilterSectionIndexPath, AlternateLocalizedString(@"Most Recent Return Visit Date", @"Title for the Display Rules 'pick a sort rule' screen"), MTFilterUntranslatedName, nil],
	   [NSDictionary dictionaryWithObjectsAndKeys:@"returnVisits", MTFilterPath, AlternateLocalizedString(@"Return Visit Information", @"Title for the Display Rules 'pick a sort rule' screen"), MTFilterUntranslatedName, [self displayEntriesForReturnVisits], MTFilterSubFilters, [MTReturnVisit entityName], MTFilterEntityName, nil],
	   nil], MTFilterGroupArray, nil],
	 nil];
	
	return [returnArray autorelease];
}

+ (NSArray *)displayEntriesForEntityName:(NSString *)entityName
{
	if([entityName isEqualToString:[MTCall entityName]])
	{
		return [MTFilter displayEntriesForCalls];
	}
	else if([entityName isEqualToString:[MTReturnVisit entityName]])
	{
		return [MTFilter displayEntriesForReturnVisits];
	}
	return nil;
}

+ (NSString *)predicateStringFromPath:(NSString *)path entity:(NSEntityDescription *)entity operator:(NSString *)operator subqueryOperator:(NSString *)subqueryOperator tempVariable:(NSString **)tempVariable isList:(BOOL)isList
{
	NSDictionary *attributesByName = [entity attributesByName];
	NSDictionary *relationshipsByName = [entity relationshipsByName];
	NSArray *keys = [path componentsSeparatedByString:@"."];
	NSString *key = path;
	if(keys == nil || keys.count == 0)
	{
		key = path;
	}
	else
	{
		key = [keys objectAtIndex:0];
	}
	
	if(*tempVariable == nil)
	{
		*tempVariable = key;
	}
	else
	{
		*tempVariable = [NSString stringWithFormat:@"%@.%@", *tempVariable, key];
	}

	for (NSString *relationshipName in [relationshipsByName allKeys]) 
	{
		if([relationshipName isEqualToString:key])
		{
			NSRelationshipDescription *relationshipDescription = [relationshipsByName objectForKey:relationshipName];
			if([keys count] > 1)
			{
				NSArray *tempPath = [keys objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1 , [keys count] - 1)]];
				if ([relationshipDescription isToMany]) 
				{
					// we will have to do a SUBQUERY for this
					NSString *oldTempVariable = *tempVariable;
					*tempVariable = [@"$" stringByAppendingString:key];
					NSString *subPredicate = [self predicateStringFromPath:[tempPath componentsJoinedByString:@"."] entity:[relationshipDescription destinationEntity] operator:operator subqueryOperator:subqueryOperator tempVariable:tempVariable isList:isList];
					NSString *ret = [NSString stringWithFormat:@"SUBQUERY(%@, $%@, %@).@count %@", oldTempVariable, key, subPredicate, subqueryOperator];
					return ret;
				}
				else
				{
					return [self predicateStringFromPath:[tempPath componentsJoinedByString:@"."] entity:[relationshipDescription destinationEntity] operator:operator subqueryOperator:subqueryOperator tempVariable:tempVariable isList:isList];
				}
			}
			else
			{
				if ([relationshipDescription isToMany]) 
				{
					// we will have to do a SUBQUERY for this
					if(isList)
					{
						NSString *oldTempVariable = *tempVariable;
						*tempVariable = [@"$" stringByAppendingString:key];
						return [NSString stringWithFormat:@"SUBQUERY(%@, %@, %%@).@count %@", oldTempVariable, *tempVariable, subqueryOperator];
					}
					else
					{
						return [NSString stringWithFormat:@"SUBQUERY(%@, $%@, $%@ %@ %%@).@count %@", *tempVariable, key, key, operator, subqueryOperator];
					}
				}
				else
				{
					if(isList)
					{
						return @"%@";
					}
					else
					{
						return [NSString stringWithFormat:@"%@ %@ %%@", *tempVariable, operator];
					}
				}
			}

		}
	}

	// the lists are only for the relationships, not the attributes
	assert(isList == NO);
	for (NSString *attributeName in [attributesByName allKeys]) 
	{
		// if this is a string then add quotes to the value.
		if([attributeName isEqualToString:key])
		{
			NSAttributeDescription *attributeDescription = [attributesByName objectForKey:attributeName];
			NSAttributeType type = attributeDescription.attributeType;
			BOOL quotesNeeded;
			switch(type)
			{
				case NSUndefinedAttributeType:
				case NSInteger16AttributeType:
				case NSInteger32AttributeType:
				case NSInteger64AttributeType:
				case NSDecimalAttributeType:
				case NSDoubleAttributeType:
				case NSFloatAttributeType:
				case NSBooleanAttributeType:
				case NSBinaryDataAttributeType:
				case NSTransformableAttributeType:
				case NSObjectIDAttributeType:
					quotesNeeded = NO;
					break;
				default:
				case NSDateAttributeType:
				case NSStringAttributeType:
					quotesNeeded = YES;
					break;
			}
			// placeholder for the value
			if(quotesNeeded)
			{
				return [NSString stringWithFormat:@"%@ %@ \"%%@\"", *tempVariable, operator];
			}
			else
			{
				return [NSString stringWithFormat:@"%@ %@ %%@", *tempVariable, operator];
			}
		}
	}
	assert(false);
	return nil;
}

- (NSAttributeType)typeForPath:(NSString *)path entity:(NSEntityDescription *)entity
{
	NSDictionary *attributesByName = [entity attributesByName];
	NSDictionary *relationshipsByName = [entity relationshipsByName];
	NSArray *keys = [path componentsSeparatedByString:@"."];
	NSString *key = path;
	if(keys == nil || keys.count == 0)
	{
		key = path;
	}
	else
	{
		key = [keys objectAtIndex:0];
	}
	
	for (NSString *relationshipName in [relationshipsByName allKeys]) 
	{
		if([relationshipName isEqualToString:key])
		{
			NSArray *tempPath = [keys objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1 , [keys count] - 1)]];
			NSRelationshipDescription *relationshipDescription = [relationshipsByName objectForKey:relationshipName];
			return [self typeForPath:[tempPath componentsJoinedByString:@"."] entity:[relationshipDescription destinationEntity]];
		}
	}
	
	for (NSString *attributeName in [attributesByName allKeys]) 
	{
		NSAttributeDescription *attributeDescription = [attributesByName objectForKey:attributeName];
		// if this is a string then add quotes to the value.
		if([attributeName isEqualToString:key])
		{
			return [attributeDescription attributeType];
		}
	}
	assert(false);
	return -1;
}

- (NSAttributeType)typeForPath
{
	NSEntityDescription *entity = [NSEntityDescription entityForName:self.filterEntityName inManagedObjectContext:self.managedObjectContext];
	return [self typeForPath:self.path entity:entity];
}

- (void)setList:(NSNumber *)list
{
	[self willChangeValueForKey:@"list"];
	[self setPrimitiveList:list];
	[self didChangeValueForKey:@"list"];
	if([list boolValue])
		self.operator = @"> 0";
}

- (NSString *)title 
{
	NSString *translatedName = [[PSLocalization localizationBundle] localizedStringForKey:self.untranslatedName value:self.untranslatedName table:@""];
	if(self.listValue)
	{
		return translatedName;
	}
	else
	{
		NSString *valueTitle = self.untranslatedValueTitle;
		NSString *operator = self.operator;
		if(valueTitle)
		{
			valueTitle = [[PSLocalization localizationBundle] localizedStringForKey:valueTitle value:valueTitle table:@""];
		}
		else
		{
			if([self typeForPath] == NSDateAttributeType && self.value.length > 0)
			{
				if([operator hasPrefix:@"== "])
				{			
					operator = [operator substringFromIndex:3];
					valueTitle = [[PSLocalization localizationBundle] localizedStringForKey:operator value:operator table:nil];
					operator = @"==";
				}
				else
				{
					NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[self.value doubleValue]];
					// create dictionary entry for This Return Visit
					[NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
					NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
					[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
					if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
					{
						[dateFormatter setDateFormat:@"d/M/yyy h:mma"];
					}
					else
					{
						[dateFormatter setDateFormat:NSLocalizedString(@"M/d/yyy h:mma", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
					}
					
					valueTitle = [dateFormatter stringFromDate:date];
				}
			}
			else
			{
				valueTitle = self.value;
			}
		}
		NSString *caseFlags = @"";
		if(self.caseInsensitiveValue && self.diacriticInsensitiveValue)
		{
			caseFlags = @"[cd]";
		}
		else if(self.diacriticInsensitiveValue)
		{
			caseFlags = @"[d]";
		}
		else if(self.caseInsensitiveValue)
		{
			caseFlags = @"[c]";
		}
		
		if(self.notValue)
		{
			return [NSString stringWithFormat:@"!(%@ %@%@ %@)", translatedName, operator, caseFlags, valueTitle];
		}
		else
		{
			return [NSString stringWithFormat:@"%@ %@%@ %@", translatedName, operator, caseFlags, valueTitle];
		}
	}
}

- (NSString *)predicateStringWithTempVariable:(NSString *)tempVariable
{
	// if the operator has not been specified then this is not an initialized MTFilter
	if(!self.listValue && (self.operator == nil || [self.operator length] == 0))
	{
		return @"";
	}
	NSMutableString *output = [NSMutableString string];
	NSString *newTempVariable = tempVariable == nil ? nil : [[tempVariable copy] autorelease];
	NSString *ourPredicateString;
	NSString *dateType = nil;
	
	// if this is the filter attached directly to the display rule then we just need to aggregate all the predicates togeather
	if(self.displayRule)
	{
		ourPredicateString = @"%@";
	}
	else
	{
		NSString *caseFlags = @"";
		if(self.caseInsensitiveValue && self.diacriticInsensitiveValue)
		{
			caseFlags = @"[cd]";
		}
		else if(self.diacriticInsensitiveValue)
		{
			caseFlags = @"[d]";
		}
		else if(self.caseInsensitiveValue)
		{
			caseFlags = @"[c]";
		}
		NSString *operator = self.operator;
		if([operator hasPrefix:@"== "])
		{			
			dateType = [operator substringFromIndex:3];
			operator = @"BETWEEN";
		}
		ourPredicateString = [MTFilter predicateStringFromPath:self.path 
														entity:[NSEntityDescription entityForName:self.parent.filterEntityName inManagedObjectContext:self.managedObjectContext]
													  operator:[NSString stringWithFormat:@"%@%@", operator, caseFlags]
											  subqueryOperator:@"> 0"
												  tempVariable:&newTempVariable 
														isList:self.listValue];
	}
	
	if(self.listValue)
	{
		if(self.notValue)
		{
			[output appendString:@"!"];
		}
		[output appendString:@"("];
		BOOL isFirst = YES;
		for(MTFilter *filter in self.filters)
		{
			// if the filter has no values within it then skip it
			NSString *newPredicateString = [filter predicateStringWithTempVariable:newTempVariable];
			if([newPredicateString length] == 0)
			{
				continue;
			}
			if(isFirst == NO)
			{
				[output appendString:(self.andValue ? @" AND " : @" OR ")];
			}
			isFirst = NO;
			newPredicateString = [NSString stringWithFormat:newPredicateString, filter.value];
			[output appendString:newPredicateString];
		}
		[output appendString:@")"];
		// if we have no output then let the callers know
		if(isFirst)
		{
			return @"";
		}
		output = [NSString stringWithFormat:ourPredicateString, output];
	}
	else
	{
		id value = self.value;
		if(dateType)
		{
			NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
			// set the default publication to be the watchtower this month and year
			NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
			NSDate *date = [gregorian dateFromComponents:dateComponents];
			NSDate *todayStart = date;
			NSDate *todayEnd = [NSDate dateWithTimeInterval:(60*60*24 - 1) sinceDate:date];
			NSDate *yesterdayStart = [NSDate dateWithTimeInterval:-(60*60*24) sinceDate:date];
			if([dateType isEqualToString:@"Today"])
			{
				ourPredicateString = @"%@";
				value = [NSString stringWithFormat:@"%@ >= \"%f\" && %@ < \"%f\"", newTempVariable, [todayStart timeIntervalSinceReferenceDate], newTempVariable, [todayEnd timeIntervalSinceReferenceDate]];
			}
			else if([dateType isEqualToString:@"Yesterday"])
			{
				ourPredicateString = @"%@";
				value = [NSString stringWithFormat:@"%@ >= \"%f\" && %@ < \"%f\"", newTempVariable, [yesterdayStart timeIntervalSinceReferenceDate], newTempVariable, [todayStart timeIntervalSinceReferenceDate]];
			}
		}
		else if([value length] == 0)
		{
			ourPredicateString = @"%@";
			value = [NSString stringWithFormat:@"%@ == \"\" || %@ == nil", newTempVariable, newTempVariable];
		}
		else
		{
			value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
		}

		
		if(self.notValue)
		{
			[output appendFormat:@"!(%@)", [NSString stringWithFormat:ourPredicateString, value]];
		}
		else
		{
			output = (id)[NSString stringWithFormat:ourPredicateString, value];
		}
	}
	return output;
}

- (NSPredicate *)predicate
{
	NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"user == %@", [MTUser currentUser]];
	NSString *tempString = [self predicateStringWithTempVariable:nil];

	if(tempString == nil || [tempString length] == 0)
		return userPredicate;
	
	NSLog(@"Predicate: %@", tempString);

	return [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:userPredicate, [NSPredicate predicateWithFormat:tempString], nil]];
}

- (NSString *)predicateString
{
	return [self predicateStringWithTempVariable:nil];
}

+ (void)test:(NSManagedObjectContext *)moc
{
#if 0
	NSString *tempVariable = nil;
	NSString *ret;
	
	tempVariable = nil;
	ret = [MTFilter predicateStringFromPath:@"user.calls.additionalInformation" entity:[MTCall entityInManagedObjectContext:moc] operator:nil subqueryOperator:@"> 0" tempVariable:&tempVariable isList:YES];
	NSLog(@"%@", ret);
	assert([@"SUBQUERY(user.calls, $calls, SUBQUERY($calls.additionalInformation, $additionalInformation, %@).@count > 0).@count > 0" isEqualToString:ret]);
	assert([@"$additionalInformation" isEqualToString:tempVariable]);
	tempVariable = nil;
	ret = [MTFilter predicateStringFromPath:@"user.calls" entity:[MTCall entityInManagedObjectContext:moc] operator:nil subqueryOperator:@"> 0" tempVariable:&tempVariable isList:YES];
	NSLog(@"%@", ret);
	assert([@"SUBQUERY(user.calls, $calls, %@).@count > 0" isEqualToString:ret]);
	assert([@"$calls" isEqualToString:tempVariable]);
	tempVariable = nil;
	ret = [MTFilter predicateStringFromPath:@"user" entity:[MTCall entityInManagedObjectContext:moc] operator:nil subqueryOperator:nil tempVariable:&tempVariable isList:YES];
	NSLog(@"%@", ret);
	assert([@"%@" isEqualToString:ret]);
	assert([@"user" isEqualToString:tempVariable]);
	
	
	
	
	tempVariable = nil;
	ret = [MTFilter predicateStringFromPath:@"user.calls.additionalInformation.type" entity:[MTCall entityInManagedObjectContext:moc] operator:@"==" subqueryOperator:@"> 0" tempVariable:&tempVariable isList:NO];
	NSLog(@"%@", ret);
	assert([@"SUBQUERY(user.calls, $calls, SUBQUERY($calls.additionalInformation, $additionalInformation, $additionalInformation.type == %@).@count > 0).@count > 0" isEqualToString:ret]);
	tempVariable = nil;
	ret = [MTFilter predicateStringFromPath:@"user.calls.additionalInformation" entity:[MTCall entityInManagedObjectContext:moc] operator:@"==" subqueryOperator:@"> 0" tempVariable:&tempVariable isList:NO];
	NSLog(@"%@", ret);
	assert([@"SUBQUERY(user.calls, $calls, SUBQUERY($calls.additionalInformation, $additionalInformation, $additionalInformation == %@).@count > 0).@count > 0" isEqualToString:ret]);
	tempVariable = nil;
	ret = [MTFilter predicateStringFromPath:@"user.calls.name" entity:[MTCall entityInManagedObjectContext:moc] operator:@"==" subqueryOperator:@"> 0" tempVariable:&tempVariable isList:NO];
	NSLog(@"%@", ret);
	assert([@"SUBQUERY(user.calls, $calls, $calls.name == %@).@count > 0" isEqualToString:ret]);

	tempVariable = nil;
	ret = [MTFilter predicateStringFromPath:@"user.calls" entity:[MTCall entityInManagedObjectContext:moc] operator:@"==" subqueryOperator:@"> 0" tempVariable:&tempVariable isList:NO];
	NSLog(@"%@", ret);
	assert([@"SUBQUERY(user.calls, $calls, $calls == %@).@count > 0" isEqualToString:ret]);

	tempVariable = nil;
	ret = [MTFilter predicateStringFromPath:@"user.name" entity:[MTCall entityInManagedObjectContext:moc] operator:@"==" subqueryOperator:nil tempVariable:&tempVariable isList:NO];
	NSLog(@"%@", ret);
	assert([@"user.name == %@" isEqualToString:ret]);
	tempVariable = nil;
	ret = [MTFilter predicateStringFromPath:@"user" entity:[MTCall entityInManagedObjectContext:moc] operator:@"==" subqueryOperator:nil tempVariable:&tempVariable isList:NO];
	NSLog(@"%@", ret);
	assert([@"user == %@" isEqualToString:ret]);
	tempVariable = nil;
	ret = [MTFilter predicateStringFromPath:@"name" entity:[MTCall entityInManagedObjectContext:moc] operator:@"==" subqueryOperator:nil tempVariable:&tempVariable isList:NO];
	NSLog(@"%@", ret);
	assert([@"name == %@" isEqualToString:ret]);

	MTFilter *filter;
	MTFilter *subFilter;
	NSMutableArray *deleteThese = [NSMutableArray array];
	filter = [MTFilter insertInManagedObjectContext:moc];
	[deleteThese addObject:filter];
	filter.filterEntityName = [MTCall entityName];
	filter.listValue = NO;
	filter.operator = @"==";
	filter.path = @"name";
	filter.value = @"John";
	ret = [filter predicateString];
	NSLog(@"%@", ret);
	assert([@"name == John" isEqualToString:ret]);

	
	filter = [MTFilter insertInManagedObjectContext:moc];
	[deleteThese addObject:filter];
	filter.filterEntityName = [MTCall entityName];
	filter.listValue = YES;
	filter.operator = @"> 0";
	filter.path = @"additionalInformation";

	subFilter = [MTFilter insertInManagedObjectContext:moc];
	subFilter.parent = filter;
	subFilter.listValue = NO;
	subFilter.path = @"type.name";
	subFilter.value = @"\"Suburb\"";
	subFilter.operator = @"==";
	subFilter.filterEntityName = [MTAdditionalInformation entityName];
	ret = [filter predicateString];
	NSLog(@"%@", ret);

	subFilter = [MTFilter insertInManagedObjectContext:moc];
	subFilter.parent = filter;
	subFilter.listValue = NO;
	subFilter.path = @"type.type";
	subFilter.value = @"7";
	subFilter.operator = @"==";
	subFilter.filterEntityName = [MTAdditionalInformation entityName];
	ret = [filter predicateString];
	NSLog(@"%@", ret);
	
	
	
	
	
	
	for(MTFilter *deleteMe in deleteThese)
	{
		[moc deleteObject:deleteMe];
	}

#endif
}



@end
