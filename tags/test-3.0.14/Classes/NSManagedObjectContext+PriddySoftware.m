//
//  NSManagedObjectContext+PriddySoftware.m
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "NSManagedObjectContext+PriddySoftware.h"

@implementation NSSortDescriptor(PriddySoftware)
+ (id)psSortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending
{
	return [[[NSSortDescriptor alloc] initWithKey:key ascending:ascending] autorelease];
}
+ (id)psSortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending selector:(SEL)selector
{
	return [[[NSSortDescriptor alloc] initWithKey:key ascending:ascending selector:selector] autorelease];
}
@end

@implementation NSManagedObjectContext(PriddySoftware)
// Convenience method to fetch the array of objects for a given Entity
// name in the context, optionally limiting by a predicate or by a predicate
// made from a format NSString and variable arguments.
//
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
					 propertiesToFetch:(NSArray *)propertiesToFetch
				   withSortDescriptors:(NSArray *)sortDescriptors
						 withPredicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription
								   entityForName:newEntityName inManagedObjectContext:self];
	
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
	if(propertiesToFetch)
		[request setPropertiesToFetch:propertiesToFetch];
	
	if(sortDescriptors)
		[request setSortDescriptors:sortDescriptors];
	
    if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
											   arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
					  @"Second parameter passed to %s is of unexpected class %@",
					  sel_getName(_cmd), [stringOrPredicate description]);
            predicate = (NSPredicate *)stringOrPredicate;
        }
        [request setPredicate:predicate];
    }
	
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:request error:&error];
    if (error != nil)
    {
        [NSException raise:NSGenericException format:@"%@", [error description]];
    }
    
    return results;
}

- (NSUInteger)countForFetchedObjectsForEntityName:(NSString *)newEntityName
									withPredicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription
								   entityForName:newEntityName inManagedObjectContext:self];
	
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
	
    if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
											   arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
					  @"Second parameter passed to %s is of unexpected class %@",
					  sel_getName(_cmd), [stringOrPredicate description]);
            predicate = (NSPredicate *)stringOrPredicate;
        }
        [request setPredicate:predicate];
    }
    NSError *error = nil;
	NSUInteger count = [self countForFetchRequest:request error:&error];
    if (error != nil)
    {
        [NSException raise:NSGenericException format:@"%@", [error description]];
    }
    
    return count;
}


// Convenience method to fetch the array of objects for a given Entity
// name in the context, optionally limiting by a predicate or by a predicate
// made from a format NSString and variable arguments.
//
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
					 propertiesToFetch:(NSArray *)propertiesToFetch
						 withPredicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription
								   entityForName:newEntityName inManagedObjectContext:self];
	
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
	if(propertiesToFetch)
		[request setPropertiesToFetch:propertiesToFetch];
	
    if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
											   arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
					  @"Second parameter passed to %s is of unexpected class %@",
					  sel_getName(_cmd), [stringOrPredicate description]);
            predicate = (NSPredicate *)stringOrPredicate;
        }
        [request setPredicate:predicate];
    }
	
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:request error:&error];
    if (error != nil)
    {
        [NSException raise:NSGenericException format:@"%@", [error description]];
    }
    
    return results;
}

// Convenience method to fetch the array of objects for a given Entity
// name in the context, optionally limiting by a predicate or by a predicate
// made from a format NSString and variable arguments.
//
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
						 withPredicate:(id)stringOrPredicate, ...
{
    NSEntityDescription *entity = [NSEntityDescription
								   entityForName:newEntityName inManagedObjectContext:self];
	
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entity];
    
    if (stringOrPredicate)
    {
        NSPredicate *predicate;
        if ([stringOrPredicate isKindOfClass:[NSString class]])
        {
            va_list variadicArguments;
            va_start(variadicArguments, stringOrPredicate);
            predicate = [NSPredicate predicateWithFormat:stringOrPredicate
											   arguments:variadicArguments];
            va_end(variadicArguments);
        }
        else
        {
            NSAssert2([stringOrPredicate isKindOfClass:[NSPredicate class]],
					  @"Second parameter passed to %s is of unexpected class %@",
					  sel_getName(_cmd), [stringOrPredicate description]);
            predicate = (NSPredicate *)stringOrPredicate;
        }
        [request setPredicate:predicate];
    }
	
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:request error:&error];
    if (error != nil)
    {
        [NSException raise:NSGenericException format:@"%@", [error description]];
    }
    
    return results;
}

+ (void)presentErrorDialog:(NSError *)error
{
	NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
	NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
	if(detailedErrors != nil && [detailedErrors count] > 0) 
	{
		for(NSError* detailedError in detailedErrors) 
		{
			NSLog(@"  DetailedError: %@", [detailedError userInfo]);
		}
	}
	else 
	{
		NSLog(@"  %@", [error userInfo]);
	}
	NSThread *thread = [NSThread mainThread];
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving Data", @"This is a dialog message title whenever there is an error saving data; you should not see this normally") 
													 message:[NSString stringWithFormat:@"%@\n %@ %@", NSLocalizedString(@"There was an error trying to save data, this is very bad... Please try again or quit the application.", @"This is a dialog message title whenever there is an error saving data; you should not see this normally"), error, [error userInfo]] 
													delegate:nil
										   cancelButtonTitle:NSLocalizedString(@"OK", @"Dismiss an Alert View") 
										   otherButtonTitles:nil] autorelease];
	if(thread == [NSThread currentThread])
	{
		[alert show];
	}
	else
	{
		[alert performSelector:@selector(show) onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES];
		assert(false);
	}

}

