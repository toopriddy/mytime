//
//  NSManagedObjectContext+PriddySoftware.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext(PriddySoftware)
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
						 withPredicate:(id)stringOrPredicate, ...;
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
					 propertiesToFetch:(NSArray *)propertiesToFetch
						 withPredicate:(id)stringOrPredicate, ...;
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
					 propertiesToFetch:(NSArray *)propertiesToFetch
				   withSortDescriptors:(NSArray *)sortDescriptors
						 withPredicate:(id)stringOrPredicate, ...;

- (NSUInteger)countForFetchedObjectsForEntityName:(NSString *)newEntityName
									withPredicate:(id)stringOrPredicate, ...;

- (NSDictionary *)dictionaryFromManagedObject:(NSManagedObject*)managedObject skipRelationshipNames:(NSArray *)skipRelationshipNames;
- (NSManagedObject*)managedObjectFromDictionary:(NSDictionary*)structureDictionary;


+ (void)presentErrorDialog:(NSError *)error;

@end
