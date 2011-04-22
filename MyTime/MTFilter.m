#import "MTFilter.h"
#import "MTDisplayRule.h"
#import "MTCall.h"

@implementation MTFilter

// Custom logic goes here.


+ (MTFilter *)createFilterForDisplayRule:(MTDisplayRule *)displayRule
{
	// first find the highefilterst ordering index
	double order = 0;
	
	for(MTFilter *filter in displayRule.filters)
	{
		double filterOrder = filter.orderValue;
		if (filterOrder > order)
			order = filterOrder;
	}
	
	
	MTFilter *filter = [NSEntityDescription insertNewObjectForEntityForName:[MTFilter entityName]
													 inManagedObjectContext:displayRule.managedObjectContext];
	filter.orderValue = order + 1; // we are using the order to seperate calls and when reordering these will be mobed halfway between displayRules.
	filter.displayRule = displayRule;
	return filter;
}

+ (MTFilter *)createFilterForFilter:(MTDisplayRule *)parentFilter
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
			// placeholder for the value
			return [NSString stringWithFormat:@"%@ %@ %%@", *tempVariable, operator];
		}
	}
	assert(false);
	return nil;
}


- (NSPredicate *)predicate
{
	return [NSPredicate predicateWithFormat:[self predicateStringWithTempVariable:nil]];
}

- (NSString *)predicateStringWithTempVariable:(NSString *)tempVariable
{
	NSMutableString *output = [NSMutableString string];
	NSString *newTempVariable = tempVariable == nil ? nil : [[tempVariable copy] autorelease];
	NSString *ourPredicateString = [MTFilter predicateStringFromPath:self.path 
															  entity:[NSEntityDescription entityForName:@"AdditionalInformation" inManagedObjectContext:self.managedObjectContext]
															operator:nil 
													subqueryOperator:@"> 0" 
														tempVariable:&newTempVariable 
															  isList:self.listValue];
	if(self.listValue)
	{
		[output appendString:@"("];
		BOOL isFirst = YES;
		for(MTFilter *filter in self.filters)
		{
			if(isFirst == NO)
			{
				[output appendString:(self.andValue ? @" AND " : @" OR ")];
			}
			isFirst = NO;
			[output appendString:[filter predicateStringWithTempVariable:newTempVariable]];
		}
		[output appendString:@")"];
		output = [NSString stringWithFormat:ourPredicateString, output];
	}
	else
	{
		output = (id)ourPredicateString;
	}
	return output;
}

+ (void)test:(NSManagedObjectContext *)moc
{
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


}
@end