- (NSDictionary *)dictionaryFromManagedObject:(NSManagedObject*)managedObject skipRelationshipNames:(NSArray *)skipRelationshipNames visitedObjects:(NSMutableArray *)visitedObjects currentPath:(NSString *)currentPath
{
	NSDictionary *attributesByName = [[managedObject entity] attributesByName];
	NSDictionary *relationshipsByName = [[managedObject entity] relationshipsByName];
	NSMutableDictionary *valuesDictionary = [[managedObject dictionaryWithValuesForKeys:[attributesByName allKeys]] mutableCopy];
	[valuesDictionary setObject:[[managedObject entity] name] forKey:@"ManagedObjectName"];
	visitedObjects = [NSMutableArray arrayWithArray:visitedObjects];
	[visitedObjects addObject:managedObject];
	
	for (NSString *relationshipName in [relationshipsByName allKeys]) 
	{
		NSString *newCurrentPath = [currentPath stringByAppendingFormat:@".%@", relationshipName];

		id namedRelationshipObject = [managedObject valueForKey:relationshipName];
		NSRelationshipDescription *relationshipDescription = [relationshipsByName objectForKey:relationshipName];
		
		// skip relationship names
		if(skipRelationshipNames && [skipRelationshipNames indexOfObject:newCurrentPath] != NSNotFound)
		{
#if 1
			// go ahead and add these to skip later on
			if (![relationshipDescription isToMany]) 
			{
				[visitedObjects addObject:namedRelationshipObject];
			}
			else
			{
				[visitedObjects addObjectsFromArray:namedRelationshipObject];
			}
#endif
			continue;
		}
		
		if (![relationshipDescription isToMany]) 
		{
			if(namedRelationshipObject == nil || [visitedObjects containsObject:namedRelationshipObject])
				continue;
			
			[valuesDictionary setValue:[self dictionaryFromManagedObject:namedRelationshipObject skipRelationshipNames:skipRelationshipNames visitedObjects:visitedObjects currentPath:newCurrentPath] forKey:relationshipName];
		}
		else
		{
			NSSet *relationshipObjects = namedRelationshipObject;
			NSMutableArray *relationshipArray = [NSMutableArray array];
			for (NSManagedObject *relationshipObject in relationshipObjects) 
			{
				if([visitedObjects containsObject:relationshipObject])
					continue;
				[relationshipArray addObject:[self dictionaryFromManagedObject:relationshipObject skipRelationshipNames:skipRelationshipNames visitedObjects:visitedObjects currentPath:newCurrentPath]];
			}
			[valuesDictionary setObject:relationshipArray forKey:relationshipName];
		}
	}
	return [valuesDictionary autorelease];
}

- (NSDictionary *)dictionaryFromManagedObject:(NSManagedObject*)managedObject skipRelationshipNames:(NSArray *)skipRelationshipNames
{
	return [self dictionaryFromManagedObject:managedObject skipRelationshipNames:skipRelationshipNames visitedObjects:[NSMutableArray array] currentPath:@"self"];
}

- (NSManagedObject*)managedObjectFromDictionary:(NSDictionary*)structureDictionary
{
	return [self managedObjectFromDictionary:structureDictionary uniqueObjects:nil];
}

- (NSManagedObject*)managedObjectFromDictionary:(NSDictionary*)structureDictionary uniqueObjects:(NSDictionary *)uniqueObjects
{
	NSManagedObjectContext *moc = self;
	NSString *objectName = [structureDictionary objectForKey:@"ManagedObjectName"];
	NSArray *uniqueAttributeNames = [uniqueObjects objectForKey:objectName];
	if(uniqueAttributeNames)
	{
		NSMutableArray *predicateArray = [NSMutableArray array];
		
		for(NSString *attributeName in uniqueAttributeNames)
		{
			NSObject *value = [structureDictionary objectForKey:attributeName];
			if(value && ![value isKindOfClass:[NSNull class]])
			{
				[predicateArray addObject:[NSPredicate predicateWithFormat:@"%K == %@", attributeName, value]];
			}
		}
		NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
		NSArray *foundManagedObjects = [self fetchObjectsForEntityName:objectName withPredicate:predicate];
		if([foundManagedObjects count] == 1)
		{
			return [foundManagedObjects lastObject];
		}
	}
	
	// if we cant find a unique object, then just make one
	NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:objectName inManagedObjectContext:moc];
	// set the attributes
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:objectName inManagedObjectContext:self];
	NSArray *attributeNames = [[entityDescription attributesByName] allKeys];
	for(NSString *name in attributeNames)
	{
		NSObject *value = [structureDictionary objectForKey:name];
		if(value && ![value isKindOfClass:[NSNull class]])
		{
			[managedObject setValue:value forKey:name];
		}
	}
	
	// now for the relationships
	NSDictionary *relationshipsByName = [[managedObject entity] relationshipsByName];
	
	for (NSString *relationshipName in [[[managedObject entity] relationshipsByName] allKeys]) 
	{
		NSRelationshipDescription *description = [relationshipsByName objectForKey:relationshipName];
		if (![description isToMany]) 
		{
			NSDictionary *childStructureDictionary = [structureDictionary objectForKey:relationshipName];
			if(childStructureDictionary && ![childStructureDictionary isKindOfClass:[NSNull class]])
			{
				NSManagedObject *childObject = [self managedObjectFromDictionary:childStructureDictionary uniqueObjects:uniqueObjects];
				[managedObject setValue:childObject forKey:relationshipName];
			}
			continue;
		}
		NSMutableSet *relationshipSet = [managedObject mutableSetValueForKey:relationshipName];
		NSArray *relationshipArray = [structureDictionary objectForKey:relationshipName];
		for (NSDictionary *childStructureDictionary in relationshipArray) 
		{
			NSManagedObject *childObject = [self managedObjectFromDictionary:childStructureDictionary uniqueObjects:uniqueObjects];
			[relationshipSet addObject:childObject];
		}
	}
	return managedObject;
}

@end